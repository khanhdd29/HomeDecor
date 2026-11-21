//
//  Destination.swift
//  SwiftBase
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI

enum Destination: Equatable {
    static func == (lhs: Destination, rhs: Destination) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }

    case create
    case inspiration
    case mylook
    case setting
    case homeDetail(id: Int)
    case language
}

extension Destination {
    var identifier: String {
        switch self {
        case .create:             return "create"
        case .inspiration:        return "inspiration"
        case .mylook:             return "mylook"
        case .setting:            return "setting"
        case .homeDetail(let id): return "homeDetail-\(id)"
        case .language:           return "language"
        }
    }
}

extension Navigation {
    @ViewBuilder
    internal func screen(for destinationWrapper: DestinationWrapper) -> some View {
        switch destinationWrapper.destination {
        case .create:
            HomeScreen()
        case .inspiration:
            SearchScreen()
        case .mylook:
            FavoritesScreen()
        case .setting:
            SettingsScreen()
        case .homeDetail(let id):
            HomeDetailScreen(id: id)
        case .language:
            LanguageView(mode: .settings)
        }
    }
}
