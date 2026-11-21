//
//  AppColor.swift
//  HomeDecor
//
//  "Coral Glass" palette — single source of truth for app colors.
//  Values sampled from the Figma design (fileKey raklZjHgt1kEKJJEpsXyid).
//

import SwiftUI

enum AppColor {
    // MARK: Brand
    /// Primary accent — CTA, FAB, active tab, badges. (#EF5B3A)
    static let coral        = Color(hex: 0xEF5B3A)
    /// Pressed / darker coral.
    static let coralPressed = Color(hex: 0xD94E2F)
    /// Soft coral wash for tints and chips.
    static let coralTint    = Color(hex: 0xF7C9BC)

    /// Coral gradient endpoints (logo, splash progress, "Start" accents).
    static let coralGradTop = Color(hex: 0xFF9E78)
    static let coralGradBot = Color(hex: 0xE04229)

    // MARK: Ink (text + dark surfaces)
    /// Primary text / dark pill buttons. (#121212)
    static let ink          = Color(hex: 0x121212)
    /// Warm secondary text. (#6E6A66)
    static let inkSecondary = Color(hex: 0x6E6A66)
    /// Muted / tertiary text.
    static let inkTertiary  = Color(hex: 0x9A938D)

    static let onCoral      = Color.white
    static let onDark       = Color.white

    // MARK: Background
    /// Base canvas (#EAE8E6) — the peach warmth comes from the blobs on top.
    static let bgBase       = Color(hex: 0xEAE8E6)
    static let bgTop        = Color(hex: 0xF7E7DB)
    static let bgMid        = Color(hex: 0xF1DED2)
    static let bgBottom     = Color(hex: 0xECEAE8)

    // MARK: Glass surfaces
    static let glassFill    = Color.white.opacity(0.6)
    static let glassStroke  = Color.white.opacity(0.8)
    static let surface      = Color.white
    static let surfaceSoft  = Color(hex: 0xFBF6F2)

    // MARK: Decorative blobs (warm peach wash on top of bgBase)
    static let blobWarm     = Color(hex: 0xF7C9AE)
    static let blobCoral    = Color(hex: 0xF4A48C)
    static let blobPeach    = Color(hex: 0xF6D9C8)
}

// MARK: - Hex initializer

extension Color {
    /// Create a Color from a 0xRRGGBB literal, e.g. `Color(hex: 0xEF5B3A)`.
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
