//
//  SearchScreen.swift  (Inspiration tab)
//  HomeDecor
//
//  Category browser — Figma 10:25576 (Inside) / 10:25180 (Loading). "Category"
//  header + Outside/Inside segmented control + per-category rails (each with a
//  See-All arrow). Tapping a style opens Style Detail; the arrow opens
//  Category — See All. Sample data for now (InspirationCatalog); wire to
//  `artMagic.categories/templates` with credentials.
//

import SwiftUI
import Factory

struct SearchScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.createSession) private var session: CreateSession
    @Injected(\.inspiration) private var store: InspirationStore

    @State private var isOutside = true
    @State private var loading = true

    private var sections: [InspirationCategory] { InspirationCatalog.sections(outside: isOutside) }

    var body: some View {
        ZStack(alignment: .top) {
            BlobBackground()

            VStack(spacing: 0) {
                header
                segmented
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 8)

                if loading {
                    skeleton
                } else {
                    content
                }
            }
            .padding(.top, 50)
        }
        .trackScreen(.inspiration)
        .task {
            loading = true
            try? await Task.sleep(nanoseconds: 650_000_000)
            loading = false
        }
    }

    // MARK: Header

    private var header: some View {
        Text("category".localized)
            .font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
            .frame(height: 44).frame(maxWidth: .infinity)
            .padding(.top, 8)
    }

    // MARK: Segmented

    private var segmented: some View {
        HStack(spacing: 10) {
            segItem("outside".localized, icon: "house", active: isOutside) { isOutside = true }
            segItem("inside".localized, icon: "sofa", active: !isOutside) { isOutside = false }
        }
    }

    private func segItem(_ title: String, icon: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 15, weight: active ? .semibold : .regular))
                Text(title).font(.system(size: 15, weight: active ? .semibold : .medium))
            }
            .foregroundStyle(active ? AppColor.coral : AppColor.inkSecondary)
            .frame(maxWidth: .infinity).frame(height: 40)
            .background(active ? Color(hex: 0xEAE8E6).opacity(0.9) : AppColor.ink.opacity(0.07),
                       in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(active ? AppColor.coral : AppColor.ink.opacity(0.12), lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Content

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                ForEach(sections) { section in
                    sectionView(section)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 130)
        }
    }

    private func sectionView(_ section: InspirationCategory) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(section.title)
                    .font(.system(size: 21, weight: .bold)).tracking(-0.3)
                    .foregroundStyle(AppColor.ink)
                Spacer()
                Button {
                    store.browseStyles = section.styles
                    store.browseTitle = section.title
                    app.navi.push(.categorySeeAll)
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(AppColor.coral)
                        .frame(width: 34, height: 34)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(AppColor.coral, lineWidth: 1))
                }
                .buttonStyle(PressableStyle())
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(section.styles) { style in
                        card(style, in: section.styles)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }
        }
    }

    private func card(_ style: CreateStyle, in styles: [CreateStyle]) -> some View {
        Button {
            session.start(style, in: styles)
            app.navi.push(.styleDetail)
        } label: {
            ZStack(alignment: .bottomLeading) {
                Image(style.image).resizable().scaledToFill().frame(width: 156, height: 200)
                LinearGradient(colors: [.clear, .black.opacity(0.62)], startPoint: .center, endPoint: .bottom)
                Text(style.name).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white).padding(11)
            }
            .frame(width: 156, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(AppColor.ink.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(PressableStyle())
    }

    // MARK: Loading skeleton

    private var skeleton: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            shimmer.frame(width: 150, height: 20).clipShape(RoundedRectangle(cornerRadius: 8))
                            Spacer()
                            shimmer.frame(width: 34, height: 34).clipShape(RoundedRectangle(cornerRadius: 17))
                        }
                        .padding(.horizontal, 20)
                        HStack(spacing: 10) {
                            ForEach(0..<3, id: \.self) { _ in
                                shimmer.frame(width: 156, height: 200).clipShape(RoundedRectangle(cornerRadius: 22))
                            }
                        }
                        .padding(.leading, 20)
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    private var shimmer: some View {
        ShimmerBox()
    }
}

/// Soft shimmering placeholder used by the loading skeleton.
private struct ShimmerBox: View {
    @State private var phase: CGFloat = -1
    var body: some View {
        Rectangle()
            .fill(Color(hex: 0xDDD8D4))
            .overlay(
                LinearGradient(colors: [.clear, Color(hex: 0xEAE8E6).opacity(0.9), .clear],
                               startPoint: .leading, endPoint: .trailing)
                    .scaleEffect(x: 0.5, y: 1, anchor: .leading)
                    .offset(x: phase * 400)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) { phase = 1.5 }
            }
    }
}
