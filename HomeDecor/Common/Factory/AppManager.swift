//
//  AppManager.swift
//  SwiftBase
//
//  Created by VanTuan on 18/6/26.
//

import Foundation
import Combine

@MainActor
final class AppManager: ObservableObject {
    /// The currently selected tab.
    @Published var activeTab: HomeTab = .create

    /// The navigation tree of the active tab. `HomeTabView` keeps this in sync.
    @Published var navi: Navigation = Navigation()

    /// Whether the app is currently backgrounded.
    @Published var isInBackground: Bool = false

    /// Hides the floating tab bar + AI Chat FAB even at the root (e.g. while the
    /// My look gallery is in multi-select mode).
    @Published var hideShellChrome: Bool = false
}
