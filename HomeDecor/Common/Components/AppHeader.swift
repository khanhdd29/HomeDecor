//
//  AppHeader.swift
//  HomeDecor
//
//  Home top bar (Figma 10:2393): glass ☰ menu · "Home Decor" · glass ✦ Pro.
//  The Pro entry is hidden for v1 (no IAP) via `AppFeatures.showPro`.
//

import SwiftUI

struct AppHeader: View {
    var onMenu: (() -> Void)? = nil
    var onPro: (() -> Void)? = nil

    var body: some View {
        HStack {
            Button { onMenu?() } label: {
                VStack(spacing: 4) {
                    bar(16); bar(10); bar(16)
                }
                .frame(width: 44, height: 44)
                .glassButton()
            }
            .buttonStyle(PressableStyle())

            Spacer()

            Text("Home Decor")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColor.ink)

            Spacer()

            if AppFeatures.showPro {
                Button { onPro?() } label: {
                    Text("✦")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColor.coral)
                        .frame(width: 44, height: 44)
                        .glassButton()
                }
                .buttonStyle(PressableStyle())
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
    }

    private func bar(_ w: CGFloat) -> some View {
        Capsule().fill(AppColor.ink).frame(width: w, height: 2)
    }
}

extension View {
    /// 44pt frosted square button used in headers.
    func glassButton() -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(.white.opacity(0.75), lineWidth: 1))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 8)
    }
}

#if DEBUG
#Preview {
    ZStack(alignment: .top) {
        BlobBackground()
        AppHeader(onMenu: {}, onPro: {}).padding(.top, 8)
    }
}
#endif
