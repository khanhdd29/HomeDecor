//
//  CategorySeeAllScreen.swift
//  HomeDecor
//
//  Inspiration — Category — See All (Figma 10:24070). Back + category name, a
//  "N styles" count, and a 2-column grid of big style cards. Tapping a card
//  opens Style Detail. Reads the list from InspirationStore.
//

import SwiftUI
import Factory

struct CategorySeeAllScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.createSession) private var session: CreateSession
    @Injected(\.inspiration) private var store: InspirationStore

    private let columns = [GridItem(.flexible(), spacing: 13), GridItem(.flexible(), spacing: 13)]

    var body: some View {
        VStack(spacing: 0) {
            CreateHeader(title: store.browseTitle, onBack: { app.navi.pop() })

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(String(format: "styles_count".localized, store.browseStyles.count))
                        .font(.system(size: 13, weight: .medium)).foregroundStyle(AppColor.inkSecondary)

                    LazyVGrid(columns: columns, spacing: 13) {
                        ForEach(store.browseStyles) { style in
                            card(style)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .background(BlobBackground().ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func card(_ style: CreateStyle) -> some View {
        Button {
            session.start(style, in: store.browseStyles)
            app.navi.push(.styleDetail)
        } label: {
            ZStack(alignment: .bottomLeading) {
                Color.clear.frame(height: 250)
                    .overlay(Image(style.image).resizable().scaledToFill())
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                LinearGradient(colors: [.clear, Color(hex: 0x050812).opacity(0.75)],
                               startPoint: .center, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                Text(style.name).font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xF2F5F1)).padding(14)
            }
            .frame(height: 250)
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(AppColor.ink.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(PressableStyle())
    }
}
