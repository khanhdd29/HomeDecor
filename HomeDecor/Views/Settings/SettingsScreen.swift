//
//  SettingsScreen.swift
//  HomeDecor
//
//  Setting tab — matches Figma node 10:3964 (Coral Glass). Header + settings
//  rows grouped in frosted cards. The Pro upsell card is hidden for v1 (no IAP).
//

import SwiftUI
import Factory

struct SettingsScreen: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Injected(\.app) private var app
    @InjectedObject(\.appFlow) private var appFlow: AppFlowCoordinator
    @Environment(\.openURL) private var openURL
    @State private var showShare = false

    var body: some View {
        ZStack(alignment: .top) {
            BlobBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Pro upsell (hidden for v1 — no IAP).
                    if AppFeatures.showPro {
                        proCard
                    }

                    group {
                        row(icon: "character.bubble", title: "language".localized) {
                            viewModel.openLanguage()
                        }
                    }

                    group {
                        row(icon: "star", title: "rate".localized) { viewModel.rateApp() }
                        divider
                        row(icon: "square.and.arrow.up", title: "share".localized) { showShare = true }
                        divider
                        row(icon: "checkmark.shield", title: "privacy_policy".localized) {
                            app.navi.push(.privacyPolicy)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 118)
                .padding(.bottom, 130)
            }

            header
        }
        .sheet(isPresented: $showShare) { ShareAppSheet(onClose: { showShare = false }) }
        .trackScreen(.setting)
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            Text("setting".localized)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColor.ink)
            // Setting is a tab root (never pushed), so there is nothing to pop —
            // no back button here; leave side spacers to keep the title centered.
            HStack {
                Color.clear.frame(width: 44, height: 44)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: Rows

    private func group<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).strokeBorder(.white.opacity(0.75), lineWidth: 1))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 8)
    }

    private func row(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(AppColor.ink)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(title).font(.system(size: 16, weight: .medium)).foregroundStyle(AppColor.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.inkTertiary)
            }
            .padding(.leading, 12).padding(.trailing, 16)
            .frame(height: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var divider: some View {
        Rectangle().fill(AppColor.ink.opacity(0.06)).frame(height: 1)
            .padding(.leading, 52).padding(.trailing, 16)
    }

    // MARK: Pro card (hidden v1)

    private var proCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("✦ PRO").font(.system(size: 12, weight: .bold)).foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(AppColor.coral, in: RoundedRectangle(cornerRadius: 12))
            Text("Unlock\nHome Decor Pro").font(.system(size: 20, weight: .bold)).foregroundStyle(AppColor.ink)
            Text("Unlimited AI redesigns, all styles & HD downloads")
                .font(.system(size: 13)).foregroundStyle(AppColor.inkSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}
