//
//  HomeTabView.swift
//  HomeDecor
//
//  Four-tab shell with the floating Coral Glass tab bar + AI Chat FAB
//  (Figma 10:2386). Content scrolls behind the floating bar.
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
        // Observe the language so tab titles re-read `.localized` at runtime.
        let _ = coordinator.language
        return ZStack(alignment: .bottom) {
            ZStack {
                tab(.create, destination: .create, navigation: createNavi)
                tab(.inspiration, destination: .inspiration, navigation: inspirationNavi)
                tab(.mylook, destination: .mylook, navigation: mylookNavi)
                tab(.setting, destination: .setting, navigation: settingNavi)
            }

            if activeNavigation.isAtRoot && !app.hideShellChrome {
                ZStack(alignment: .topTrailing) {
                    CoralTabBar(selection: $app.activeTab)
                    AIChatFAB(action: { /* Phase 7: open AI chat */ })
                        .offset(x: 2, y: -76)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: activeNavigation.isAtRoot)
        .animation(.easeInOut(duration: 0.2), value: app.hideShellChrome)
        .onAppear {
            guard !isFirstAppear else { return }
            isFirstAppear = true
            app.navi = createNavi
        }
        .onChange(of: app.activeTab) { tab in
            didSelectTab(tab)
        }
    }

    @ViewBuilder
    private func tab(_ tab: HomeTab, destination: Destination, navigation: Navigation) -> some View {
        let active = app.activeTab == tab
        NavigationRoot(destination: destination, navigation: navigation)
            .opacity(active ? 1 : 0)
            .allowsHitTesting(active)
            .zIndex(active ? 1 : 0)
    }

    private var activeNavigation: Navigation {
        switch app.activeTab {
        case .create:      return createNavi
        case .inspiration: return inspirationNavi
        case .mylook:      return mylookNavi
        case .setting:     return settingNavi
        }
    }

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
    HomeTabView().environmentObject(AppFlowCoordinator())
}
#endif
