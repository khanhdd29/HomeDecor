//
//  BlobBackground.swift
//  HomeDecor
//
//  The Coral Glass screen background: warm peach gradient + soft blurred blobs.
//  Use as a screen background: `.background(BlobBackground())`.
//

import SwiftUI

struct BlobBackground: View {
    /// Tune how strong the coral blobs read on this screen.
    var intensity: Double = 1.0

    var body: some View {
        ZStack {
            AppGradient.background

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    blob(AppColor.blobCoral.opacity(0.32 * intensity), size: 340, x: w * 0.86, y: h * 0.10)
                    blob(AppColor.blobPeach.opacity(0.55 * intensity), size: 380, x: w * 0.06, y: h * 0.42)
                    blob(AppColor.blobCoral.opacity(0.20 * intensity), size: 320, x: w * 0.92, y: h * 0.82)
                    blob(AppColor.blobPeach.opacity(0.40 * intensity), size: 300, x: w * 0.10, y: h * 0.95)
                }
                .blur(radius: 70)
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
        Text("Coral Glass")
            .font(.appDisplay())
            .foregroundStyle(AppColor.ink)
    }
}
#endif
