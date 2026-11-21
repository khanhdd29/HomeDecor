//
//  ChooseStyleScreen.swift
//  HomeDecor
//
//  Create flow — Choose Style (Figma 12:33654 / Outside 12:35537).
//  PLACEHOLDER for batch 1: shows the picked photo + selected style and a
//  Generate CTA. Batch 2 builds the full screen (Inside/Outside toggle, room
//  types, style grid, Change Style sheet) and batch 3 wires Generate →
//  Generating → Result.
//

import SwiftUI
import Factory

struct ChooseStyleScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.createSession) private var session: CreateSession

    var body: some View {
        VStack(spacing: 0) {
            CreateHeader(title: "choose_style".localized, onBack: { app.navi.pop() })

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if let photo = session.sourcePhoto {
                        FilledPhoto(image: photo, height: 240, cornerRadius: 24)
                    }
                    if let style = session.style {
                        HStack(spacing: 12) {
                            Image(style.image).resizable().scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("selected_style".localized)
                                    .font(.system(size: 12, weight: .medium)).foregroundStyle(AppColor.inkSecondary)
                                Text(style.name)
                                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColor.ink)
                            }
                            Spacer()
                        }
                        .padding(.leading, 10).padding(.trailing, 14).padding(.vertical, 10)
                        .glassPanel(24)
                    }
                    Text("choose_style_soon".localized)
                        .font(.system(size: 13)).foregroundStyle(AppColor.inkSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            FlowCTAButton(title: "generate".localized, systemIcon: "sparkles", enabled: false) {}
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 34)
        }
        .background(BlobBackground().ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
