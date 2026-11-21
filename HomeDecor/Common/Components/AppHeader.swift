//
//  AppHeader.swift
//  HomeDecor
//
//  The Home / Create top bar: ☰ menu · "Home Decor" wordmark · ✦ Pro.
//  The Pro entry is hidden for v1 (no IAP) via `AppFeatures.showPro`.
//

import SwiftUI

struct AppHeader: View {
    var onMenu: (() -> Void)? = nil
    var onPro: (() -> Void)? = nil

    var body: some View {
        ZStack {
            // Wordmark (brand — not localized)
            Text("Home Decor")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppColor.ink)

            HStack {
                if let onMenu {
                    CircleIconButton(systemName: "line.3.horizontal", action: onMenu)
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }

                Spacer()

                // Pro (✦) — hidden while IAP is off (v1). Keep for later release.
                if AppFeatures.showPro {
                    Button(action: { onPro?() }) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(AppColor.coral)
                            .frame(width: 44, height: 44)
                            .glassCard(cornerRadius: AppRadius.pill)
                    }
                    .buttonStyle(PressableStyle())
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, AppSpacing.lg)
    }
}

#if DEBUG
#Preview {
    ZStack(alignment: .top) {
        BlobBackground()
        AppHeader(onMenu: {}, onPro: {})
            .padding(.top, 8)
    }
}
#endif
