//
//  InspirationCatalog.swift
//  HomeDecor
//
//  Sample catalog for the Inspiration tab (Phase 5). Grouped Outside/Inside;
//  wire to `artMagic.categories/templates` once Code12 credentials arrive.
//  `InspirationStore` carries the list a pushed See-All / Image-Preview screen
//  should show (the router destinations take no params).
//

import SwiftUI
import Factory

struct InspirationCategory: Identifiable {
    let id = UUID()
    let title: String
    let isOutside: Bool
    let styles: [CreateStyle]
}

enum InspirationCatalog {
    private static func s(_ image: String, _ name: String, _ cat: String) -> CreateStyle {
        CreateStyle(image: image, name: name, category: cat)
    }

    static let categories: [InspirationCategory] = [
        .init(title: "Modern Outside", isOutside: true, styles: [
            s("cat_snow_cozy", "Snow Cozy", "Modern Outside"),
            s("cat_garden_view", "Garden View", "Modern Outside"),
            s("cat_hillside", "Hillside", "Modern Outside"),
            s("cat_lake_house", "Lake House", "Modern Outside"),
        ]),
        .init(title: "Fantasy style", isOutside: true, styles: [
            s("cat_enchanted", "Enchanted", "Fantasy style"),
            s("cat_mossy_hall", "Mossy Hall", "Fantasy style"),
            s("cat_starlit", "Starlit", "Fantasy style"),
            s("cat_misty_vale", "Misty Vale", "Fantasy style"),
        ]),
        .init(title: "Anime style", isOutside: true, styles: [
            s("cat_sakura_room", "Sakura Room", "Anime style"),
            s("cat_studio_sky", "Studio Sky", "Anime style"),
            s("cat_neon_soft", "Neon Soft", "Anime style"),
            s("cat_cel_shade", "Cel Shade", "Anime style"),
        ]),
        .init(title: "Cyberpunk bedroom", isOutside: true, styles: [
            s("cat_neon_night", "Neon Night", "Cyberpunk bedroom"),
            s("cat_synth_loft", "Synth Loft", "Cyberpunk bedroom"),
            s("cat_holo_den", "Holo Den", "Cyberpunk bedroom"),
            s("cat_grid_city", "Grid City", "Cyberpunk bedroom"),
        ]),
        .init(title: "Isometric room", isOutside: true, styles: [
            s("cat_tiny_studio", "Tiny Studio", "Isometric room"),
            s("cat_mini_loft", "Mini Loft", "Isometric room"),
            s("cat_cube_home", "Cube Home", "Isometric room"),
            s("cat_pastel_box", "Pastel Box", "Isometric room"),
        ]),
        .init(title: "Living room", isOutside: false, styles: [
            s("cat_warm_minimal", "Warm Minimal", "Living room"),
            s("cat_earthy_loft", "Earthy Loft", "Living room"),
            s("cat_sunlit", "Sunlit", "Living room"),
            s("cat_boho", "Boho", "Living room"),
        ]),
        .init(title: "Bedroom", isOutside: false, styles: [
            s("cat_linen_calm", "Linen Calm", "Bedroom"),
            s("cat_soft_neutral", "Soft Neutral", "Bedroom"),
            s("cat_cozy_nook", "Cozy Nook", "Bedroom"),
            s("cat_terra_suite", "Terra Suite", "Bedroom"),
        ]),
        .init(title: "Bathroom", isOutside: false, styles: [
            s("cat_spa_stone", "Spa Stone", "Bathroom"),
            s("cat_clean_lines", "Clean Lines", "Bathroom"),
            s("cat_marble", "Marble", "Bathroom"),
            s("cat_greenery", "Greenery", "Bathroom"),
        ]),
        .init(title: "Kitchen", isOutside: false, styles: [
            s("cat_oak_island", "Oak Island", "Kitchen"),
            s("cat_bright_cook", "Bright Cook", "Kitchen"),
            s("cat_rustic", "Rustic", "Kitchen"),
            s("cat_modern_chef", "Modern Chef", "Kitchen"),
        ]),
    ]

    static func sections(outside: Bool) -> [InspirationCategory] {
        categories.filter { $0.isOutside == outside }
    }
}

@MainActor
final class InspirationStore: ObservableObject {
    @Published var browseStyles: [CreateStyle] = []
    @Published var browseTitle: String = ""
    @Published var previewStart: Int = 0
}

extension Container {
    var inspiration: Factory<InspirationStore> {
        Factory(self) { @MainActor in InspirationStore() }.singleton
    }
}
