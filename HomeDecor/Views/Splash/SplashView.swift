//
//  SplashView.swift
//  HomeDecor
//
//  Coral Glass splash (matches Figma node 13:38678): warm blob background,
//  fanned room polaroids, orbit rings, coral logo, wordmark + real progress bar.
//  The `configAds()` launch sequence below is unchanged (ads stay inert in v1).
//

import SwiftUI
import ads_swift
import GoogleMobileAds
import AppTrackingTransparency

private enum SplashStep: Equatable {
    case idle, fetchingConfig, initializingAds, requestingConsent, showingInter, completed

    var progress: Double {
        switch self {
        case .idle:              return 0.05
        case .fetchingConfig:    return 0.25
        case .initializingAds:   return 0.5
        case .requestingConsent: return 0.7
        case .showingInter:      return 0.9
        case .completed:         return 1.0
        }
    }
}

struct SplashView: View {
    @EnvironmentObject private var coordinator: AppFlowCoordinator
    @Environment(\.colorScheme) private var colorScheme
    @State private var appeared = false
    @State private var didStart = false
    @State private var step: SplashStep = .idle

    var body: some View {
        ZStack {
            BlobBackground()

            VStack(spacing: 0) {
                Spacer().frame(height: 56)

                polaroidCluster
                    .scaleEffect(appeared ? 1 : 0.92)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 30)

                Image("logo")
                    .resizable()
                    .frame(width: 104, height: 104)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: AppColor.coralGradBot.opacity(0.42), radius: 18, x: 0, y: 14)
                    .scaleEffect(appeared ? 1 : 0.7)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 22)

                Text("HOME DECOR")
                    .font(.system(size: 28, weight: .bold))
                    .tracking(4)
                    .foregroundStyle(AppColor.ink)

                Text("splash_tagline".localized)
                    .font(.system(size: 15))
                    .foregroundStyle(AppColor.inkSecondary)
                    .padding(.top, 8)

                Spacer()

                VStack(spacing: 10) {
                    Text("\("loading".localized) \(Int(step.progress * 100))%")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColor.ink)
                        .contentTransition(.numericText())

                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 220, height: 6)
                        Capsule()
                            .fill(AppGradient.coral)
                            .frame(width: 220 * step.progress, height: 6)
                    }
                    .animation(.easeInOut(duration: 0.3), value: step)
                }
                .padding(.bottom, 70)
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) { appeared = true }
        }
        .task {
            guard !didStart else { return }
            didStart = true
            await configAds()
        }
        .trackScreen(.splash)
    }

    // MARK: - Decoration

    private var polaroidCluster: some View {
        ZStack {
            orbit(320).offset(y: 6)
            orbit(220).offset(x: -4, y: 10)

            polaroid("splash_room_1")
                .rotationEffect(.degrees(14))
                .offset(x: -92, y: 36)
            polaroid("splash_room_3")
                .rotationEffect(.degrees(-12))
                .offset(x: 92, y: 22)
            polaroid("splash_room_2")   // front, centered
        }
        .frame(height: 260)
    }

    private func polaroid(_ name: String) -> some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(.white)
            .frame(width: 166, height: 202)
            .overlay(
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 186)
                    .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
            )
            .shadow(color: Color(hex: 0x663824).opacity(0.18), radius: 17, x: 0, y: 18)
    }

    private func orbit(_ size: CGFloat) -> some View {
        Circle()
            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [2, 8]))
            .foregroundStyle(AppColor.inkTertiary.opacity(0.35))
            .frame(width: size, height: size)
    }
}

// MARK: - Ad initialization sequence (ORDER is load-bearing — unchanged)

private extension SplashView {

    func configAds() async {
        // v1 ships without ads: skip the ad-SDK init, the ATT tracking prompt
        // and the UMP consent flow entirely. Just play the splash progress and
        // continue. Flip `AppFeatures.adsEnabled` to re-enable the full flow.
        guard AppFeatures.adsEnabled else {
            await runAdlessSplash()
            return
        }

        step = .fetchingConfig
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            RemoteConfigManager.shared.fetchAndActivate { cont.resume() }
        }

        step = .initializingAds
        AdsManager.shared.initialize(
            intervalShowInter: RemoteConfigManager.shared.adConfig.intervalShowInter,
            nativeAdColorConfig: Self.nativeAdColorConfig(for: colorScheme)
        )

        AdjustManager.shared.initialize()
        #if DEBUG
        setTestDeviceIdentifiers()
        #endif

        let useInterSplash = RemoteConfigManager.shared.adConfig.useInterSplash
        let openSplashConfig = AdUtil.config.openOnResumeSplash
        if !useInterSplash && openSplashConfig.isEnable {
            AdsManager.shared.initAppOpenAd(
                appOpenAdUnitId: openSplashConfig.id,
                opacity: openSplashConfig.opacity,
                autoEnable: false
            )
        }

        step = .requestingConsent
        await requestConsent()

        step = .showingInter
        if useInterSplash {
            await showInterSplash()
        } else {
            await showOpenSplash(config: openSplashConfig)
        }

        let appOpen = AdUtil.config.appopenResume
        if appOpen.isEnable {
            AdsManager.shared.initAppOpenAd(
                appOpenAdUnitId: appOpen.id,
                opacity: appOpen.opacity,
                autoEnable: false
            )
        }

        step = .completed
        AdsManager.shared.appLifecycleReactor?.setShouldShow(true)
        InterHomeUtil.instance.preload()
        coordinator.splashDidFinish()
    }

    /// Ad-free launch for v1: animate the splash progress bar to 100% over a
    /// short, intentional beat, then hand off. No ad SDK, no ATT, no consent.
    func runAdlessSplash() async {
        for beat in [SplashStep.fetchingConfig, .initializingAds, .requestingConsent, .showingInter] {
            step = beat
            try? await Task.sleep(nanoseconds: 280_000_000)
        }
        step = .completed
        try? await Task.sleep(nanoseconds: 200_000_000)
        coordinator.splashDidFinish()
    }

    func requestConsent() async {
        AdsManager.shared.appLifecycleReactor?.setIsExcludeScreen(true)
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            ATTrackingManager.requestTrackingAuthorization { _ in cont.resume() }
        }
        await UMPManager.shared.requestConsentIfNeeded()
        AdsManager.shared.appLifecycleReactor?.setIsExcludeScreen(false)
    }

    func showInterSplash() async {
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            AdUtil.showInter(config: AdUtil.config.interSplash) { cont.resume() }
        }
    }

    func showOpenSplash(config: AdUnitConfig) async {
        await withCheckedContinuation { cont in
            AdUtil.showOpen(config: config) { cont.resume() }
        }
    }

    func setTestDeviceIdentifiers() {
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = []
    }

    static func nativeAdColorConfig(for scheme: ColorScheme) -> NativeAdColorConfig {
        let adBadge: UIColor = scheme == .dark ? .tertiaryLabel : .secondaryLabel
        return NativeAdColorConfig(
            headlineColor: Color(uiColor: .label),
            bodyColor: Color(uiColor: .secondaryLabel),
            adColor: Color(uiColor: adBadge),
            adBackgroundColor: Color(uiColor: .secondarySystemGroupedBackground),
            callToActionBackgroundColor: .accentColor,
            callToActionTextColor: .white,
            backgroundColor: Color(uiColor: .systemBackground)
        )
    }
}

#if DEBUG
#Preview {
    SplashView().environmentObject(AppFlowCoordinator())
}
#endif
