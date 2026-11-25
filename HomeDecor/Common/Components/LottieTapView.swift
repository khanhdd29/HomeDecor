//
//  LottieTapView.swift
//  HomeDecor
//
//  Pure-SwiftUI tap hint. Replaces the old Lottie-based animation (Lottie came
//  transitively from the ad SDK, which was removed for the v1 App Store build).
//  Keeps the same name/API so call sites don't change.
//

import SwiftUI

struct LottieTapView: View {
    /// Kept for source compatibility with the old Lottie version (ignored).
    var name: String = "tap"
    /// Tint for the tapping hand.
    var tint: Color? = nil

    @State private var pressed = false

    private var color: Color { tint ?? AppColor.coral }

    var body: some View {
        ZStack {
            // Ripple that expands as the finger "taps".
            Circle()
                .stroke(color.opacity(pressed ? 0 : 0.5), lineWidth: 2)
                .scaleEffect(pressed ? 1.6 : 0.6)
                .frame(width: 26, height: 26)

            Image(systemName: "hand.point.up.left.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(color)
                .scaleEffect(pressed ? 0.86 : 1.0)
                .offset(x: 1, y: 2)
        }
        .frame(width: 36, height: 36)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pressed = true
            }
        }
    }
}

#if DEBUG
#Preview {
    LottieTapView(tint: .orange).padding()
}
#endif
