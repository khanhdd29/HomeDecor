//
//  AppButton.swift
//  HomeDecor
//
//  Coral Glass button kit: pill buttons (coral / dark), round icon buttons,
//  and the coral circle used for the Create FAB and "Try Now".
//

import SwiftUI

// MARK: - Press feedback

/// Subtle scale + dim while pressed. Reused by every tappable surface.
struct PressableStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Pill buttons

/// Full-width coral capsule — the primary CTA (e.g. "Generate", "Continue").
struct CoralPillButton: View {
    let title: String
    var icon: String? = nil
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                if let icon { Image(systemName: icon) }
            }
            .font(.appLabel())
            .foregroundStyle(AppColor.onCoral)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColor.coral, in: Capsule())
            .opacity(isEnabled ? 1 : 0.4)
        }
        .buttonStyle(PressableStyle())
        .disabled(!isEnabled)
    }
}

/// Full-width ink capsule — secondary dark CTA (e.g. "Try Now", "Save").
struct DarkPillButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                if let icon { Image(systemName: icon) }
            }
            .font(.appLabel())
            .foregroundStyle(AppColor.onDark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColor.ink, in: Capsule())
        }
        .buttonStyle(PressableStyle())
    }
}

// MARK: - Icon buttons

/// Round frosted-glass icon button (header menu, back, close…).
struct CircleIconButton: View {
    let systemName: String
    var size: CGFloat = 44
    var tint: Color = AppColor.ink
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: size, height: size)
                .glassCard(cornerRadius: AppRadius.pill)
        }
        .buttonStyle(PressableStyle())
    }
}

/// Solid coral circle with an icon — the Create FAB / "Try Now" arrow.
struct CoralCircleButton: View {
    var systemName: String = "arrow.up.right"
    var size: CGFloat = 56
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.36, weight: .bold))
                .foregroundStyle(AppColor.onCoral)
                .frame(width: size, height: size)
                .background(AppColor.coral, in: Circle())
                .shadow(color: AppColor.coral.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PressableStyle())
    }
}

#if DEBUG
#Preview {
    ZStack {
        BlobBackground()
        VStack(spacing: 16) {
            CoralPillButton(title: "Generate", icon: "sparkles") {}
            DarkPillButton(title: "Try Now", icon: "arrow.up.right") {}
            HStack(spacing: 16) {
                CircleIconButton(systemName: "line.3.horizontal") {}
                CircleIconButton(systemName: "xmark") {}
                CoralCircleButton {}
            }
        }
        .padding()
    }
}
#endif
