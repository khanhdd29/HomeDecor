//
//  ResultScreen.swift
//  HomeDecor
//
//  Create flow — Result (Figma 12:34044 / Saved 12:34226). A draggable
//  Before/After slider (source photo vs AI render), style meta with regenerate
//  + share, and "Save to My look" which stores the render in LookStore (then
//  becomes "View in My look").
//

import SwiftUI
import Factory

struct ResultScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.createSession) private var session: CreateSession

    @State private var split: CGFloat = 0.5
    @State private var saved = false
    @State private var showShare = false
    @State private var showDiscard = false
    @State private var showRegen = false

    private let cardHeight: CGFloat = 440

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    beforeAfter
                    meta
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            saveCTA
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 34)
        }
        .background(BlobBackground().ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showShare) {
            if let img = session.result { ActivityView(items: [img]) }
        }
        .overlay { popupOverlay }
        .animation(.easeInOut(duration: 0.2), value: showDiscard)
        .animation(.easeInOut(duration: 0.2), value: showRegen)
    }

    @ViewBuilder
    private var popupOverlay: some View {
        if showDiscard {
            CoralPopup(
                icon: "trash.fill", badge: "xmark",
                title: "discard_title".localized, message: "discard_message".localized,
                primaryTitle: "keep_editing".localized, primaryAction: { showDiscard = false },
                secondaryTitle: "discard".localized,
                secondaryAction: { showDiscard = false; app.navi.pop() })
        } else if showRegen {
            CoralPopup(
                icon: "sparkles", badge: "arrow.clockwise",
                title: "regenerate_title".localized, message: "regenerate_message".localized,
                primaryTitle: "regenerate".localized,
                primaryAction: { showRegen = false; app.navi.pop(onComplete: { app.navi.push(.generating) }) },
                secondaryTitle: "cancel".localized, secondaryAction: { showRegen = false })
        }
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            Text("your_design".localized)
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
            HStack {
                Button { if saved { app.navi.pop() } else { showDiscard = true } } label: {
                    Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColor.ink).frame(width: 44, height: 44).glassButton()
                }
                .buttonStyle(PressableStyle())
                Spacer()
                Button {
                    app.navi.popToRoot(.root)
                    app.activeTab = .create
                } label: {
                    Image(systemName: "house").font(.system(size: 17, weight: .medium))
                        .foregroundStyle(AppColor.ink).frame(width: 44, height: 44).glassButton()
                }
                .buttonStyle(PressableStyle())
            }
        }
        .frame(height: 44).padding(.horizontal, 20).padding(.top, 8)
    }

    // MARK: Before / After slider

    private var beforeAfter: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                // After (result)
                if let after = session.result {
                    Image(uiImage: after).resizable().scaledToFill()
                        .frame(width: w, height: cardHeight).clipped()
                }
                // Before (source), revealed on the left
                if let before = session.sourcePhoto {
                    Image(uiImage: before).resizable().scaledToFill()
                        .frame(width: w, height: cardHeight).clipped()
                        .mask(alignment: .leading) { Rectangle().frame(width: w * split) }
                }
                // Divider + handle (tap to open fullscreen compare)
                Rectangle().fill(.white).frame(width: 2, height: cardHeight)
                    .offset(x: w * split - 1)
                Button { app.navi.push(.compare) } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1))
                }
                .buttonStyle(PressableStyle())
                .offset(x: w * split - 22, y: cardHeight / 2 - 22)

                chip("before".localized, bg: Color.white.opacity(0.22)).padding(11)
                chip("after".localized, bg: Color.white.opacity(0.22))
                    .frame(maxWidth: .infinity, alignment: .trailing).padding(11)
            }
            .frame(width: w, height: cardHeight)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in split = min(1, max(0, v.location.x / w)) }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppColor.ink.opacity(0.12), lineWidth: 1))
        }
        .frame(height: cardHeight)
    }

    private func chip(_ text: String, bg: Color) -> some View {
        Text(text).font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
            .padding(.horizontal, 14).frame(height: 30)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.5), lineWidth: 1))
    }

    // MARK: Meta

    private var meta: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.style?.name ?? "")
                    .font(.system(size: 20, weight: .bold)).foregroundStyle(AppColor.ink)
                Text("\(session.roomType) · \(session.isOutside ? "outside".localized : "inside".localized)")
                    .font(.system(size: 13)).foregroundStyle(AppColor.inkSecondary)
            }
            Spacer()
            iconButton("arrow.triangle.2.circlepath") { showRegen = true }
            iconButton("square.and.arrow.up") { showShare = true }
        }
    }

    private func iconButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon).font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColor.ink).frame(width: 44, height: 44).glassButton()
        }
        .buttonStyle(PressableStyle())
    }

    // MARK: Save CTA

    private var saveCTA: some View {
        Button {
            if saved {
                app.navi.popToRoot(.root)
                app.activeTab = .mylook
            } else if let img = session.result {
                try? LookStore.shared.add(img)
                saved = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: saved ? "checkmark" : "square.and.arrow.down").font(.system(size: 16, weight: .semibold))
                Text(saved ? "view_in_my_look".localized : "save_to_my_look".localized)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity).frame(height: 52)
            .background(AppColor.ink, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: Color(hex: 0x1A140F).opacity(0.18), radius: 10, x: 0, y: 8)
        }
        .buttonStyle(PressableStyle())
    }
}
