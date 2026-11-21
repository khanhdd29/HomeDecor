//
//  IntroView.swift
//  HomeDecor
//
//  Onboarding carousel (Coral Glass) — matches Figma nodes 13:38180..13:38348
//  (the "no ad" variant used by v1). Only the per-slide Visual lives inside the
//  paging TabView (fixed height); the title, dots and CTA sit outside it so the
//  Next/Start button stays tappable.
//

import SwiftUI
import ads_swift

struct IntroView: View {
    @EnvironmentObject private var coordinator: AppFlowCoordinator
    @State private var index = 0

    private let pages = IntroPage.all
    private var isLast: Bool { index == pages.count - 1 }

    private var showSkip: Bool {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return version == "1.0.0"
    }

    @State private var nativeIntro1VM: NativeAdViewModel?
    @State private var nativeIntro3VM: NativeAdViewModel?

    var body: some View {
        ZStack {
            BlobBackground()

            VStack(spacing: 0) {
                skipBar

                // Manual carousel — a plain DragGesture instead of a `.page`
                // TabView, which otherwise swallows taps meant for the CTA below.
                visual(index)
                    .frame(maxWidth: .infinity)
                    .frame(height: 440)
                    .id(index)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 24)
                            .onEnded { value in
                                if value.translation.width < -40 { goNext() }
                                else if value.translation.width > 40 { goPrev() }
                            }
                    )

                titleBlock

                Spacer(minLength: 12)

                footer
            }
            .animation(.easeInOut(duration: 0.25), value: index)
        }
        .onAppear { loadAds() }
        .trackScreen(.intro)
    }

    // MARK: - Text + footer

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(pages[index].title.localized)
                .font(.system(size: 38, weight: .bold))
                .tracking(-1.0)
                .foregroundStyle(AppColor.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(pages[index].message.localized)
                .font(.system(size: 15))
                .foregroundStyle(AppColor.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .animation(.easeInOut(duration: 0.2), value: index)
    }

    private var skipBar: some View {
        HStack {
            Spacer()
            Button("skip".localized) { coordinator.finishOnboarding() }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColor.inkSecondary)
                .opacity(showSkip && !isLast ? 1 : 0)
                .disabled(!showSkip || isLast)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .frame(height: 28)
    }

    private var footer: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(pages.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == index ? AppColor.coral : AppColor.ink.opacity(0.18))
                        .frame(width: i == index ? 24 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: index)
                }
            }

            Spacer()

            Button { advance() } label: {
                HStack(spacing: 12) {
                    Text((isLast ? "start" : "next").localized)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColor.ink)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(isLast ? AppColor.coral : AppColor.ink, in: Circle())
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableStyle())
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 22)
    }

    private func advance() {
        if isLast {
            coordinator.finishOnboarding()
        } else {
            index += 1
        }
    }

    private func goNext() { if index < pages.count - 1 { index += 1 } }
    private func goPrev() { if index > 0 { index -= 1 } }

    // MARK: - Per-slide visuals

    @ViewBuilder
    private func visual(_ i: Int) -> some View {
        switch i {
        case 0: slide1
        case 1: slide2
        case 2: slide3
        default: slide4
        }
    }

    private var slide1: some View {
        ZStack {
            orbit(300).offset(y: 14)
            polaroid("intro1_before", caption: "Before", dot: AppColor.inkTertiary, w: 150, h: 190)
                .rotationEffect(.degrees(-7)).offset(x: -66, y: -34)
            polaroid("intro1_after", caption: "After", dot: AppColor.coral, w: 150, h: 190)
                .rotationEffect(.degrees(6)).offset(x: 66, y: 40)
            sparkleBadge.offset(x: -2, y: -18)
        }
    }

    private var slide2: some View {
        ZStack {
            orbit(300).offset(y: 6)
            polaroid("intro2_office", caption: "Home office", dot: AppColor.inkTertiary, w: 196, h: 224)
                .rotationEffect(.degrees(4)).offset(x: 6, y: -6)

            Text("Design a cozy home office with warm wood tones")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 186, alignment: .leading)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(AppColor.ink, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .offset(x: 58, y: -170)

            HStack(alignment: .top, spacing: 10) {
                Image("logo").resizable().frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text("AI Designer").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColor.coral)
                    Text("Done! Walnut shelves, a brass desk lamp and a deep navy accent wall for a calm, focused mood.")
                        .font(.system(size: 13)).foregroundStyle(AppColor.ink)
                        .frame(width: 200, alignment: .leading)
                }
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(.white.opacity(0.9), lineWidth: 1))
            .shadow(color: Color(hex: 0x663824).opacity(0.12), radius: 10, y: 8)
            .offset(x: -26, y: 150)
        }
    }

    private var slide3: some View {
        ZStack {
            orbit(300)
            polaroid("intro3_modern", caption: "Modern", dot: AppColor.inkTertiary, w: 124, h: 160)
                .rotationEffect(.degrees(9)).offset(x: -92, y: 44)
            polaroid("intro3_tropical", caption: "Tropical", dot: AppColor.inkTertiary, w: 124, h: 160)
                .rotationEffect(.degrees(-9)).offset(x: 94, y: 16)
            polaroid("intro3_japandi", caption: "Japandi", dot: AppColor.coral, w: 148, h: 190)
                .offset(y: -42)
            coralChip("✦ Applied: Japandi").offset(y: 158)
        }
    }

    private var slide4: some View {
        ZStack {
            orbit(300)
            polaroid("intro4_artdeco", caption: "Art Deco Dining", dot: AppColor.inkTertiary, w: 170, h: 200)
                .rotationEffect(.degrees(7)).offset(x: -66, y: -18)
            polaroid("intro4_nordic", caption: "Nordic Kitchen", dot: AppColor.coral, w: 170, h: 200)
                .rotationEffect(.degrees(-6)).offset(x: 74, y: 58)
            glassChip(thumb: "intro4_artdeco", title: "Art Deco Dining", saves: "♥ 2.4k saves")
                .offset(x: 86, y: -156)
            glassChip(thumb: "intro4_nordic", title: "Nordic Kitchen", saves: "♥ 1.8k saves")
                .offset(x: -74, y: 120)
            coralChip("✦ Save to my board").offset(x: 40, y: 176)
        }
    }

    // MARK: - Reusable pieces

    private func polaroid(_ image: String, caption: String, dot: Color, w: CGFloat, h: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(image).resizable().scaledToFill()
                .frame(width: w, height: h)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            HStack(spacing: 6) {
                Circle().fill(dot).frame(width: 8, height: 8)
                Text(caption).font(.system(size: 14, weight: .semibold)).foregroundStyle(AppColor.ink)
            }
        }
        .padding(.horizontal, 10).padding(.top, 10).padding(.bottom, 14)
        .background(.white, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color(hex: 0x663824).opacity(0.18), radius: 17, x: 0, y: 18)
    }

    private var sparkleBadge: some View {
        Text("✦").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
            .frame(width: 52, height: 52)
            .background(AppGradient.coral, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(.white, lineWidth: 3))
            .shadow(color: AppColor.coral.opacity(0.4), radius: 9, y: 5)
    }

    private func coralChip(_ text: String) -> some View {
        Text(text).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(AppColor.coral, in: Capsule())
            .shadow(color: AppColor.coral.opacity(0.35), radius: 8, y: 4)
    }

    private func glassChip(thumb: String, title: String, saves: String) -> some View {
        HStack(spacing: 8) {
            Image(thumb).resizable().scaledToFill().frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(AppColor.ink)
                Text(saves).font(.system(size: 11, weight: .medium)).foregroundStyle(AppColor.coral)
            }
        }
        .padding(.leading, 8).padding(.trailing, 14).padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.9), lineWidth: 1))
        .shadow(color: Color(hex: 0x663824).opacity(0.12), radius: 10, y: 8)
    }

    private func orbit(_ size: CGFloat) -> some View {
        Circle()
            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [2, 8]))
            .foregroundStyle(AppColor.inkTertiary.opacity(0.3))
            .frame(width: size, height: size)
    }

    // MARK: - Ads (inert in v1)

    private func loadAds() {
        let c1 = AdUtil.config.nativeIntro1
        if c1.isEnable, nativeIntro1VM == nil {
            let vm = NativeAdViewModel(adUnitID: c1.id); vm.refreshAd(); nativeIntro1VM = vm
        }
        let c3 = AdUtil.config.nativeIntro3
        if c3.isEnable, nativeIntro3VM == nil {
            let vm = NativeAdViewModel(adUnitID: c3.id); vm.refreshAd(); nativeIntro3VM = vm
        }
    }
}

#if DEBUG
#Preview {
    IntroView().environmentObject(AppFlowCoordinator())
}
#endif
