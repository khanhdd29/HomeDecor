//
//  HomeTab.swift
//  HomeDecor
//
//  The four main tabs (Coral Glass): Create · Inspiration · My look · Setting.
//

import Foundation

enum HomeTab: Hashable, CaseIterable {
    case create       // Home: hero + style catalog + Create FAB
    case inspiration  // Browse catalog of styles / categories
    case mylook       // Saved generated designs
    case setting      // Settings

    var title: String {
        switch self {
        case .create:      return "create".localized
        case .inspiration: return "inspiration".localized
        case .mylook:      return "my_look".localized
        case .setting:     return "setting".localized
        }
    }

    /// SF Symbol for the tab bar item (outline = inactive).
    var icon: String {
        switch self {
        case .create:      return "house"
        case .inspiration: return "square.grid.2x2"
        case .mylook:      return "photo.on.rectangle"
        case .setting:     return "gearshape"
        }
    }

    /// Filled variant for the active tab.
    var iconSelected: String {
        switch self {
        case .create:      return "house.fill"
        case .inspiration: return "square.grid.2x2.fill"
        case .mylook:      return "photo.fill.on.rectangle.fill"
        case .setting:     return "gearshape.fill"
        }
    }
}
