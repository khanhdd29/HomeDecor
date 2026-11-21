//
//  FavoritesScreen.swift  (My look tab)
//  HomeDecor
//
//  Saved designs ("My look"). Matches Figma Gallery Empty (10:3609) when there
//  are no saved looks; shows a 2-column grid of saved looks otherwise.
//

import SwiftUI
import Factory

struct FavoritesScreen: View {
    @Injected(\.app) private var app
    @State private var looks: [LookStore.Look] = []

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack(alignment: .top) {
            BlobBackground()

            if looks.isEmpty {
                emptyState
            } else {
                grid
            }

            header
        }
        .onAppear { looks = LookStore.shared.all() }
        .trackScreen(.mylook)
    }

    private var header: some View {
        ZStack {
            Text("gallery".localized)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColor.ink)
            HStack {
                Color.clear.frame(width: 44, height: 44)
                Spacer()
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppColor.ink)
                    .frame(width: 44, height: 44)
                    .glassButton()
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: Empty

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
                        .font(.system(size: 22, weight: .bold)).tracking(-0.4)
                        .foregroundStyle(AppColor.ink)
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
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).strokeBorder(.white.opacity(0.75), lineWidth: 1))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 8)
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

    // MARK: Grid

    private var grid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(looks) { look in
                    if let img = LookStore.shared.image(for: look) {
                        Image(uiImage: img).resizable().scaledToFill()
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 114)
            .padding(.bottom, 130)
        }
    }
}
