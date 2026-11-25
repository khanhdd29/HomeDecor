//
//  ScreenTracking.swift
//  HomeDecor
//
//  Screen identifiers + a `.trackScreen(_:)` modifier. v1 ships with NO
//  analytics SDK, so the modifier is a no-op. If analytics is added back in a
//  later release, implement logging inside `ScreenTrackingModifier` — every
//  screen already carries the right `.trackScreen(...)` tag.
//

import SwiftUI

/// Stable screen identifiers (kept for when analytics is reintroduced).
enum AnalyticsScreen: String {
    case splash
    case language
    case intro
    case create
    case inspiration
    case mylook = "my_look"
    case setting
    case homeDetail = "home_detail"
    case settingsLanguage = "settings_language"
}

struct ScreenTrackingModifier: ViewModifier {
    let screen: AnalyticsScreen
    // No-op in v1 (no analytics SDK). Add logging here if analytics returns.
    func body(content: Content) -> some View { content }
}

extension View {
    func trackScreen(_ screen: AnalyticsScreen) -> some View {
        modifier(ScreenTrackingModifier(screen: screen))
    }
}
