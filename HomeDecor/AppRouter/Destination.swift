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
    // Create / Generate flow (Phase 4)
    case styleDetail
    case uploadPhoto
    case chooseStyle
    case generating
    case result
    case compare
    case camera
    case adjustPhoto
    case categorySeeAll
    case styleImagePreview
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
        case .styleDetail:        return "styleDetail"
        case .uploadPhoto:        return "uploadPhoto"
        case .chooseStyle:        return "chooseStyle"
        case .generating:         return "generating"
        case .result:             return "result"
        case .compare:            return "compare"
        case .camera:             return "camera"
        case .adjustPhoto:        return "adjustPhoto"
        case .categorySeeAll:     return "categorySeeAll"
        case .styleImagePreview:  return "styleImagePreview"
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
        case .styleDetail:
            StyleDetailScreen()
        case .uploadPhoto:
            UploadPhotoScreen()
        case .chooseStyle:
            ChooseStyleScreen()
        case .generating:
            GeneratingScreen()
        case .result:
            ResultScreen()
        case .compare:
            CompareScreen()
        case .camera:
            CameraScreen()
        case .adjustPhoto:
            AdjustPhotoScreen()
        case .categorySeeAll:
            CategorySeeAllScreen()
        case .styleImagePreview:
            StyleImagePreviewScreen()
        }
    }
}
