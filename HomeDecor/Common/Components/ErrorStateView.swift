//
//  ErrorStateView.swift
//  HomeDecor
//
//  Full-bleed error / empty-connection states (Figma 10:30402 No Internet,
//  10:30595 Server Error): concentric rings + a coral icon badge, a title,
//  a message and a dark "try again" button. Shown as tab content when a load
//  fails; reusable via the `.offline` / `.serverError` presets.
//

import SwiftUI

struct ErrorStateConfig {
    var icon: String          // SF Symbol in the coral circle
    var badge: String         // SF Symbol in the white corner badge
    var titleKey: String
    var messageKey: String
    var ctaKey: String

    static let offline = ErrorStateConfig(
        icon: "wifi.slash", badge: "xmark",
        titleKey: "offline_title", messageKey: "offline_message", ctaKey: "try_again")

    static let serverError = ErrorStateConfig(
        icon: "exclamationmark", badge: "arrow.clockwise",
        titleKey: "server_error_title", messageKey: "server_error_message", ctaKey: "reload")
}

struct ErrorStateView: View {
    var config: ErrorStateConfig
    var onRetry: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            rings
                .padding(.bottom, 28)
            Text(config.titleKey.localized)
                .font(.system(size: 22, weight: .bold)).foregroundStyle(AppColor.ink)
            Text(config.messageKey.localized)
                .font(.system(size: 14)).foregroundStyle(AppColor.inkSecondary)
                .multilineTextAlignment(.center).frame(width: 260)
                .padding(.top, 8)

            Button(action: onRetry) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise").font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColor.coral)
                    Text(config.ctaKey.localized).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity).frame(height: 56)
                .background(AppColor.ink, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
            .buttonStyle(PressableStyle())
            .padding(.top, 28).padding(.horizontal, 20)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var rings: some View {
        ZStack {
            Circle()
                .strokeBorder(AppColor.coral.opacity(0.35),
                              style: StrokeStyle(lineWidth: 1.5, dash: [2, 7]))
                .frame(width: 196, height: 196)
            Circle().fill(.white.opacity(0.45)).frame(width: 150, height: 150)
                .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1))
            // Coral dot sitting on the dashed ring.
            Circle().fill(AppColor.coral).frame(width: 10, height: 10)
                .offset(x: -92, y: 42)

            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: 0xFFA880), Color(hex: 0xE04229)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 96, height: 96)
                    .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: 4))
                    .shadow(color: AppColor.coral.opacity(0.4), radius: 16, x: 0, y: 8)
                    .overlay(Image(systemName: config.icon).font(.system(size: 34, weight: .semibold)).foregroundStyle(.white))

                Image(systemName: config.badge).font(.system(size: 13, weight: .bold)).foregroundStyle(AppColor.coral)
                    .frame(width: 34, height: 34).background(.white, in: Circle())
                    .shadow(color: Color(hex: 0x733824).opacity(0.16), radius: 6, x: 0, y: 6)
                    .offset(x: 8, y: -4)
            }
            .frame(width: 96, height: 96)
        }
        .frame(width: 196, height: 196)
    }
}

#if DEBUG
#Preview {
    ZStack { BlobBackground(); ErrorStateView(config: .offline, onRetry: {}) }
}
#endif
