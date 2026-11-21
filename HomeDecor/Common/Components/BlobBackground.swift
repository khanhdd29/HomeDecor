//
//  BlobBackground.swift
//  HomeDecor
//
//  Coral Glass screen background: neutral base (#EAE8E6) with soft warm peach
//  blobs — matches the Figma onboarding background (peach wash fading down).
//

import SwiftUI

struct BlobBackground: View {
    var intensity: Double = 1.0

    var body: some View {
        ZStack {
            AppColor.bgBase

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    blob(AppColor.blobWarm.opacity(0.85 * intensity), size: 460, x: w * 0.80, y: h * 0.06)
                    blob(AppColor.blobPeach.opacity(0.80 * intensity), size: 420, x: w * 0.15, y: h * 0.02)
                    blob(AppColor.blobWarm.opacity(0.45 * intensity), size: 360, x: w * 0.95, y: h * 0.40)
                    blob(AppColor.blobPeach.opacity(0.35 * intensity), size: 320, x: w * 0.05, y: h * 0.52)
                }
                .blur(radius: 80)
            }
        }
        .ignoresSafeArea()
    }

    private func blob(_ color: Color, size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .position(x: x, y: y)
    }
}

#if DEBUG
#Preview {
    ZStack {
        BlobBackground()
        Text("Coral Glass").font(.appDisplay()).foregroundStyle(AppColor.ink)
    }
}
#endif
