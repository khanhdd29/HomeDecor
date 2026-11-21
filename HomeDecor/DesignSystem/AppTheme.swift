//
//  AppTheme.swift
//  HomeDecor
//
//  Radii, spacing, shadows, gradients and type helpers for Coral Glass.
//

import SwiftUI

enum AppRadius {
    static let xs: CGFloat   = 12
    static let sm: CGFloat   = 16
    static let md: CGFloat   = 20
    static let lg: CGFloat   = 28
    static let xl: CGFloat   = 34
    static let pill: CGFloat = 999
}

enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat  = 8
    static let sm: CGFloat  = 12
    static let md: CGFloat  = 16
    static let lg: CGFloat  = 20
    static let xl: CGFloat  = 28
}

enum AppGradient {
    /// Full-screen warm peach → neutral background.
    static let background = LinearGradient(
        colors: [AppColor.bgTop, AppColor.bgMid, AppColor.bgBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Coral brand gradient (logo, "Start" button, badges).
    static let coral = LinearGradient(
        colors: [AppColor.coralGradTop, AppColor.coralGradBot],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Type helpers

extension Font {
    /// Big bold display used by hero / result titles.
    static func appDisplay(_ size: CGFloat = 32) -> Font { .system(size: size, weight: .bold) }
    /// Section heading.
    static func appHeading(_ size: CGFloat = 20) -> Font { .system(size: size, weight: .semibold) }
    /// Button / emphasised label.
    static func appLabel(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .semibold) }
}
