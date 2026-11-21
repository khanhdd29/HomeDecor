//
//  CoralTabBar.swift
//  HomeDecor
//
//  Custom Coral Glass tab bar + floating Create FAB. Built as reusable
//  components; wired into the shell in Phase 3 (the FAB launches the Create
//  flow, which doesn't exist yet).
//

import SwiftUI

struct CoralTabBar: View {
    @Binding var selection: HomeTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: AppRadius.xl)
    }

    private func tabButton(_ tab: HomeTab) -> some View {
        let isActive = tab == selection
        return Button {
            selection = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isActive ? tab.iconSelected : tab.icon)
                    .font(.system(size: 20, weight: .semibold))
                Text(tab.title)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(isActive ? AppColor.coral : AppColor.inkTertiary)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle())
    }
}

/// Floating coral action button that starts a new design.
struct CreateFAB: View {
    var action: () -> Void
    var body: some View {
        CoralCircleButton(systemName: "wand.and.stars", size: 60, action: action)
    }
}

#if DEBUG
private struct CoralTabBarPreview: View {
    @State private var tab: HomeTab = .create
    var body: some View {
        ZStack(alignment: .bottom) {
            BlobBackground()
            ZStack(alignment: .topTrailing) {
                CoralTabBar(selection: $tab)
                CreateFAB(action: {})
                    .offset(x: -8, y: -36)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, 8)
        }
    }
}

#Preview { CoralTabBarPreview() }
#endif
