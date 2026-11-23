//
//  CoralPopup.swift
//  HomeDecor
//
//  Reusable Coral Glass dialog (Figma 12:36268 and the other Phase 4 popups):
//  dim backdrop + a frosted card with a coral badge-icon, title, message, and
//  one or two stacked buttons. Overlay it on a screen and toggle with @State.
//

import SwiftUI

struct CoralPopup: View {
    var icon: String                      // SF Symbol in the coral circle
    var badge: String? = nil              // small SF Symbol in the white badge
    var title: String
    var message: String
    var primaryTitle: String
    var primaryAction: () -> Void
    var secondaryTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil
    /// Lay the two buttons side by side (secondary left, primary right) instead
    /// of stacked — Figma 10:29290 (Clear Chat).
    var horizontal: Bool = false
    /// Backdrop tap; defaults to the secondary (or primary) action.
    var onBackdrop: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color(hex: 0x291F1A).opacity(0.38)
                .ignoresSafeArea()
                .onTapGesture { (onBackdrop ?? secondaryAction ?? primaryAction)() }

            VStack(spacing: 12) {
                popupIcon
                VStack(spacing: 6) {
                    Text(title).font(.system(size: 18, weight: .semibold)).foregroundStyle(AppColor.ink)
                    Text(message).font(.system(size: 14)).foregroundStyle(AppColor.inkSecondary)
                        .multilineTextAlignment(.center).frame(width: 250)
                }
                if horizontal, let secondaryTitle, let secondaryAction {
                    HStack(spacing: 10) {
                        secondaryButton(secondaryTitle, secondaryAction)
                        primaryButton
                    }
                } else {
                    VStack(spacing: 10) {
                        primaryButton
                        if let secondaryTitle, let secondaryAction {
                            secondaryButton(secondaryTitle, secondaryAction)
                        }
                    }
                }
            }
            .padding(20)
            .frame(width: 300)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).strokeBorder(.white.opacity(0.9), lineWidth: 1))
            .shadow(color: Color(hex: 0x4D2E1F).opacity(0.18), radius: 20, x: 0, y: 20)
        }
    }

    private var primaryButton: some View {
        Button(action: primaryAction) {
            Text(primaryTitle).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).frame(height: 44)
                .background(AppColor.ink, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(PressableStyle())
    }

    private func secondaryButton(_ title: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.system(size: 15, weight: .medium)).foregroundStyle(AppColor.ink)
                .frame(maxWidth: .infinity).frame(height: 44)
                .background(AppColor.ink.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(PressableStyle())
    }

    private var popupIcon: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [Color(hex: 0xFFA880), Color(hex: 0xE04229)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 76, height: 76)
                .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: 4))
                .shadow(color: AppColor.coral.opacity(0.45), radius: 16, x: 0, y: 8)
            Image(systemName: icon).font(.system(size: 30, weight: .semibold)).foregroundStyle(.white)
            if let badge {
                Image(systemName: badge).font(.system(size: 13, weight: .bold)).foregroundStyle(AppColor.coral)
                    .frame(width: 34, height: 34)
                    .background(.white, in: Circle())
                    .overlay(Circle().strokeBorder(.white, lineWidth: 1))
                    .shadow(color: Color(hex: 0x733824).opacity(0.16), radius: 6, x: 0, y: 6)
                    .offset(x: 34, y: -30)
            }
        }
        .frame(height: 96)
    }
}
