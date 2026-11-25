//
//  CompareScreen.swift
//  HomeDecor
//
//  Create flow — Compare — Fullscreen (Figma 12:35932). A full-bleed draggable
//  Before/After slider over the whole screen, with a close + share (download)
//  overlay and a "Drag to compare" hint.
//

import SwiftUI
import Factory

struct CompareScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.createSession) private var session: CreateSession

    @State private var split: CGFloat = 0.5
    @State private var showShare = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack(alignment: .topLeading) {
                Color.black.ignoresSafeArea()

                // After (result)
                if let after = session.result {
                    Image(uiImage: after).resizable().scaledToFill()
                        .frame(width: w, height: h).clipped()
                }
                // Before (source), revealed on the left
                if let before = session.sourcePhoto {
                    Image(uiImage: before).resizable().scaledToFill()
                        .frame(width: w, height: h).clipped()
                        .mask(alignment: .leading) { Rectangle().frame(width: w * split) }
                }
                // Divider + handle
                Rectangle().fill(.white).frame(width: 2, height: h).offset(x: w * split - 1)
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1))
                    .offset(x: w * split - 26, y: h / 2 - 26)

                overlay(w)
            }
            .frame(width: w, height: h)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in split = min(1, max(0, v.location.x / w)) }
            )
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showShare) {
            if let img = session.result { ActivityView(items: [img]) }
        }
    }

    private func overlay(_ w: CGFloat) -> some View {
        VStack(spacing: 8) {
            HStack {
                Button { app.navi.pop() } label: {
                    Image(systemName: "xmark").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(.white.opacity(0.5), lineWidth: 1))
                }
                .buttonStyle(PressableStyle())
                Spacer()
                Button { showShare = true } label: {
                    Image(systemName: "square.and.arrow.up").font(.system(size: 17, weight: .medium)).foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(.white.opacity(0.5), lineWidth: 1))
                }
                .buttonStyle(PressableStyle())
            }
            HStack {
                chip("before".localized)
                Spacer()
                chip("after".localized)
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "arrow.left.arrow.right").font(.system(size: 12, weight: .semibold))
                Text("drag_to_compare".localized).font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14).frame(height: 34)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.5), lineWidth: 1))
        }
        .padding(.horizontal, 20)
        .padding(.top, 54)
        .padding(.bottom, 44)
        .frame(width: w, height: nil, alignment: .top)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func chip(_ text: String) -> some View {
        Text(text).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
            .padding(.horizontal, 14).frame(height: 32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.5), lineWidth: 1))
    }
}
