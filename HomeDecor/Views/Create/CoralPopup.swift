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
                    Text(message).font(.system(size: 14)).foregroundStyle(AppColor.inkTertiary)
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
            .background(
                LinearGradient(colors: [Color(hex: 0xFFFDFC), Color(hex: 0xF6F3F1)],
                               startPoint: .top, endPoint: .bottom),
                in: RoundedRectangle(cornerRadius: 32, style: .continuous)
            )
            .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).strokeBorder(.white.opacity(0.8), lineWidth: 1))
            .shadow(color: Color(hex: 0x4D2E1F).opacity(0.14), radius: 24, x: 0, y: 18)
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
                .background(Color(hex: 0xEBEAEA), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(PressableStyle())
    }

    // Figma dialog icon: concentric dashed ring + white glow + coral dots +
    // a coral gradient circle, with a small white corner badge.
    private var popupIcon: some View {
        ZStack {
            Circle()
                .strokeBorder(AppColor.coral.opacity(0.3),
                              style: StrokeStyle(lineWidth: 1.5, dash: [2, 7]))
                .frame(width: 132, height: 132)
            Circle().fill(.white.opacity(0.5)).frame(width: 104, height: 104)
                .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1))
            // Coral dots sitting on the dashed ring.
            Circle().fill(AppColor.coral).frame(width: 9, height: 9).offset(x: -63, y: 26)
            Circle().fill(AppColor.coral.opacity(0.85)).frame(width: 7, height: 7).offset(x: 62, y: 22)

            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: 0xFFA880), Color(hex: 0xE04229)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 76, height: 76)
                    .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: 4))
                    .shadow(color: AppColor.coral.opacity(0.4), radius: 14, x: 0, y: 8)
                    .overlay(Image(systemName: icon).font(.system(size: 28, weight: .semibold)).foregroundStyle(.white))

                if let badge {
                    Image(systemName: badge).font(.system(size: 12, weight: .bold)).foregroundStyle(AppColor.coral)
                        .frame(width: 30, height: 30).background(.white, in: Circle())
                        .shadow(color: Color(hex: 0x733824).opacity(0.16), radius: 6, x: 0, y: 6)
                        .offset(x: 6, y: -2)
                }
            }
            .frame(width: 76, height: 76)
        }
        .frame(width: 132, height: 132)
    }
}
