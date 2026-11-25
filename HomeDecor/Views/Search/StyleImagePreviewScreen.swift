//
//  StyleImagePreviewScreen.swift
//  HomeDecor
//
//  Inspiration — Style — Image Preview (Figma 10:26121). A swipeable fullscreen
//  gallery of a category's styles with a pager, the style name + position, and a
//  "Try this style" CTA that starts the Create flow. Reads InspirationStore.
//

import SwiftUI
import Factory

struct StyleImagePreviewScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.createSession) private var session: CreateSession
    @Injected(\.inspiration) private var store: InspirationStore

    @State private var index = 0

    private var styles: [CreateStyle] { store.browseStyles }
    private var current: CreateStyle? { styles.indices.contains(index) ? styles[index] : nil }

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: 0xEAE8E6).ignoresSafeArea()

            VStack(spacing: 0) {
                header
                TabView(selection: $index) {
                    ForEach(styles.indices, id: \.self) { i in
                        Color.clear
                            .overlay(Image(styles[i].image).resizable().scaledToFill())
                            .clipped()
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 520)
                Spacer()
            }

            VStack(spacing: 14) {
                Spacer()
                pager
                VStack(spacing: 2) {
                    Text(current?.name ?? "").font(.system(size: 18, weight: .semibold)).foregroundStyle(AppColor.ink)
                    Text("\(current?.category ?? "") · \(index + 1) / \(styles.count)")
                        .font(.system(size: 13)).foregroundStyle(AppColor.inkSecondary)
                }
                Button {
                    if let c = current {
                        session.start(c, in: styles)
                        app.navi.push(.uploadPhoto)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles").font(.system(size: 16, weight: .semibold))
                        Text("try_this_style".localized).font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(AppColor.ink, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .shadow(color: Color(hex: 0x1A140F).opacity(0.18), radius: 10, x: 0, y: 8)
                }
                .buttonStyle(PressableStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
        .onAppear { index = min(max(0, store.previewStart), max(0, styles.count - 1)) }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            Button { app.navi.pop() } label: {
                Image(systemName: "xmark").font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.ink).frame(width: 44, height: 44).glassButton()
            }
            .buttonStyle(PressableStyle())
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .frame(height: 44).padding(.horizontal, 20).padding(.top, 8)
    }

    private var pager: some View {
        HStack(spacing: 6) {
            ForEach(styles.indices, id: \.self) { i in
                Capsule()
                    .fill(i == index ? AppColor.coral : AppColor.ink.opacity(0.2))
                    .frame(width: i == index ? 18 : 6, height: 6)
            }
        }
    }
}
