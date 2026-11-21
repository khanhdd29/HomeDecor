//
//  HomeScreen.swift
//  HomeDecor
//
//  Create tab — matches Figma node 10:2386. Header + Before/After hero +
//  horizontally-scrolling catalog sections (big style cards + "Try style"
//  trend cards). Content is sample data for now; wire to `artMagic.sections()`
//  once Code12 credentials arrive.
//

import SwiftUI
import Factory

// MARK: - Sample catalog model

private struct StyleCard: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let category: String
}

private enum SectionLayout { case big, trend }

private struct CatalogSection: Identifiable {
    let id = UUID()
    let title: String
    let layout: SectionLayout
    let items: [StyleCard]
}

private let sampleSections: [CatalogSection] = [
    .init(title: "Modern Outside", layout: .big, items: [
        .init(image: "style_snow_cozy", title: "Snow Cozy", category: "Modern Outside"),
        .init(image: "style_garden_view", title: "Garden View", category: "Modern Outside"),
        .init(image: "style_hillside", title: "Hillside", category: "Modern Outside"),
    ]),
    .init(title: "Living room", layout: .trend, items: [
        .init(image: "thumb_warm_minimal", title: "Warm Minimal", category: "Living room"),
        .init(image: "thumb_earthy_loft", title: "Earthy Loft", category: "Living room"),
        .init(image: "thumb_sunlit", title: "Sunlit", category: "Living room"),
    ]),
    .init(title: "Bedroom", layout: .big, items: [
        .init(image: "style_linen_calm", title: "Linen Calm", category: "Bedroom"),
        .init(image: "style_soft_neutral", title: "Soft Neutral", category: "Bedroom"),
        .init(image: "style_cozy_nook", title: "Cozy Nook", category: "Bedroom"),
    ]),
    .init(title: "Bathroom", layout: .trend, items: [
        .init(image: "thumb_spa_stone", title: "Spa Stone", category: "Bathroom"),
        .init(image: "thumb_clean_lines", title: "Clean Lines", category: "Bathroom"),
        .init(image: "thumb_marble", title: "Marble", category: "Bathroom"),
    ]),
    .init(title: "Kitchen", layout: .big, items: [
        .init(image: "style_oak_island", title: "Oak Island", category: "Kitchen"),
        .init(image: "style_bright_cook", title: "Bright Cook", category: "Kitchen"),
        .init(image: "style_rustic", title: "Rustic", category: "Kitchen"),
    ]),
    .init(title: "Fantasy style", layout: .trend, items: [
        .init(image: "thumb_enchanted", title: "Enchanted", category: "Fantasy style"),
        .init(image: "thumb_mossy_hall", title: "Mossy Hall", category: "Fantasy style"),
        .init(image: "thumb_starlit", title: "Starlit", category: "Fantasy style"),
    ]),
    .init(title: "Anime style", layout: .big, items: [
        .init(image: "style_sakura_room", title: "Sakura Room", category: "Anime style"),
        .init(image: "style_studio_sky", title: "Studio Sky", category: "Anime style"),
        .init(image: "style_neo_tokyo", title: "Neo Tokyo", category: "Anime style"),
    ]),
    .init(title: "Cyberpunk bedroom", layout: .trend, items: [
        .init(image: "thumb_neon_night", title: "Neon Night", category: "Cyberpunk bedroom"),
        .init(image: "thumb_synth_loft", title: "Synth Loft", category: "Cyberpunk bedroom"),
        .init(image: "thumb_holo", title: "Holo", category: "Cyberpunk bedroom"),
    ]),
    .init(title: "Isometric room", layout: .big, items: [
        .init(image: "style_tiny_studio", title: "Tiny Studio", category: "Isometric room"),
        .init(image: "style_mini_loft", title: "Mini Loft", category: "Isometric room"),
        .init(image: "style_eco_cube", title: "Eco Cube", category: "Isometric room"),
    ]),
]

// MARK: - Screen

struct HomeScreen: View {
    @InjectedObject(\.appFlow) private var appFlow: AppFlowCoordinator

    var body: some View {
        ZStack(alignment: .top) {
            BlobBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    hero
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    ForEach(sampleSections) { section in
                        sectionView(section)
                    }
                }
                .padding(.top, 110)      // clear the fixed header
                .padding(.bottom, 130)   // clear the floating tab bar
            }

            AppHeader(onMenu: {}, onPro: {})
                .padding(.top, 8)
                .background(.clear)
        }
        .trackScreen(.create)
    }

    // MARK: Hero

    private var hero: some View {
        VStack(spacing: 12) {
            HeroCard()
            HStack(spacing: 5) {
                Capsule().fill(AppColor.coral).frame(width: 18, height: 6)
                Circle().fill(AppColor.ink.opacity(0.2)).frame(width: 6, height: 6)
                Circle().fill(AppColor.ink.opacity(0.2)).frame(width: 6, height: 6)
            }
        }
    }

    // MARK: Section

    @ViewBuilder
    private func sectionView(_ section: CatalogSection) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(section.title)
                    .font(.system(size: 20, weight: .semibold)).tracking(-0.4)
                    .foregroundStyle(AppColor.ink)
                Spacer()
                Text("show_all".localized)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColor.inkSecondary)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(section.items) { item in
                        switch section.layout {
                        case .big:   StyleBigCard(item: item)
                        case .trend: TrendCard(item: item)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            }
        }
    }
}

// MARK: - Hero card

private struct HeroCard: View {
    var body: some View {
        GeometryReader { geo in
            content(width: geo.size.width)
                .frame(width: geo.size.width, height: 380)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .shadow(color: Color(hex: 0x593326).opacity(0.14), radius: 16, x: 0, y: 16)
        }
        .frame(height: 380)
    }

    private func content(width w: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Image("hero_after").resizable().scaledToFill().frame(width: w, height: 380).clipped()
            Image("hero_before").resizable().scaledToFill().frame(width: w, height: 380).clipped()
                .mask(alignment: .leading) { Rectangle().frame(width: w * 0.5) }

            LinearGradient(colors: [.clear, Color(hex: 0x140F0D).opacity(0.62)],
                           startPoint: .center, endPoint: .bottom)

            Rectangle().fill(.white.opacity(0.9)).frame(width: 2)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("‹ ›")
                .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.75), lineWidth: 1))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            chip("Before", bg: Color.white.opacity(0.28)).padding(14)
            chip("After", bg: AppColor.coral)
                .frame(maxWidth: .infinity, alignment: .trailing).padding(14)

            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                HStack(spacing: 6) {
                    Text("✦").font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
                        .frame(width: 18, height: 18)
                        .background(.white.opacity(0.25), in: RoundedRectangle(cornerRadius: 9))
                    Text("ai_concepts".localized)
                        .font(.system(size: 13, weight: .medium)).foregroundStyle(.white.opacity(0.82))
                }
                HStack(alignment: .bottom) {
                    Text("reimagine_any_room".localized)
                        .font(.system(size: 30, weight: .bold)).tracking(-0.6)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    tryNowButton
                }
            }
            .padding(20)
        }
    }

    private func chip(_ text: String, bg: Color) -> some View {
        Text(text).font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(bg, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.5), lineWidth: bg == AppColor.coral ? 0 : 1))
    }

    private var tryNowButton: some View {
        HStack(spacing: 8) {
            Text("try_now".localized).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColor.ink)
            Image(systemName: "arrow.up.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                .frame(width: 32, height: 32).background(AppColor.coral, in: Circle())
        }
        .padding(.leading, 16).padding(.trailing, 6).padding(.vertical, 6)
        .background(Color.white.opacity(0.92), in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.75), lineWidth: 1))
    }
}

// MARK: - Catalog cards

private struct StyleBigCard: View {
    let item: StyleCard
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(item.image).resizable().scaledToFill()
                .frame(width: 156, height: 200)
            LinearGradient(colors: [.clear, Color(hex: 0x140F0D).opacity(0.55)],
                           startPoint: .center, endPoint: .bottom)
            Text(item.title)
                .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                .padding(14)
        }
        .frame(width: 156, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct TrendCard: View {
    let item: StyleCard
    var body: some View {
        HStack(spacing: 12) {
            Image(item.image).resizable().scaledToFill()
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.system(size: 16, weight: .semibold)).foregroundStyle(AppColor.ink)
                Text(item.category).font(.system(size: 12)).foregroundStyle(AppColor.inkSecondary)
                HStack(spacing: 4) {
                    Text("✦").font(.system(size: 11, weight: .bold))
                    Text("try_style".localized).font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(AppColor.coral)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 8).padding(.trailing, 16).padding(.vertical, 8)
        .frame(width: 250)
        .background(Color.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(hex: 0x4D3326).opacity(0.06), radius: 8, x: 0, y: 6)
    }
}
