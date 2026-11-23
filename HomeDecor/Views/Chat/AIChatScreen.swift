//
//  AIChatScreen.swift
//  HomeDecor
//
//  Phase 7 — AI Chat (Figma 10:27693 Welcome, 10:27885 Conversation, and the
//  Attach Photo / Chat Options sheets + Clear Chat popup). Opened from the AI
//  Chat FAB. Uses the system keyboard. Replies come from `ChatStore` (server
//  agent when live; mock for now).
//

import SwiftUI
import Factory
import PhotosUI

struct AIChatScreen: View {
    var onClose: () -> Void = {}
    @InjectedObject(\.chatStore) private var store: ChatStore

    @State private var input = ""
    @State private var showAttach = false
    @State private var showOptions = false
    @State private var showClear = false
    @State private var showHistory = false
    @State private var showCamera = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            header
            messages
            inputBar
                .padding(.bottom, keyboardHeight)
        }
        .background(BlobBackground().ignoresSafeArea())
        // Hosted in a UIHostingController whose safeAreaRegions excludes
        // `.keyboard` (see HostedChat), so SwiftUI never applies its iOS-26
        // keyboard-avoidance (which shifted this bar up off its touch target).
        // We lift the bar for a REAL keyboard ourselves.
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { note in
            guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let overlap = max(0, UIScreen.main.bounds.height - frame.minY)
            let safeBottom = UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow?.safeAreaInsets.bottom }.first ?? 0
            withAnimation(.easeOut(duration: 0.25)) { keyboardHeight = overlap > 150 ? max(0, overlap - safeBottom) : 0 }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeOut(duration: 0.2)) { keyboardHeight = 0 }
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if showClear {
                CoralPopup(
                    icon: "trash.fill",
                    title: "clear_chat_title".localized, message: "clear_chat_message".localized,
                    primaryTitle: "cancel".localized, primaryAction: { showClear = false },
                    secondaryTitle: "clear".localized, secondaryAction: {
                        showClear = false; store.clearCurrent()
                    },
                    horizontal: true)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showClear)
        .sheet(isPresented: $showAttach) { attachSheet }
        .sheet(isPresented: $showOptions) { optionsSheet }
        .sheet(isPresented: $showHistory) {
            ChatHistorySheet(onClose: { showHistory = false })
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { img in if let img { store.sendPhoto(img, caption: nil) } }
                .ignoresSafeArea()
        }
        .onChange(of: pickerItem) { loadPicked($0) }
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            HStack(spacing: 10) {
                AIAvatar(size: 36)
                VStack(alignment: .leading, spacing: 1) {
                    Text("ai_designer".localized)
                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(AppColor.ink)
                    HStack(spacing: 5) {
                        Circle().fill(Color(hex: 0x4DCC80)).frame(width: 7, height: 7)
                        Text("online".localized).font(.system(size: 12)).foregroundStyle(AppColor.inkSecondary)
                    }
                }
            }
            HStack {
                Button { onClose() } label: {
                    Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColor.ink).frame(width: 44, height: 44).glassButton()
                }
                .buttonStyle(PressableStyle())
                Spacer()
                Button { showOptions = true } label: {
                    Image(systemName: "ellipsis").font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColor.ink).frame(width: 44, height: 44).glassButton()
                }
                .buttonStyle(PressableStyle())
            }
        }
        .frame(height: 44).padding(.horizontal, 24).padding(.top, 8).padding(.bottom, 10)
    }

    // MARK: Messages

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                if store.isEmpty {
                    welcome
                } else {
                    LazyVStack(spacing: 16) {
                        Text(dateLabel)
                            .font(.system(size: 12)).foregroundStyle(AppColor.inkSecondary)
                            .frame(maxWidth: .infinity)
                        ForEach(store.messages) { msg in
                            messageRow(msg)
                        }
                        if store.pending != nil { pendingRow }
                        Color.clear.frame(height: 1).id(bottomID)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
            }
            .onChange(of: store.messages.count) { _ in scrollToBottom(proxy) }
            .onChange(of: store.pending) { _ in scrollToBottom(proxy) }
        }
    }

    private let bottomID = "chat-bottom"

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo(bottomID, anchor: .bottom) }
    }

    private var dateLabel: String {
        let f = DateFormatter(); f.timeStyle = .short; f.dateStyle = .none
        return "\("today".localized) \(f.string(from: Date()))"
    }

    @ViewBuilder
    private func messageRow(_ msg: ChatMessage) -> some View {
        switch msg.role {
        case .user: UserRow(msg: msg) { store.retry(msg) }
        case .assistant: AIRow(msg: msg, onQuickReply: { store.send($0) }, onCTA: { store.send(msg.ctaLabel ?? "") })
        }
    }

    private var pendingRow: some View {
        HStack(alignment: .bottom, spacing: 8) {
            AIAvatar(size: 28)
            Group {
                switch store.pending {
                case .analyzing: AnalyzingBubble()
                default:         TypingBubble()
                }
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: Welcome (empty state)

    private var welcome: some View {
        VStack(spacing: 20) {
            AIAvatar(size: 132)
                .shadow(color: Color(hex: 0xE54D2E).opacity(0.35), radius: 15, x: 0, y: 16)
            VStack(spacing: 6) {
                Text("ai_welcome_title".localized)
                    .font(.system(size: 22, weight: .bold)).foregroundStyle(AppColor.ink)
                Text("ai_welcome_subtitle".localized)
                    .font(.system(size: 14)).foregroundStyle(AppColor.inkSecondary)
                    .multilineTextAlignment(.center).frame(width: 300)
            }
            VStack(spacing: 10) {
                suggestion("ai_suggest_1".localized)
                suggestion("ai_suggest_2".localized)
                suggestion("ai_suggest_3".localized)
            }
        }
        .padding(.top, 40).padding(.horizontal, 20).padding(.bottom, 24)
    }

    private func suggestion(_ text: String) -> some View {
        Button { store.send(text) } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles").font(.system(size: 16, weight: .medium)).foregroundStyle(AppColor.coral)
                Text(text).font(.system(size: 14, weight: .medium)).foregroundStyle(AppColor.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(AppColor.inkSecondary)
            }
            .padding(.horizontal, 16).frame(height: 52)
            .glassPanel(24)
        }
        .buttonStyle(PressableStyle())
    }

    // MARK: Input bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            Button { showAttach = true } label: {
                Image(systemName: "plus").font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColor.ink).frame(width: 44, height: 44).glassButton()
            }
            .buttonStyle(PressableStyle())

            HStack(spacing: 8) {
                ChatInputField(text: $input, placeholder: "ai_input_placeholder".localized, onSubmit: sendInput)
                    .frame(height: 24)
                    .padding(.leading, 18)
                Button(action: sendInput) {
                    Image(systemName: "paperplane.fill").font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white).frame(width: 36, height: 36)
                        .background(canSend ? AppColor.coral : AppColor.coral.opacity(0.4), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(PressableStyle())
                .disabled(!canSend)
                .padding(.trailing, 6)
            }
            .frame(minHeight: 48)
            .glassPanel(24)
        }
        .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 10)
    }

    private var canSend: Bool { !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    private func sendInput() {
        guard canSend else { return }
        store.send(input)
        input = ""
    }

    // MARK: Attach Photo sheet (Figma 10:28077)

    private var attachSheet: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("add_photo".localized).font(.system(size: 19, weight: .bold)).foregroundStyle(AppColor.ink)
                Text("attach_photo_subtitle".localized).font(.system(size: 13)).foregroundStyle(AppColor.inkSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)
            HStack(spacing: 12) {
                Button {
                    showAttach = false
                    if CameraPicker.isAvailable { showCamera = true }
                } label: {
                    sheetCard(icon: "camera", title: "take_photo".localized, sub: "take_photo_sub".localized)
                }
                .buttonStyle(PressableStyle())
                PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                    sheetCard(icon: "photo", title: "photo_library".localized, sub: "photo_library_sub".localized)
                }
                .buttonStyle(PressableStyle())
            }
            Button { showAttach = false } label: {
                Text("cancel".localized).font(.system(size: 15, weight: .medium)).foregroundStyle(AppColor.ink)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(AppColor.ink.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(PressableStyle())
        }
        .padding(.horizontal, 20).padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BlobBackground())
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.visible)
    }

    private func sheetCard(icon: String, title: String, sub: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon).font(.system(size: 22)).foregroundStyle(AppColor.coral)
                .frame(width: 48, height: 48).glassPanel(24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColor.ink)
                Text(sub).font(.system(size: 12)).foregroundStyle(AppColor.inkSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16).padding(.vertical, 18)
        .glassPanel(28)
    }

    // MARK: Chat Options sheet (Figma 10:29098)

    private var optionsSheet: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                optionRow("clock.arrow.circlepath", "chat_history".localized, tint: AppColor.ink) {
                    showOptions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showHistory = true }
                }
                Divider().overlay(AppColor.ink.opacity(0.08))
                optionRow("square.and.pencil", "new_chat".localized, tint: AppColor.ink) {
                    showOptions = false; store.newConversation()
                }
                Divider().overlay(AppColor.ink.opacity(0.08))
                optionRow("trash", "clear_chat".localized, tint: Color(hex: 0xFF8A80)) {
                    showOptions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showClear = true }
                }
            }
            .glassPanel(28)
            Button { showOptions = false } label: {
                Text("cancel".localized).font(.system(size: 15, weight: .medium)).foregroundStyle(AppColor.ink)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(AppColor.ink.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(PressableStyle())
        }
        .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BlobBackground())
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }

    private func optionRow(_ icon: String, _ title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.system(size: 18)).foregroundStyle(tint).frame(width: 22)
                Text(title).font(.system(size: 16, weight: .medium)).foregroundStyle(tint)
                Spacer()
            }
            .padding(.horizontal, 16).frame(height: 56).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func loadPicked(_ item: PhotosPickerItem?) {
        guard let item else { return }
        showAttach = false
        Task {
            if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                await MainActor.run { store.sendPhoto(PhotoTools.normalized(image), caption: nil); pickerItem = nil }
            }
        }
    }
}

// MARK: - Sized AI avatar

struct AIAvatar: View {
    var size: CGFloat
    var body: some View {
        AIAvatarView()
            .frame(width: 64, height: 64)
            .scaleEffect(size / 64)
            .frame(width: size, height: size)
    }
}

// MARK: - Bubble shape

private func bubbleShape(ai: Bool) -> UnevenRoundedRectangle {
    UnevenRoundedRectangle(
        topLeadingRadius: 20,
        bottomLeadingRadius: ai ? 6 : 20,
        bottomTrailingRadius: ai ? 20 : 6,
        topTrailingRadius: 20,
        style: .continuous)
}

private extension View {
    func chatBubble(ai: Bool) -> some View {
        let shape = bubbleShape(ai: ai)
        return self
            .background(.ultraThinMaterial, in: shape)
            .overlay(shape.strokeBorder(.white.opacity(0.8), lineWidth: 1))
            .shadow(color: Color(hex: 0x593826).opacity(0.07), radius: 12, x: 0, y: 8)
    }
}

private func bubbleText(_ markdown: String) -> Text {
    let attr = (try? AttributedString(
        markdown: markdown,
        options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(markdown)
    return Text(attr)
}

// MARK: - User row

private struct UserRow: View {
    let msg: ChatMessage
    var onRetry: () -> Void

    var body: some View {
        HStack {
            Spacer(minLength: 40)
            VStack(alignment: .trailing, spacing: 6) {
                VStack(alignment: .leading, spacing: 10) {
                    if let image = msg.image {
                        Image(uiImage: image).resizable().scaledToFill()
                            .frame(maxWidth: 260, maxHeight: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    if let caption = msg.caption {
                        Text(caption).font(.system(size: 15)).foregroundStyle(AppColor.ink)
                    }
                    if msg.image == nil, let text = msg.text {
                        bubbleText(text).font(.system(size: 15)).foregroundStyle(AppColor.ink)
                            .frame(maxWidth: 250, alignment: .leading)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .chatBubble(ai: false)

                if msg.failed {
                    Button(action: onRetry) {
                        HStack(spacing: 4) {
                            Text("not_delivered".localized).foregroundStyle(AppColor.inkSecondary)
                            Text("·").foregroundStyle(AppColor.inkSecondary)
                            Text("tap_to_retry".localized).foregroundStyle(AppColor.coral).fontWeight(.semibold)
                        }
                        .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - AI row

private struct AIRow: View {
    let msg: ChatMessage
    var onQuickReply: (String) -> Void
    var onCTA: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                AIAvatar(size: 28)
                VStack(alignment: .leading, spacing: 10) {
                    if let text = msg.text {
                        bubbleText(text).font(.system(size: 15)).foregroundStyle(AppColor.ink)
                            .frame(maxWidth: 250, alignment: .leading)
                    }
                    if let asset = msg.asset, msg.styleIdeas == nil {
                        Image(asset).resizable().scaledToFill()
                            .frame(maxWidth: 250, maxHeight: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    if let palette = msg.palette { paletteRow(palette, caption: msg.paletteCaption) }
                    if let ideas = msg.styleIdeas { styleIdeasRow(ideas) }
                    if let cta = msg.ctaLabel { ctaButton(cta) }
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .chatBubble(ai: true)
                Spacer(minLength: 0)
            }

            if let quick = msg.quickReplies {
                HStack(spacing: 8) {
                    ForEach(quick, id: \.self) { q in
                        Button { onQuickReply(q) } label: {
                            Text(q).font(.system(size: 13, weight: .medium)).foregroundStyle(AppColor.ink)
                                .padding(.horizontal, 16).frame(height: 38)
                                .glassPanel(19)
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
                .padding(.leading, 36)
            }
        }
    }

    private func paletteRow(_ swatches: [PaletteSwatch], caption: String?) -> some View {
        HStack(spacing: 6) {
            ForEach(swatches) { s in
                Group {
                    if let hex = s.hex {
                        Color(hex: hex)
                    } else {
                        Rectangle().fill(.ultraThinMaterial)
                    }
                }
                .frame(width: 22, height: 22)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).strokeBorder(AppColor.ink.opacity(0.12), lineWidth: 1))
            }
            if let caption {
                Text(caption).font(.system(size: 12)).foregroundStyle(AppColor.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func styleIdeasRow(_ ideas: [StyleIdea]) -> some View {
        HStack(spacing: 8) {
            ForEach(ideas) { idea in
                VStack(spacing: 6) {
                    Image(idea.asset).resizable().scaledToFill()
                        .frame(width: 74, height: 74)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Text(idea.name).font(.system(size: 11, weight: .medium)).foregroundStyle(AppColor.ink)
                        .lineLimit(1)
                }
                .frame(width: 74)
            }
        }
    }

    private func ctaButton(_ label: String) -> some View {
        Button(action: onCTA) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles").font(.system(size: 13, weight: .semibold))
                Text(label).font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(AppColor.coral)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Typing / Analyzing bubbles

private struct TypingBubble: View {
    @State private var phase = 0
    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle().fill(AppColor.coral.opacity(phase == i ? 0.95 : 0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 14)
        .chatBubble(ai: true)
        .onReceive(timer) { _ in phase = (phase + 1) % 3 }
    }
}

private struct AnalyzingBubble: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColor.coral)
            VStack(alignment: .leading, spacing: 6) {
                Text("analyzing_room".localized).font(.system(size: 14)).foregroundStyle(AppColor.ink)
                ProgressView().progressViewStyle(.linear).tint(AppColor.coral).frame(width: 150)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .chatBubble(ai: true)
    }
}

// MARK: - Host that opts out of the keyboard safe area

/// Wraps `AIChatScreen` in a `UIHostingController` whose `safeAreaRegions`
/// excludes `.keyboard`. On iOS 26 SwiftUI's own keyboard avoidance shifts a
/// bottom-anchored bar up off its hit-area (a known platform bug); excluding
/// the keyboard region at the hosting layer is the reliable opt-out.
struct HostedChat: UIViewControllerRepresentable {
    var onClose: () -> Void

    func makeUIViewController(context: Context) -> UIHostingController<AIChatScreen> {
        let hc = UIHostingController(rootView: AIChatScreen(onClose: onClose))
        if #available(iOS 16.4, *) { hc.safeAreaRegions = .container }
        hc.view.backgroundColor = .clear
        return hc
    }
    func updateUIViewController(_ controller: UIHostingController<AIChatScreen>, context: Context) {}
}

// MARK: - UIKit-backed input field

/// A UIKit `UITextField`. Using SwiftUI's `TextField` here made SwiftUI apply a
/// keyboard-avoidance transform to the whole input bar even while idle (an
/// iOS-26 simulator quirk), shifting it up visually off its touch target.
struct ChatInputField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onSubmit: () -> Void

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = .systemFont(ofSize: 15)
        tf.textColor = UIColor(AppColor.ink)
        tf.tintColor = UIColor(AppColor.coral)
        tf.returnKeyType = .send
        tf.autocorrectionType = .no
        tf.delegate = context.coordinator
        tf.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .editingChanged)
        tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return tf
    }

    func updateUIView(_ tf: UITextField, context: Context) {
        if tf.text != text { tf.text = text }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ChatInputField
        init(_ parent: ChatInputField) { self.parent = parent }
        @objc func changed(_ tf: UITextField) { parent.text = tf.text ?? "" }
        func textFieldShouldReturn(_ tf: UITextField) -> Bool { parent.onSubmit(); return false }
    }
}

// MARK: - Camera (system) picker

struct CameraPicker: UIViewControllerRepresentable {
    var onResult: (UIImage?) -> Void
    static var isAvailable: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let p = UIImagePickerController()
        p.sourceType = .camera
        p.delegate = context.coordinator
        return p
    }
    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(onResult: onResult) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onResult: (UIImage?) -> Void
        init(onResult: @escaping (UIImage?) -> Void) { self.onResult = onResult }
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let img = (info[.originalImage] as? UIImage).map { PhotoTools.normalized($0) }
            picker.dismiss(animated: true) { self.onResult(img) }
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) { self.onResult(nil) }
        }
    }
}
