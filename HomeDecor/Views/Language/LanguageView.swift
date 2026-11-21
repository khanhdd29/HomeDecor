//
//  LanguageView.swift
//  HomeDecor
//
//  Coral Glass language picker (matches Figma node 10:23507 / settings 10:29655).
//  16 languages, glass rows with circular flag + native/English name + radio.
//  The back button shows ONLY when opened from Settings.
//

import SwiftUI
import ads_swift
import Factory

struct LanguageView: View {

    enum Mode { case onboarding, settings }

    let mode: Mode

    @EnvironmentObject private var coordinator: AppFlowCoordinator
    @Injected(\.app) private var app

    @State private var hasChosen = false
    @State private var originalLanguage: AppLanguage = .deviceDefault
    @Namespace private var guideNS

    @State private var nativeLanguageVM: NativeAdViewModel?
    @State private var nativeLanguageSelectVM: NativeAdViewModel?
    @State private var nativeAllVM: NativeAdViewModel?

    init(mode: Mode = .onboarding) { self.mode = mode }

    private let guideLanguage: AppLanguage = .english
    private var isGuiding: Bool { mode == .onboarding }
    private var showRowGuide: Bool { isGuiding && !hasChosen }
    private var canConfirm: Bool { hasChosen }

    private var currentAdVM: NativeAdViewModel? {
        if mode == .settings { return nativeAllVM }
        return hasChosen ? nativeLanguageSelectVM : nativeLanguageVM
    }

    var body: some View {
        ZStack {
            BlobBackground()

            VStack(spacing: 0) {
                header

                Text("please_select_language".localized)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColor.ink.opacity(0.55))
                    .padding(.bottom, 14)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(AppLanguage.allCases) { language in
                            row(for: language)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }

                if let vm = currentAdVM {
                    NativeContentView(nativeViewModel: vm, style: .nativeNormalMediaCtaTop)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .onAppear {
            originalLanguage = coordinator.language
            if mode == .settings { hasChosen = true }
            loadAds()
        }
        .trackScreen(mode == .onboarding ? .language : .settingsLanguage)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("language".localized)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColor.ink)

            HStack {
                if mode == .settings {
                    Button { cancel() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppColor.ink)
                            .frame(width: 24, height: 24)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(width: 24, height: 24)
                }

                Spacer()

                Button { confirm() } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(canConfirm ? AppColor.coral : AppColor.inkTertiary.opacity(0.4))
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!canConfirm)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .padding(.top, 8)
    }

    // MARK: - Row

    private func row(for language: AppLanguage) -> some View {
        let isSelected = hasChosen && coordinator.language == language
        return Button {
            select(language)
        } label: {
            HStack(spacing: 12) {
                Image(language.flagAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 1) {
                    Text(language.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColor.ink)
                    if let english = language.englishName {
                        Text(english)
                            .font(.system(size: 11))
                            .foregroundStyle(AppColor.ink.opacity(0.55))
                    }
                }

                Spacer()

                radio(isSelected)
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(isSelected ? AppColor.coral : AppColor.glassStroke,
                                  lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: Color(hex: 0x593826).opacity(0.07), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .trailing) {
            if showRowGuide && language == guideLanguage {
                tapGuide.offset(x: -6, y: 0)
            }
        }
    }

    private func radio(_ on: Bool) -> some View {
        ZStack {
            Circle()
                .strokeBorder(on ? AppColor.coral : AppColor.inkTertiary.opacity(0.45), lineWidth: 2)
                .frame(width: 22, height: 22)
            if on {
                Circle().fill(AppColor.coral).frame(width: 12, height: 12)
            }
        }
    }

    // MARK: - Ads (inert in v1)

    private func loadAds() {
        if mode == .settings {
            let all = AdUtil.config.nativeAll
            if all.isEnable, nativeAllVM == nil {
                let vm = NativeAdViewModel(adUnitID: all.id); vm.refreshAd(); nativeAllVM = vm
            }
            return
        }
        let initial = AdUtil.config.nativeLanguage
        if initial.isEnable, nativeLanguageVM == nil {
            let vm = NativeAdViewModel(adUnitID: initial.id); vm.refreshAd(); nativeLanguageVM = vm
        }
        let postSelect = AdUtil.config.nativeLanguageSelect
        if postSelect.isEnable, nativeLanguageSelectVM == nil {
            let vm = NativeAdViewModel(adUnitID: postSelect.id); vm.refreshAd(); nativeLanguageSelectVM = vm
        }
    }

    // MARK: - Actions

    private func select(_ language: AppLanguage) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            hasChosen = true
            coordinator.updateLanguage(language)
        }
    }

    private func confirm() {
        guard hasChosen else { return }
        switch mode {
        case .onboarding: coordinator.didSelectLanguage(coordinator.language)
        case .settings:   app.navi.pop()
        }
    }

    private func cancel() {
        if coordinator.language != originalLanguage {
            coordinator.updateLanguage(originalLanguage)
        }
        app.navi.pop()
    }

    private var tapGuide: some View {
        LottieTapView(name: "tap", tint: AppColor.coral)
            .frame(width: 64, height: 64)
            .clipped()
            .allowsHitTesting(false)
            .matchedGeometryEffect(id: "tapGuide", in: guideNS)
    }
}

#if DEBUG
#Preview("Onboarding") {
    LanguageView(mode: .onboarding).environmentObject(AppFlowCoordinator())
}
#Preview("Settings") {
    LanguageView(mode: .settings).environmentObject(AppFlowCoordinator())
}
#endif
