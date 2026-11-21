//
//  FavoritesScreen.swift  (My look tab)
//  HomeDecor
//
//  Saved designs. Empty state (Figma Gallery Empty) when there are no looks;
//  otherwise a 2-column gallery. Tapping a look opens Gallery Detail; the select
//  button enters Select Mode (10:26283) for multi Share / Download / Delete,
//  with a loading skeleton and Downloaded / Deleted toasts.
//

import SwiftUI
import Factory

struct FavoritesScreen: View {
    @InjectedObject(\.app) private var app
    @Injected(\.myLook) private var store: MyLookStore

    @State private var looks: [LookStore.Look] = []
    @State private var loading = true
    @State private var selectMode = false
    @State private var selected = Set<String>()
    @State private var showDeleteSelected = false
    @State private var showShare = false
    @State private var shareImages: [UIImage] = []
    @State private var toast: String?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack(alignment: .top) {
            BlobBackground()

            if loading {
                skeleton
            } else if looks.isEmpty {
                emptyState
            } else {
                grid
            }

            header

            if selectMode { selectActionBar }

            if let toast {
                ToastView(icon: "checkmark.circle.fill", text: toast)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 130)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectMode)
        .animation(.easeInOut(duration: 0.2), value: toast)
        .overlay {
            if showDeleteSelected {
                CoralPopup(
                    icon: "trash.fill", badge: "xmark",
                    title: String(format: "delete_selected_title".localized, selected.count),
                    message: "delete_selected_message".localized,
                    primaryTitle: "cancel".localized, primaryAction: { showDeleteSelected = false },
                    secondaryTitle: "delete".localized, secondaryAction: { deleteSelected() })
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showDeleteSelected)
        .sheet(isPresented: $showShare) { ActivityView(items: shareImages) }
        .onAppear { reload() }
        .onChange(of: app.activeTab) { if $0 == .mylook { reload() } else { selectMode = false } }
        .onChange(of: selectMode) { app.hideShellChrome = $0 }
        .trackScreen(.mylook)
    }

    private func reload() {
        loading = true
        looks = LookStore.shared.all()
        loading = false
    }

    // MARK: Header

    private var header: some View {
        Group {
            if selectMode {
                ZStack {
                    Text(String(format: "n_selected".localized, selected.count))
                        .font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
                    HStack {
                        Button { exitSelect() } label: {
                            Image(systemName: "xmark").font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AppColor.ink).frame(width: 44, height: 44).glassButton()
                        }
                        .buttonStyle(PressableStyle())
                        Spacer()
                        Button {
                            selected = selected.count == looks.count ? [] : Set(looks.map(\.id))
                        } label: {
                            Text("all".localized).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColor.coral)
                                .frame(height: 44)
                        }
                    }
                }
            } else {
                ZStack {
                    Text("gallery".localized)
                        .font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
                    if !looks.isEmpty {
                        HStack {
                            Spacer()
                            Button { selectMode = true } label: {
                                Image(systemName: "checkmark.circle").font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(AppColor.ink).frame(width: 44, height: 44).glassButton()
                            }
                            .buttonStyle(PressableStyle())
                        }
                    }
                }
            }
        }
        .frame(height: 44).padding(.horizontal, 20).padding(.top, 8)
    }

    // MARK: Grid

    private var grid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(looks) { look in
                    cell(look)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 62)
            .padding(.bottom, selectMode ? 170 : 130)
        }
    }

    private func cell(_ look: LookStore.Look) -> some View {
        let isSel = selected.contains(look.id)
        return Button {
            if selectMode {
                if isSel { selected.remove(look.id) } else { selected.insert(look.id) }
            } else {
                store.detail = look
                app.navi.push(.galleryDetail)
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                Color.clear.frame(height: 215)
                    .overlay(
                        Group { if let img = LookStore.shared.image(for: look) { Image(uiImage: img).resizable().scaledToFill() } }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(isSel ? AppColor.coral : AppColor.ink.opacity(0.12), lineWidth: isSel ? 2 : 1))
                if selectMode {
                    Group {
                        if isSel {
                            Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundStyle(.white)
                                .frame(width: 26, height: 26).background(AppColor.coral, in: Circle())
                        } else {
                            Circle().fill(.ultraThinMaterial).frame(width: 26, height: 26)
                                .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: 1))
                        }
                    }
                    .padding(9)
                }
            }
        }
        .buttonStyle(PressableStyle())
        .simultaneousGesture(LongPressGesture().onEnded { _ in
            if !selectMode { selectMode = true; selected = [look.id] }
        })
    }

    // MARK: Select action bar

    private var selectActionBar: some View {
        HStack(spacing: 0) {
            barAction("square.and.arrow.up", "share_action".localized, tint: AppColor.ink, enabled: !selected.isEmpty) { shareSelected() }
            barAction("square.and.arrow.down", "download".localized, tint: AppColor.ink, enabled: !selected.isEmpty) { downloadSelected() }
            barAction("trash", "delete".localized, tint: Color(hex: 0xFF8A80), enabled: !selected.isEmpty) { showDeleteSelected = true }
        }
        .padding(.horizontal, 16)
        .frame(height: 72)
        .frame(maxWidth: .infinity)
        .glassPanel(36)
        .padding(.horizontal, 20)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 34)
    }

    private func barAction(_ icon: String, _ title: String, tint: Color, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 20, weight: .regular))
                Text(title).font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .opacity(enabled ? 1 : 0.4)
        }
        .buttonStyle(PressableStyle())
        .disabled(!enabled)
    }

    // MARK: Select actions

    private func exitSelect() { selectMode = false; selected = [] }

    private func selectedLooks() -> [LookStore.Look] { looks.filter { selected.contains($0.id) } }

    private func shareSelected() {
        shareImages = selectedLooks().compactMap { LookStore.shared.image(for: $0) }
        if !shareImages.isEmpty { showShare = true }
    }

    private func downloadSelected() {
        for look in selectedLooks() { if let img = LookStore.shared.image(for: look) { PhotoTools.saveToPhotos(img) } }
        showToast(String(format: "saved_n_to_photos".localized, selected.count))
        exitSelect()
    }

    private func deleteSelected() {
        showDeleteSelected = false
        LookStore.shared.delete(ids: Array(selected))
        exitSelect()
        reload()
        showToast("deleted_toast".localized)
    }

    private func showToast(_ text: String) {
        toast = text
        Task { try? await Task.sleep(nanoseconds: 1_800_000_000); await MainActor.run { toast = nil } }
    }

    // MARK: Empty + skeleton

    private var emptyState: some View {
        VStack {
            VStack(spacing: 16) {
                HStack(spacing: -24) {
                    preview("gallery_empty_1", angle: -6)
                    preview("gallery_empty_2", angle: 6)
                }
                .padding(.vertical, 10)
                VStack(spacing: 6) {
                    Text("empty_title".localized)
                        .font(.system(size: 22, weight: .bold)).tracking(-0.4).foregroundStyle(AppColor.ink)
                    Text("empty_subtitle".localized)
                        .font(.system(size: 14)).foregroundStyle(AppColor.inkSecondary)
                        .multilineTextAlignment(.center).frame(width: 260)
                }
                Button { app.activeTab = .create } label: {
                    HStack {
                        Text("start_transform".localized)
                            .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "arrow.up.right").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                            .frame(width: 44, height: 44).background(AppColor.coral, in: RoundedRectangle(cornerRadius: 22))
                    }
                    .padding(.leading, 22).padding(.trailing, 6)
                    .frame(height: 56)
                    .background(AppColor.ink, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableStyle())
            }
            .padding(.top, 24).padding(.bottom, 20).padding(.horizontal, 20)
            .glassPanel(32)
            .padding(.horizontal, 20)
            .padding(.top, 138)
            Spacer()
        }
    }

    private func preview(_ image: String, angle: Double) -> some View {
        Image(image).resizable().scaledToFill()
            .frame(width: 130, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(.white, lineWidth: 4))
            .rotationEffect(.degrees(angle))
            .shadow(color: Color(hex: 0x4D331A).opacity(0.14), radius: 10, x: 0, y: 10)
    }

    private var skeleton: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<6, id: \.self) { _ in
                    ShimmerBox().frame(height: 215).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
            .padding(.horizontal, 20).padding(.top, 62)
        }
    }
}
