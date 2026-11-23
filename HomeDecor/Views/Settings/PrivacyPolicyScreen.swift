//
//  PrivacyPolicyScreen.swift
//  HomeDecor
//
//  Setting — Privacy Policy (Figma 10:29947). Header + an in-app web view that
//  loads the hosted policy page from `AppConstants.policyLink` (the real policy
//  content lives on the web, not hardcoded in the app).
//

import SwiftUI
import Factory

struct PrivacyPolicyScreen: View {
    @Injected(\.app) private var app
    @StateObject private var model = WebViewModel()

    private var policyURL: URL? {
        AppConstants.policyLink.isEmpty ? nil : URL(string: AppConstants.policyLink)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ZStack {
                if let url = policyURL {
                    InAppWebView(url: url, model: model)
                        .opacity(model.failed ? 0 : 1)
                    if model.isLoading {
                        ProgressView().tint(AppColor.coral)
                    }
                    if model.failed {
                        placeholder("offline_title", "offline_message")
                    }
                } else {
                    // policyLink not set yet.
                    placeholder("privacy_policy", "policy_updated")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Figma 10:29947 — content sits in a padded, rounded card.
            .background(Color(hex: 0xF6F3F1))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(BlobBackground().ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func placeholder(_ titleKey: String, _ bodyKey: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.text")
                .font(.system(size: 34, weight: .regular)).foregroundStyle(AppColor.coral)
            Text(titleKey.localized)
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
            Text(bodyKey.localized)
                .font(.system(size: 14)).foregroundStyle(AppColor.inkSecondary)
                .multilineTextAlignment(.center).frame(width: 260)
        }
        .padding(24)
    }

    private var header: some View {
        ZStack {
            Text("privacy_policy".localized)
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
            HStack {
                Button { app.navi.pop() } label: {
                    Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColor.ink).frame(width: 44, height: 44).glassButton()
                }
                .buttonStyle(PressableStyle())
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .frame(height: 44).padding(.horizontal, 24).padding(.top, 8).padding(.bottom, 12)
    }
}
