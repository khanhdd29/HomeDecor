//
//  PrivacyPolicyScreen.swift
//  HomeDecor
//
//  Setting — Privacy Policy (Figma 10:29947). Header + a frosted card with
//  four coral-headed sections.
//

import SwiftUI
import Factory

struct PrivacyPolicyScreen: View {
    @Injected(\.app) private var app

    private let sections: [(String, String)] = [
        ("policy_1_title", "policy_1_body"),
        ("policy_2_title", "policy_2_body"),
        ("policy_3_title", "policy_3_body"),
        ("policy_4_title", "policy_4_body"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("policy_updated".localized)
                        .font(.system(size: 13)).foregroundStyle(AppColor.inkSecondary)

                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(sections, id: \.0) { title, body in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(title.localized)
                                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColor.coral)
                                Text(body.localized)
                                    .font(.system(size: 14)).foregroundStyle(AppColor.ink.opacity(0.8))
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 18).padding(.vertical, 20)
                    .glassPanel(28)
                }
                .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 32)
            }
        }
        .background(BlobBackground().ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
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
