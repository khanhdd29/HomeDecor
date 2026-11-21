//
//  UploadPhotoScreen.swift
//  HomeDecor
//
//  Create flow — Upload Photo (Figma 12:33259, + Selected 12:35348 / No Style
//  12:37079). Selected-style card, a dashed upload area (shows the picked photo
//  once chosen), photo tips, and the Continue CTA (enabled once a photo exists).
//  "Add a photo" sheet (12:33443) picks the source: Photo library uses the
//  system PHPicker (no permission prompt); Take photo uses the camera.
//

import SwiftUI
import Factory
import PhotosUI

struct UploadPhotoScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.createSession) private var session: CreateSession

    @State private var showAddPhoto = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var wantCamera = false
    @State private var showChangeStyle = false
    @State private var tempStyle: CreateStyle?
    @State private var showPhotoQuality = false

    var body: some View {
        VStack(spacing: 0) {
            CreateHeader(title: "upload_photo".localized, onBack: { app.navi.pop() })

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    selectedStyleCard
                    uploadArea
                    tipsCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            FlowCTAButton(title: "continue".localized, enabled: session.sourcePhoto != nil) {
                if let p = session.sourcePhoto, PhotoTools.isTooDark(p) {
                    showPhotoQuality = true
                } else {
                    app.navi.push(.chooseStyle)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 34)
        }
        .background(BlobBackground().ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if showPhotoQuality {
                CoralPopup(
                    icon: "exclamationmark.triangle.fill", badge: "sun.max.fill",
                    title: "photo_quality_title".localized, message: "photo_quality_message".localized,
                    primaryTitle: "choose_another".localized,
                    primaryAction: { showPhotoQuality = false; showAddPhoto = true },
                    secondaryTitle: "use_anyway".localized,
                    secondaryAction: { showPhotoQuality = false; app.navi.push(.chooseStyle) })
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showPhotoQuality)
        .sheet(isPresented: $showAddPhoto) { addPhotoSheet }
        .sheet(isPresented: $showChangeStyle) { changeStyleSheet }
        .fullScreenCover(isPresented: $showCamera) {
            SystemCameraPicker { session.sourcePhoto = $0 }
                .ignoresSafeArea()
        }
        .onChange(of: pickerItem) { load($0) }
        .onChange(of: showAddPhoto) { open in
            if !open && wantCamera {
                wantCamera = false
                if SystemCameraPicker.isAvailable { showCamera = true }
            }
        }
    }

    // MARK: Selected style

    @ViewBuilder
    private var selectedStyleCard: some View {
        if let style = session.style {
            HStack(spacing: 12) {
                Image(style.image).resizable().scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text("selected_style".localized)
                        .font(.system(size: 12, weight: .medium)).foregroundStyle(AppColor.inkSecondary)
                    Text(style.name)
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColor.ink)
                }
                Spacer()
                Button { tempStyle = session.style; showChangeStyle = true } label: {
                    Text("change".localized)
                        .font(.system(size: 14, weight: .semibold)).foregroundStyle(AppColor.coral)
                }
            }
            .padding(.leading, 10).padding(.trailing, 14).padding(.vertical, 10)
            .glassPanel(24)
        } else {
            Button { app.navi.push(.chooseStyle) } label: {
                HStack(spacing: 12) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 18, weight: .medium)).foregroundStyle(AppColor.coral)
                        .frame(width: 44, height: 44)
                        .background(AppColor.coral.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("no_style_title".localized)
                            .font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColor.ink)
                        Text("no_style_sub".localized)
                            .font(.system(size: 12)).foregroundStyle(AppColor.inkSecondary)
                    }
                    Spacer()
                    Text("choose_style".localized)
                        .font(.system(size: 14, weight: .semibold)).foregroundStyle(AppColor.coral)
                }
                .padding(.leading, 10).padding(.trailing, 14).padding(.vertical, 10)
                .glassPanel(24)
            }
            .buttonStyle(PressableStyle())
        }
    }

    // MARK: Upload area

    private var uploadArea: some View {
        Button { showAddPhoto = true } label: {
            Group {
                if let photo = session.sourcePhoto {
                    FilledPhoto(image: photo, height: 300, cornerRadius: 28)
                        .overlay(alignment: .bottomTrailing) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 13, weight: .semibold))
                                Text("change_photo".localized).font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundStyle(AppColor.ink)
                            .padding(.horizontal, 12).frame(height: 36)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(Capsule().strokeBorder(.white.opacity(0.8), lineWidth: 1))
                            .padding(14)
                        }
                } else {
                    VStack(spacing: 14) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 26, weight: .regular)).foregroundStyle(AppColor.ink)
                            .frame(width: 68, height: 68)
                            .glassPanel(34)
                        Text("upload_room_title".localized)
                            .font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
                        Text("upload_room_subtitle".localized)
                            .font(.system(size: 13)).foregroundStyle(AppColor.inkSecondary)
                            .multilineTextAlignment(.center).frame(width: 260)
                    }
                    .frame(maxWidth: .infinity).frame(height: 300)
                    .glassPanel(28, dashed: true)
                }
            }
        }
        .buttonStyle(PressableStyle())
    }

    // MARK: Tips

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("tips_title".localized)
                .font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColor.ink)
            tip("tip_lighting".localized)
            tip("tip_whole_room".localized)
            tip("tip_no_people".localized)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassPanel(28)
    }

    private func tip(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .bold)).foregroundStyle(AppColor.coral)
                .frame(width: 22, height: 22)
                .background(AppColor.coral.opacity(0.16), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            Text(text).font(.system(size: 14)).foregroundStyle(AppColor.ink.opacity(0.8))
        }
    }

    // MARK: Add Photo sheet

    private var addPhotoSheet: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("add_photo".localized)
                    .font(.system(size: 19, weight: .bold)).foregroundStyle(AppColor.ink)
                Text("add_photo_subtitle".localized)
                    .font(.system(size: 13)).foregroundStyle(AppColor.inkSecondary)
            }
            .padding(.top, 8)

            HStack(spacing: 12) {
                // Take photo (custom camera comes in batch 2; temporary bridge for now).
                Button {
                    wantCamera = true
                    showAddPhoto = false
                } label: {
                    optionCard(icon: "camera", title: "take_photo".localized, sub: "take_photo_sub".localized)
                }
                .buttonStyle(PressableStyle())

                // Photo library — system PHPicker, no permission prompt.
                PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                    optionCard(icon: "photo", title: "photo_library".localized, sub: "photo_library_sub".localized)
                }
                .buttonStyle(PressableStyle())
            }

            Button { showAddPhoto = false } label: {
                Text("cancel".localized)
                    .font(.system(size: 15, weight: .medium)).foregroundStyle(AppColor.ink)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(AppColor.ink.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(PressableStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BlobBackground())
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.visible)
    }

    private func optionCard(icon: String, title: String, sub: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .regular)).foregroundStyle(AppColor.coral)
                .frame(width: 48, height: 48)
                .glassPanel(24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColor.ink)
                Text(sub).font(.system(size: 12)).foregroundStyle(AppColor.inkSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16).padding(.vertical, 18)
        .glassPanel(28)
    }

    // MARK: Change Style sheet

    private var styleOptions: [CreateStyle] {
        let cat = session.style?.category ?? ""
        let base: [CreateStyle] = [
            .init(image: "cat_snow_cozy", name: "Snow Cozy", category: cat),
            .init(image: "cat_warm_minimal", name: "Warm Minimal", category: cat),
            .init(image: "cat_earthy_loft", name: "Earthy Loft", category: cat),
            .init(image: "cat_linen_calm", name: "Linen Calm", category: cat),
            .init(image: "cat_spa_stone", name: "Spa Stone", category: cat),
            .init(image: "cat_oak_island", name: "Oak Island", category: cat),
        ]
        var all = session.style.map { [$0] } ?? []
        for s in base where !all.contains(where: { $0.id == s.id }) { all.append(s) }
        return all
    }

    private var changeStyleSheet: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
        return VStack(spacing: 16) {
            Text("choose_a_style".localized)
                .font(.system(size: 19, weight: .bold)).foregroundStyle(AppColor.ink)
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(styleOptions) { style in
                        let selected = tempStyle?.id == style.id
                        Button { tempStyle = style } label: {
                            VStack(spacing: 6) {
                                Color.clear.frame(height: 96)
                                    .overlay(Image(style.image).resizable().scaledToFill())
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(selected ? AppColor.coral : AppColor.ink.opacity(0.12),
                                                      lineWidth: selected ? 2 : 1))
                                Text(style.name)
                                    .font(.system(size: 13, weight: selected ? .semibold : .medium))
                                    .foregroundStyle(selected ? AppColor.coral : AppColor.ink.opacity(0.8))
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
            }

            Button {
                if let t = tempStyle { session.select(t) }
                showChangeStyle = false
            } label: {
                Text("apply_style".localized)
                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(AppColor.ink, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            }
            .buttonStyle(PressableStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BlobBackground())
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: Picker load

    private func load(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                let normalized = PhotoTools.normalized(image)
                await MainActor.run {
                    session.sourcePhoto = normalized
                    pickerItem = nil
                    showAddPhoto = false
                }
            }
        }
    }
}
