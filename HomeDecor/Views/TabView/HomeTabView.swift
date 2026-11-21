//
//  HomeTabView.swift
//  HomeDecor
//
//  Four-tab shell: Create · Inspiration · My look · Setting.
//  NOTE: uses the native TabView for now; the custom Coral Glass tab bar
//  (`CoralTabBar` + `CreateFAB`) is wired in Phase 3 together with the Home
//  screen so the FAB can launch the Create flow.
//

import SwiftUI
import Factory

struct HomeTabView: View {
    @InjectedObject(\.createNavi) private var createNavi: Navigation
    @InjectedObject(\.inspirationNavi) private var inspirationNavi: Navigation
    @InjectedObject(\.mylookNavi) private var mylookNavi: Navigation
    @InjectedObject(\.settingNavi) private var settingNavi: Navigation
    @InjectedObject(\.app) private var app: AppManager
    @EnvironmentObject private var coordinator: AppFlowCoordinator

    @State private var isFirstAppear = false

    var body: some View {
        // Observe the language so the tab titles re-read `.localized` when it
        // changes at runtime (e.g. from the Settings language sheet).
        let _ = coordinator.language
        return TabView(selection: $app.activeTab) {
            NavigationRoot(destination: .create, navigation: createNavi)
                .tabItem { Label(HomeTab.create.title, systemImage: HomeTab.create.icon) }
                .tag(HomeTab.create)

            NavigationRoot(destination: .inspiration, navigation: inspirationNavi)
                .tabItem { Label(HomeTab.inspiration.title, systemImage: HomeTab.inspiration.icon) }
                .tag(HomeTab.inspiration)

            NavigationRoot(destination: .mylook, navigation: mylookNavi)
                .tabItem { Label(HomeTab.mylook.title, systemImage: HomeTab.mylook.icon) }
                .tag(HomeTab.mylook)

            NavigationRoot(destination: .setting, navigation: settingNavi)
                .tabItem { Label(HomeTab.setting.title, systemImage: HomeTab.setting.icon) }
                .tag(HomeTab.setting)
        }
        .tint(AppColor.coral)
        .onAppear {
            guard !isFirstAppear else { return }
            isFirstAppear = true
            app.navi = createNavi
        }
        .onChange(of: app.activeTab) { tab in
            didSelectTab(tab)
        }
    }

    /// Keep `app.navi` pointing at the active tab's navigation tree.
    private func didSelectTab(_ tab: HomeTab) {
        switch tab {
        case .create:      app.navi = createNavi
        case .inspiration: app.navi = inspirationNavi
        case .mylook:      app.navi = mylookNavi
        case .setting:     app.navi = settingNavi
        }
    }
}

#if DEBUG
#Preview {
    HomeTabView()
        .environmentObject(AppFlowCoordinator())
}
#endif
