//
//  StyleDetailScreen.swift
//  HomeDecor
//
//  Create flow — Style Detail (Figma 12:33088). Full-bleed hero photo of the
//  style fading into the background, a glass category chip + big title,
//  "More in <category>" thumbnails, and the black "Try this style" CTA.
//

import SwiftUI
import Factory

struct StyleDetailScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.createSession) private var session: CreateSession

    private let bg = Color(hex: 0xEAE8E6)

    var body: some View {
        ZStack(alignment: .top) {
            bg.ignoresSafeArea()

            hero
                .frame(height: 560)
                .frame(maxWidth: .infinity, alignment: .top)
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                CreateHeader(onBack: { app.navi.pop() })
                Spacer(minLength: 0)
                bottom
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Hero

    private var hero: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .top) {
                Image(session.style?.image ?? "cat_snow_cozy")
                    .resizable().scaledToFill()
                    .frame(width: w, height: 560)
                    .clipped()
                LinearGradient(stops: [
                    .init(color: bg.opacity(0.55), location: 0.0),
                    .init(color: bg.opacity(0.0),  location: 0.22),
                    .init(color: bg.opacity(0.15), location: 0.60),
                    .init(color: bg,               location: 1.0),
                ], startPoint: .top, endPoint: .bottom)
                .frame(width: w, height: 560)
            }
        }
    }

    // MARK: Bottom content

    private var bottom: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "house").font(.system(size: 11, weight: .semibold))
                    Text(session.style?.category ?? "")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(AppColor.coral)
                .padding(.horizontal, 14)
                .frame(height: 28)
                .glassPanel(14)

                Text(session.style?.name ?? "")
                    .font(.system(size: 30, weight: .bold)).tracking(-0.4)
                    .foregroundStyle(AppColor.ink)
            }
            .padding(.horizontal, 20)

            if !session.siblings.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(format: "more_in".localized, session.style?.category ?? ""))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColor.ink)
                        .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(session.siblings.prefix(8)) { style in
                                thumb(style)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }

            FlowCTAButton(title: "try_this_style".localized, systemIcon: "sparkles") {
                app.navi.push(.uploadPhoto)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
    }

    private func thumb(_ style: CreateStyle) -> some View {
        Button { session.select(style) } label: {
            ZStack(alignment: .bottomLeading) {
                Image(style.image).resizable().scaledToFill()
                    .frame(width: 111, height: 140)
                LinearGradient(colors: [.clear, .black.opacity(0.65)],
                               startPoint: .center, endPoint: .bottom)
                Text(style.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xF2F5F1))
                    .padding(10)
            }
            .frame(width: 111, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColor.ink.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(PressableStyle())
    }
}
