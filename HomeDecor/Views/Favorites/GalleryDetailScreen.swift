//
//  GalleryDetailScreen.swift
//  HomeDecor
//
//  My look — Gallery Detail (Figma 10:24225) + Image Options sheet (10:24412).
//  A Before/After view of a saved look with Download / Share / Delete, plus a
//  "⋯" options sheet.
//

import SwiftUI
import Factory

struct GalleryDetailScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.myLook) private var store: MyLookStore

    @State private var split: CGFloat = 0.5
    @State private var showOptions = false
    @State private var showShare = false
    @State private var showDelete = false
    @State private var toast: String?

    private let cardHeight: CGFloat = 500

    private var look: LookStore.Look? { store.detail }
    private var after: UIImage? { look.flatMap { LookStore.shared.image(for: $0) } }
    private var before: UIImage? { look.flatMap { LookStore.shared.beforeImage(for: $0) } }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    beforeAfter
                    meta
                    actions
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .background(BlobBackground().ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .bottom) {
            if let toast {
                ToastView(icon: "checkmark.circle.fill", text: toast)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: toast)
        .overlay {
            if showDelete {
                CoralPopup(
                    icon: "trash.fill", badge: "xmark",
                    title: "delete_look_title".localized, message: "delete_look_message".localized,
                    primaryTitle: "cancel".localized, primaryAction: { showDelete = false },
                    secondaryTitle: "delete".localized, secondaryAction: { performDelete() })
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showDelete)
        .sheet(isPresented: $showOptions) { optionsSheet }
        .sheet(isPresented: $showShare) { if let a = after { ActivityView(items: [a]) } }
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            Text("my_look".localized)
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
            HStack {
                Button { app.navi.pop() } label: {
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
        .frame(height: 44).padding(.horizontal, 20).padding(.top, 8)
    }

    // MARK: Before / After

    private var beforeAfter: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                if let after { Image(uiImage: after).resizable().scaledToFill().frame(width: w, height: cardHeight).clipped() }
                if let before {
                    Image(uiImage: before).resizable().scaledToFill().frame(width: w, height: cardHeight).clipped()
                        .mask(alignment: .leading) { Rectangle().frame(width: w * split) }
                    Rectangle().fill(.white).frame(width: 2, height: cardHeight).offset(x: w * split - 1)
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        .frame(width: 44, height: 44).background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1))
                        .offset(x: w * split - 22, y: cardHeight / 2 - 22)
                    chip("before".localized).padding(11)
                    chip("after".localized).frame(maxWidth: .infinity, alignment: .trailing).padding(11)
                }
            }
            .frame(width: w, height: cardHeight)
            .contentShape(Rectangle())
            .gesture(before == nil ? nil : DragGesture(minimumDistance: 0)
                .onChanged { v in split = min(1, max(0, v.location.x / w)) })
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(AppColor.ink.opacity(0.12), lineWidth: 1))
        }
        .frame(height: cardHeight)
    }

    private func chip(_ text: String) -> some View {
        Text(text).font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
            .padding(.horizontal, 14).frame(height: 30)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.5), lineWidth: 1))
    }

    private var meta: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(look?.name ?? "my_look".localized).font(.system(size: 20, weight: .bold)).foregroundStyle(AppColor.ink)
            if let room = look?.room {
                Text("\(room) · \((look?.isOutside ?? false) ? "outside".localized : "inside".localized)")
                    .font(.system(size: 13)).foregroundStyle(AppColor.inkSecondary)
            }
        }
    }

    private var actions: some View {
        HStack(spacing: 10) {
            actionCard("square.and.arrow.down", "download".localized, tint: AppColor.ink) { download() }
            actionCard("square.and.arrow.up", "share_action".localized, tint: AppColor.ink) { showShare = true }
            actionCard("trash", "delete".localized, tint: Color(hex: 0xFF8A80)) { showDelete = true }
        }
    }

    private func actionCard(_ icon: String, _ title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 20, weight: .regular))
                Text(title).font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity).frame(height: 76)
            .glassPanel(28)
        }
        .buttonStyle(PressableStyle())
    }

    // MARK: Options sheet

    private var optionsSheet: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                if let after {
                    Image(uiImage: after).resizable().scaledToFill().frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(look?.name ?? "my_look".localized).font(.system(size: 16, weight: .semibold)).foregroundStyle(AppColor.ink)
                    if let room = look?.room {
                        Text("\(room) · \((look?.isOutside ?? false) ? "outside".localized : "inside".localized)")
                            .font(.system(size: 12)).foregroundStyle(AppColor.inkSecondary)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 8)

            VStack(spacing: 0) {
                optionRow("square.and.arrow.down", "download".localized, tint: AppColor.ink) { showOptions = false; download() }
                Divider().overlay(AppColor.ink.opacity(0.08))
                optionRow("square.and.arrow.up", "share_action".localized, tint: AppColor.ink) { showOptions = false; showShare = true }
                Divider().overlay(AppColor.ink.opacity(0.08))
                optionRow("trash", "delete".localized, tint: Color(hex: 0xFF8A80)) { showOptions = false; showDelete = true }
            }
            .glassPanel(28)

            Button { showOptions = false } label: {
                Text("cancel".localized).font(.system(size: 15, weight: .medium)).foregroundStyle(AppColor.ink)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(AppColor.ink.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(PressableStyle())
        }
        .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BlobBackground())
        .presentationDetents([.height(360)])
        .presentationDragIndicator(.visible)
    }

    private func optionRow(_ icon: String, _ title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.system(size: 18, weight: .regular)).foregroundStyle(tint).frame(width: 22)
                Text(title).font(.system(size: 16, weight: .medium)).foregroundStyle(tint)
                Spacer()
            }
            .padding(.horizontal, 16).frame(height: 56).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Actions

    private func download() {
        guard let after else { return }
        PhotoTools.saveToPhotos(after)
        showToast("saved_to_photos".localized)
    }

    private func performDelete() {
        showDelete = false
        if let look { LookStore.shared.delete(look) }
        app.navi.pop()
    }

    private func showToast(_ text: String) {
        toast = text
        Task { try? await Task.sleep(nanoseconds: 1_800_000_000); await MainActor.run { toast = nil } }
    }
}
