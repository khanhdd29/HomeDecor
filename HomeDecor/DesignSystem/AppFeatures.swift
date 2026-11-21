//
//  AppFeatures.swift
//  HomeDecor
//
//  Central feature flags. The first App Store build ships WITHOUT ads and
//  WITHOUT in-app purchases, so those surfaces are gated off here and the
//  related UI stays commented / hidden until a later release.
//

import Foundation

enum AppFeatures {
    /// Ads are disabled for v1. Keep `Core/Ads` wired but inert (also governed
    /// by Remote Config `showAllAds` + empty ad unit ids). Do not add new ad
    /// placements while this is `false`.
    static let adsEnabled = false

    /// In-app purchases / paywall disabled for v1.
    static let iapEnabled = false

    /// Pro entry point (✦) and premium template badges. Hidden while IAP is off.
    static var showPro: Bool { iapEnabled }
}
