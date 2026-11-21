//
//  CreateComponents.swift
//  HomeDecor
//
//  Small shared pieces for the Create flow.
//

import SwiftUI
import UIKit

/// A photo that fills its width at a fixed height WITHOUT overflowing its
/// container. Using `scaledToFill()` directly with `.frame(maxWidth: .infinity)`
/// lets the image report an oversized width and stretches the whole screen
/// (losing padding); driving layout from a `Color.clear` and painting the image
/// as a clipped overlay avoids that.
struct FilledPhoto: View {
    let image: UIImage
    var height: CGFloat
    var cornerRadius: CGFloat = 24

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay(Image(uiImage: image).resizable().scaledToFill())
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

/// Standard flow header: a glass back button, a centered title, and a 44pt
/// spacer so the title stays optically centered.
struct CreateHeader: View {
    var title: String = ""
    var onBack: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColor.ink)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColor.ink)
                        .frame(width: 44, height: 44)
                        .glassButton()
                }
                .buttonStyle(PressableStyle())
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

/// Black pill CTA used at the bottom of flow screens. Dims to 40% when disabled.
struct FlowCTAButton: View {
    let title: String
    var systemIcon: String? = nil
    var enabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: { if enabled { action() } }) {
            HStack(spacing: 8) {
                if let systemIcon { Image(systemName: systemIcon).font(.system(size: 16, weight: .semibold)) }
                Text(title).font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AppColor.ink, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .opacity(enabled ? 1 : 0.4)
            .shadow(color: Color(hex: 0x1A140F).opacity(enabled ? 0.18 : 0), radius: 10, x: 0, y: 8)
        }
        .buttonStyle(PressableStyle())
        .disabled(!enabled)
    }
}
