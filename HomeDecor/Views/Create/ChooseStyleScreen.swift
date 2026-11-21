//
//  ChooseStyleScreen.swift
//  HomeDecor
//
//  Create flow — Choose Style (Figma 12:33654 / Outside 12:35537). The user's
//  photo + a "Change photo" chip, an Inside/Outside segmented control, room-type
//  chips, a wrapping style grid (selected = coral border + check), and the
//  Generate CTA which starts the AI render.
//

import SwiftUI
import Factory

struct ChooseStyleScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.createSession) private var session: CreateSession

    @State private var roomType = "Living room"

    private let roomTypes = ["Living room", "Bedroom", "Bathroom", "Kitchen", "Office"]

    /// Style options: the incoming style first, then a sample set (dedup by id).
    private var styles: [CreateStyle] {
        let samples: [CreateStyle] = [
            .init(image: "cat_warm_minimal", name: "Warm Minimal", category: roomType),
            .init(image: "cat_earthy_loft", name: "Earthy Loft", category: roomType),
            .init(image: "cat_sunlit", name: "Sunlit", category: roomType),
            .init(image: "cat_boho", name: "Boho", category: roomType),
            .init(image: "cat_enchanted", name: "Enchanted", category: roomType),
            .init(image: "cat_neon_night", name: "Neon Night", category: roomType),
        ]
        var all = session.style.map { [$0] } ?? []
        for s in samples where !all.contains(where: { $0.id == s.id }) { all.append(s) }
        return all
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        VStack(spacing: 0) {
            CreateHeader(title: "choose_style".localized, onBack: { app.navi.pop() })

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    yourPhoto
                    segmented
                    roomTypeSection
                    styleSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            FlowCTAButton(title: "generate".localized, systemIcon: "sparkles",
                          enabled: session.sourcePhoto != nil && session.style != nil) {
                app.navi.push(.generating)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 34)
        }
        .background(BlobBackground().ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { session.roomType = roomType }
    }

    // MARK: Your photo

    @ViewBuilder
    private var yourPhoto: some View {
        if let photo = session.sourcePhoto {
            FilledPhoto(image: photo, height: 180, cornerRadius: 20)
                .overlay(alignment: .topTrailing) {
                    Button { app.navi.pop() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 12, weight: .semibold))
                            Text("change_photo".localized).font(.system(size: 12, weight: .medium))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12).frame(height: 30)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().strokeBorder(.white.opacity(0.5), lineWidth: 1))
                    }
                    .buttonStyle(PressableStyle())
                    .padding(12)
                }
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(AppColor.ink.opacity(0.12), lineWidth: 1))
        }
    }

    // MARK: Segmented Inside/Outside

    private var segmented: some View {
        HStack(spacing: 8) {
            segItem("outside".localized, icon: "house", active: session.isOutside) { session.isOutside = true }
            segItem("inside".localized, icon: "sofa", active: !session.isOutside) { session.isOutside = false }
        }
        .padding(4)
        .frame(height: 48)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(.white.opacity(0.8), lineWidth: 1))
    }

    private func segItem(_ title: String, icon: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 15, weight: active ? .semibold : .regular))
                Text(title).font(.system(size: 15, weight: active ? .semibold : .medium))
            }
            .foregroundStyle(active ? .white : AppColor.inkSecondary)
            .frame(maxWidth: .infinity).frame(height: 40)
            .background(active ? AppColor.ink : Color.clear, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Room type

    private var roomTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("room_type".localized).font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(roomTypes, id: \.self) { room in
                        Button { roomType = room; session.roomType = room } label: {
                            Text(room)
                                .font(.system(size: 13, weight: roomType == room ? .semibold : .medium))
                                .foregroundStyle(roomType == room ? AppColor.coral : AppColor.ink)
                                .padding(.horizontal, 14).frame(height: 32)
                                .glassPanel(16)
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
            }
        }
    }

    // MARK: Style grid

    private var styleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("style".localized).font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(styles) { style in
                    styleCell(style)
                }
            }
        }
    }

    private func styleCell(_ style: CreateStyle) -> some View {
        let selected = session.style?.id == style.id
        return Button { session.select(style) } label: {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Color.clear.frame(height: 104)
                        .overlay(Image(style.image).resizable().scaledToFill())
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(selected ? AppColor.coral : AppColor.ink.opacity(0.12),
                                          lineWidth: selected ? 2 : 1))
                    if selected {
                        Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(AppColor.coral, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                            .padding(8)
                    }
                }
                Text(style.name)
                    .font(.system(size: 13, weight: selected ? .semibold : .medium))
                    .foregroundStyle(selected ? AppColor.coral : AppColor.ink.opacity(0.8))
                    .lineLimit(1)
            }
        }
        .buttonStyle(PressableStyle())
    }
}
