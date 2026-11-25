//
//  GeneratingScreen.swift
//  HomeDecor
//
//  Create flow — Generating (Figma 12:33861 / Done 12:35738). A scanning
//  preview of the room with a sweeping coral line, a fake 3-step progress
//  (Analyzing → Applying → Rendering), then navigates to Result.
//
//  Real generation runs through `artMagic.generate(photo:code:)` when the
//  selected style carries a template code and Code12 credentials are set;
//  otherwise it falls back to a mock render (the style's catalog image) so the
//  flow is usable before credentials arrive.
//

import SwiftUI
import Factory

struct GeneratingScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.createSession) private var session: CreateSession

    @State private var progress: Double = 0
    @State private var scan: CGFloat = 0
    @State private var work: Task<Void, Never>?
    @State private var showStop = false
    @State private var failure: GenFailure?

    private enum GenFailure { case failed, noInternet }

    private let cardHeight: CGFloat = 340

    private var stepIndex: Int { progress < 0.3 ? 0 : (progress < 0.85 ? 1 : 2) }

    private var steps: [String] {
        [ "step_analyzing".localized,
          String(format: "step_applying".localized, session.style?.name ?? ""),
          "step_rendering".localized ]
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    scanningPhoto
                    status
                    progressBar
                    stepsCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .background(BlobBackground().ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .overlay { popupOverlay }
        .animation(.easeInOut(duration: 0.2), value: showStop)
        .animation(.easeInOut(duration: 0.2), value: failure != nil)
        .onAppear { start() }
        .onDisappear { work?.cancel() }
    }

    @ViewBuilder
    private var popupOverlay: some View {
        if showStop {
            CoralPopup(
                icon: "stop.fill", badge: "hourglass",
                title: "stop_title".localized, message: "stop_message".localized,
                primaryTitle: "keep_waiting".localized, primaryAction: { showStop = false },
                secondaryTitle: "stop".localized,
                secondaryAction: { showStop = false; work?.cancel(); app.navi.pop() })
        } else if let failure {
            let noNet = failure == .noInternet
            CoralPopup(
                icon: noNet ? "wifi.slash" : "exclamationmark.triangle.fill", badge: "arrow.clockwise",
                title: (noNet ? "no_internet_title" : "gen_failed_title").localized,
                message: (noNet ? "no_internet_message" : "gen_failed_message").localized,
                primaryTitle: "try_again".localized,
                primaryAction: { self.failure = nil; progress = 0; work?.cancel(); work = Task { await run() } },
                secondaryTitle: "cancel".localized,
                secondaryAction: { self.failure = nil; app.navi.pop() },
                horizontal: true)
        }
    }

    // MARK: Header (close)

    private var header: some View {
        ZStack {
            Text("generating".localized)
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
            HStack {
                Button { showStop = true } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(AppColor.ink)
                        .frame(width: 44, height: 44).glassButton()
                }
                .buttonStyle(PressableStyle())
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .frame(height: 44).padding(.horizontal, 20).padding(.top, 8)
    }

    // MARK: Scanning photo

    private var scanningPhoto: some View {
        ZStack(alignment: .top) {
            Color.clear.frame(maxWidth: .infinity).frame(height: cardHeight)
                .overlay(
                    Group {
                        if let p = session.sourcePhoto { Image(uiImage: p).resizable().scaledToFill() }
                    }
                )
                .overlay(Color(hex: 0x1A1412).opacity(0.22))
                .overlay(alignment: .top) {
                    LinearGradient(colors: [AppColor.coral.opacity(0), AppColor.coral.opacity(0.22)],
                                   startPoint: .top, endPoint: .bottom)
                        .frame(height: 120)
                        .offset(y: scan * (cardHeight - 2) - 120)
                }
                .overlay(alignment: .top) {
                    Rectangle().fill(AppColor.coral).frame(height: 2)
                        .shadow(color: Color(hex: 0xE2C48E).opacity(0.9), radius: 8)
                        .offset(y: scan * (cardHeight - 2))
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(AppColor.coral.opacity(0.35), lineWidth: 1))

            // Chip: style · room
            HStack(spacing: 6) {
                Image(systemName: "sparkles").font(.system(size: 11, weight: .semibold))
                Text("\(session.style?.name ?? "") · \(session.roomType)")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14).frame(height: 30)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.5), lineWidth: 1))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(11)
        }
        .frame(height: cardHeight)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) { scan = 1 }
        }
    }

    // MARK: Status + progress

    private var status: some View {
        VStack(spacing: 6) {
            Text("generating_title".localized).font(.system(size: 22, weight: .bold)).foregroundStyle(AppColor.ink)
            Text("generating_subtitle".localized).font(.system(size: 14)).foregroundStyle(AppColor.inkSecondary)
        }
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(steps[stepIndex]).font(.system(size: 13, weight: .medium)).foregroundStyle(AppColor.ink.opacity(0.8))
                    .lineLimit(1)
                Spacer()
                Text("\(Int(progress * 100))%").font(.system(size: 13, weight: .semibold)).foregroundStyle(AppColor.coral)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppColor.ink.opacity(0.08))
                    Capsule().fill(AppColor.coral).frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 6)
        }
    }

    private var stepsCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { idx, label in
                HStack(spacing: 12) {
                    stepMark(idx)
                    Text(label)
                        .font(.system(size: 14, weight: idx == stepIndex ? .semibold : .regular))
                        .foregroundStyle(idx <= stepIndex ? AppColor.ink : AppColor.inkSecondary)
                        .lineLimit(1)
                    Spacer()
                }
                .frame(height: 44)
                if idx < steps.count - 1 {
                    Rectangle().fill(AppColor.ink.opacity(0.08)).frame(height: 1)
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 6)
        .glassPanel(28)
    }

    @ViewBuilder
    private func stepMark(_ idx: Int) -> some View {
        if idx < stepIndex {
            Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(AppColor.coral, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        } else if idx == stepIndex {
            RoundedRectangle(cornerRadius: 4).fill(AppColor.coral).frame(width: 8, height: 8)
                .frame(width: 22, height: 22)
                .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(AppColor.coral, lineWidth: 2))
        } else {
            RoundedRectangle(cornerRadius: 11).strokeBorder(AppColor.ink.opacity(0.12), lineWidth: 1)
                .frame(width: 22, height: 22)
        }
    }

    // MARK: Generation

    private func start() {
        guard work == nil else { return }
        work = Task { await run() }
    }

    @MainActor
    private func run() async {
        // Kick off the real render in the background when a template code +
        // credentials are available (URL + String are Sendable; the UIImage is
        // produced inside the detached task and awaited back).
        let code = session.style?.templateCode
        let file: URL? = session.sourcePhoto.flatMap { try? PhotoTools.jpegFile($0) }
        let realTask: Task<UIImage?, Error>? = (code != nil && file != nil)
            ? Task.detached { try await Container.shared.artMagic().generate(photo: file!, code: code!) }
            : nil

        // Animate the fake progress over ~5s.
        let ticks = 60
        for i in 0...ticks {
            if Task.isCancelled { realTask?.cancel(); return }
            progress = Double(i) / Double(ticks)
            try? await Task.sleep(nanoseconds: 85_000_000)
        }
        if Task.isCancelled { return }

        if let realTask {
            // Real generation: surface failures as popups rather than silently
            // falling back.
            do {
                let img = try await realTask.value
                if Task.isCancelled { return }
                finish(with: img)
            } catch is CancellationError {
                return
            } catch {
                if Task.isCancelled { return }
                let noNet = (error as? URLError)?.code == .notConnectedToInternet
                failure = noNet ? .noInternet : .failed
            }
        } else {
            // No credentials yet → mock render so the flow is usable.
            finish(with: nil)
        }
    }

    @MainActor
    private func finish(with image: UIImage?) {
        let after = image
            ?? session.style.flatMap { UIImage(named: $0.image) }
            ?? session.sourcePhoto
        session.result = after
        app.navi.pop(onComplete: { app.navi.push(.result) })
    }
}
