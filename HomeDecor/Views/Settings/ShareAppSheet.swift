//
//  ShareAppSheet.swift
//  HomeDecor
//
//  Setting — Share App bottom sheet (Figma 10:31022). App card + share
//  targets (Messages / Instagram / Copy link / More). Presented as a sheet;
//  the system supplies the dim + grabber.
//

import SwiftUI

struct ShareAppSheet: View {
    var onClose: () -> Void

    private let appName = "Home Decor AI"
    private let appURL = "https://apps.apple.com/app/home-decor"
    private let shortURL = "apps.apple.com/home-decor"
    @State private var copied = false

    var body: some View {
        VStack(spacing: 16) {
            appCard
            HStack(alignment: .top) {
                target(image: "share_messages", title: "Messages") { systemShare() }
                Spacer()
                target(image: "share_instagram", title: "Instagram") { systemShare() }
                Spacer()
                glassTarget(icon: copied ? "checkmark" : "link", title: "share_copy_link".localized) { copyLink() }
                Spacer()
                glassTarget(icon: "ellipsis", title: "share_more".localized) { systemShare() }
            }

            Button { onClose() } label: {
                Text("cancel".localized).font(.system(size: 15, weight: .medium)).foregroundStyle(AppColor.ink)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(AppColor.ink.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(PressableStyle())
        }
        .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BlobBackground())
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }

    private var appCard: some View {
        HStack(spacing: 12) {
            Image("share_app_icon").resizable().scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).strokeBorder(AppColor.ink.opacity(0.12), lineWidth: 1))
            VStack(alignment: .leading, spacing: 2) {
                Text(appName).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColor.ink)
                Text(shortURL).font(.system(size: 12)).foregroundStyle(AppColor.inkSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .glassPanel(24)
    }

    private func target(image: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(image).resizable().scaledToFit().frame(width: 56, height: 56)
                Text(title).font(.system(size: 12)).foregroundStyle(AppColor.ink.opacity(0.8))
            }
        }
        .buttonStyle(PressableStyle())
    }

    private func glassTarget(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 22, weight: .medium)).foregroundStyle(AppColor.ink)
                    .frame(width: 56, height: 56).glassPanel(28)
                Text(title).font(.system(size: 12)).foregroundStyle(AppColor.ink.opacity(0.8))
            }
        }
        .buttonStyle(PressableStyle())
    }

    private func copyLink() {
        UIPasteboard.general.string = appURL
        withAnimation { copied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { onClose() }
    }

    private func systemShare() {
        let av = UIActivityViewController(activityItems: ["\(appName) — \(appURL)"], applicationActivities: nil)
        UIApplication.shared.topShareVC?.present(av, animated: true)
    }
}

private extension UIApplication {
    var topShareVC: UIViewController? {
        let scene = connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        var top = scene?.keyWindow?.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }
}
