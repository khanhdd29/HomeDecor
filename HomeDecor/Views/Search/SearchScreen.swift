//
//  SearchScreen.swift  (Inspiration tab)
//  HomeDecor
//
//  Category browser — matches Figma node 10:2689. "Category" header +
//  Outside/Inside segmented control + big style-card sections.
//  Sample data for now; wire to `artMagic.categories/templates` with credentials.
//

import SwiftUI

private struct CatCard: Identifiable {
    let id = UUID()
    let image: String
    let title: String
}

private struct CatSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [CatCard]
}

private let categorySections: [CatSection] = [
    .init(title: "Modern Outside", items: [
        .init(image: "cat_snow_cozy", title: "Snow Cozy"),
        .init(image: "cat_garden_view", title: "Garden View"),
        .init(image: "cat_hillside", title: "Hillside"),
        .init(image: "cat_lake_house", title: "Lake House"),
    ]),
    .init(title: "Living room", items: [
        .init(image: "cat_warm_minimal", title: "Warm Minimal"),
        .init(image: "cat_earthy_loft", title: "Earthy Loft"),
        .init(image: "cat_sunlit", title: "Sunlit"),
        .init(image: "cat_boho", title: "Boho"),
    ]),
    .init(title: "Bedroom", items: [
        .init(image: "cat_linen_calm", title: "Linen Calm"),
        .init(image: "cat_soft_neutral", title: "Soft Neutral"),
        .init(image: "cat_cozy_nook", title: "Cozy Nook"),
        .init(image: "cat_terra_suite", title: "Terra Suite"),
    ]),
    .init(title: "Bathroom", items: [
        .init(image: "cat_spa_stone", title: "Spa Stone"),
        .init(image: "cat_clean_lines", title: "Clean Lines"),
        .init(image: "cat_marble", title: "Marble"),
        .init(image: "cat_greenery", title: "Greenery"),
    ]),
    .init(title: "Kitchen", items: [
        .init(image: "cat_oak_island", title: "Oak Island"),
        .init(image: "cat_bright_cook", title: "Bright Cook"),
        .init(image: "cat_rustic", title: "Rustic"),
        .init(image: "cat_modern_chef", title: "Modern Chef"),
    ]),
    .init(title: "Fantasy style", items: [
        .init(image: "cat_enchanted", title: "Enchanted"),
        .init(image: "cat_mossy_hall", title: "Mossy Hall"),
        .init(image: "cat_starlit", title: "Starlit"),
        .init(image: "cat_misty_vale", title: "Misty Vale"),
    ]),
    .init(title: "Anime style", items: [
        .init(image: "cat_sakura_room", title: "Sakura Room"),
        .init(image: "cat_studio_sky", title: "Studio Sky"),
        .init(image: "cat_neon_soft", title: "Neon Soft"),
        .init(image: "cat_cel_shade", title: "Cel Shade"),
    ]),
    .init(title: "Cyberpunk bedroom", items: [
        .init(image: "cat_neon_night", title: "Neon Night"),
        .init(image: "cat_synth_loft", title: "Synth Loft"),
        .init(image: "cat_holo_den", title: "Holo Den"),
        .init(image: "cat_grid_city", title: "Grid City"),
    ]),
    .init(title: "Isometric room", items: [
        .init(image: "cat_tiny_studio", title: "Tiny Studio"),
        .init(image: "cat_mini_loft", title: "Mini Loft"),
        .init(image: "cat_cube_home", title: "Cube Home"),
        .init(image: "cat_pastel_box", title: "Pastel Box"),
    ]),
]

struct SearchScreen: View {
    @State private var isOutside = true

    var body: some View {
        ZStack(alignment: .top) {
            BlobBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    segmented
                        .padding(.horizontal, 20)

                    ForEach(categorySections) { section in
                        sectionView(section)
                    }
                }
                .padding(.top, 110)
                .padding(.bottom, 130)
            }

            header
        }
        .trackScreen(.inspiration)
    }

    private var header: some View {
        Text("category".localized)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(AppColor.ink)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }

    private var segmented: some View {
        HStack(spacing: 4) {
            segItem("outside".localized, active: isOutside) { isOutside = true }
            segItem("inside".localized, active: !isOutside) { isOutside = false }
        }
        .padding(4)
        .frame(height: 52)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(.white.opacity(0.75), lineWidth: 1))
    }

    private func segItem(_ title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(active ? .white : AppColor.inkSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(active ? AppColor.ink : Color.clear,
                           in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func sectionView(_ section: CatSection) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(section.title).font(.system(size: 20, weight: .semibold)).tracking(-0.4)
                    .foregroundStyle(AppColor.ink)
                Spacer()
                Text("show_all".localized).font(.system(size: 14)).foregroundStyle(AppColor.inkSecondary)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(section.items) { item in
                        card(item)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            }
        }
    }

    private func card(_ item: CatCard) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image(item.image).resizable().scaledToFill().frame(width: 156, height: 200)
            LinearGradient(colors: [.clear, Color(hex: 0x140F0D).opacity(0.55)],
                           startPoint: .center, endPoint: .bottom)
            Text(item.title).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white).padding(14)
        }
        .frame(width: 156, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
