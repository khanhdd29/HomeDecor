//
//  AdjustPhotoScreen.swift
//  HomeDecor
//
//  Create flow — Adjust Photo (Figma 12:35171). Pan/zoom the captured photo
//  behind a fixed crop box (ratio chips), with a dimmed outside, rule-of-thirds
//  grid and coral corner handles. Done renders the crop and hands it back as the
//  source photo.
//

import SwiftUI
import Factory

struct AdjustPhotoScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.createSession) private var session: CreateSession

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var ratio: CropRatio = .r3x4
    @State private var areaSize: CGSize = .zero

    enum CropRatio: CaseIterable, Identifiable {
        case original, r1x1, r3x4, r4x3
        var id: Self { self }
        var label: String {
            switch self {
            case .original: return "ratio_original".localized
            case .r1x1: return "1:1"; case .r3x4: return "3:4"; case .r4x3: return "4:3"
            }
        }
        func value(_ image: UIImage?) -> CGFloat {
            switch self {
            case .original:
                let s = image?.size ?? CGSize(width: 3, height: 4)
                return max(0.2, s.width / max(1, s.height))
            case .r1x1: return 1
            case .r3x4: return 3.0 / 4.0
            case .r4x3: return 4.0 / 3.0
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            GeometryReader { geo in
                let size = geo.size
                let box = cropSize(size)
                ZStack {
                    imageLayer(size)
                    Rectangle().fill(.black.opacity(0.45))
                        .reverseMask { Rectangle().frame(width: box.width, height: box.height) }
                    CropBox().frame(width: box.width, height: box.height)
                }
                .frame(width: size.width, height: size.height)
                .clipped()
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { v in offset = CGSize(width: lastOffset.width + v.translation.width,
                                                          height: lastOffset.height + v.translation.height) }
                        .onEnded { _ in lastOffset = offset }
                        .simultaneously(with:
                            MagnificationGesture()
                                .onChanged { m in scale = min(4, max(1, lastScale * m)) }
                                .onEnded { _ in lastScale = scale })
                )
                .onAppear { areaSize = size }
                .onChange(of: size) { areaSize = $0 }
            }

            bottom
        }
        .background(BlobBackground().ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            Text("adjust_photo".localized)
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColor.ink)
            HStack {
                Button { app.navi.pop() } label: {
                    Image(systemName: "xmark").font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.ink).frame(width: 44, height: 44).glassButton()
                }
                .buttonStyle(PressableStyle())
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .frame(height: 44).padding(.horizontal, 20).padding(.top, 8)
    }

    @ViewBuilder
    private func imageLayer(_ size: CGSize) -> some View {
        if let raw = session.captured {
            Image(uiImage: raw).resizable().scaledToFill()
                .frame(width: size.width, height: size.height)
                .scaleEffect(scale)
                .offset(offset)
        }
    }

    private func cropSize(_ size: CGSize) -> CGSize {
        let r = ratio.value(session.captured)
        let availW = max(1, size.width - 60), availH = max(1, size.height - 48)
        var bw = availW, bh = bw / r
        if bh > availH { bh = availH; bw = bh * r }
        return CGSize(width: bw, height: bh)
    }

    // MARK: Bottom

    private var bottom: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(CropRatio.allCases) { r in
                    Button { ratio = r } label: {
                        Text(r.label)
                            .font(.system(size: 13, weight: ratio == r ? .semibold : .medium))
                            .foregroundStyle(ratio == r ? AppColor.coral : AppColor.ink)
                            .padding(.horizontal, 14).frame(height: 32)
                            .glassPanel(16)
                    }
                    .buttonStyle(PressableStyle())
                }
            }
            HStack(spacing: 12) {
                Button { scale = 1; lastScale = 1; offset = .zero; lastOffset = .zero } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise").font(.system(size: 15, weight: .medium))
                        Text("reset".localized).font(.system(size: 15, weight: .medium))
                    }
                    .foregroundStyle(AppColor.ink)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(AppColor.ink.opacity(0.06), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                }
                .buttonStyle(PressableStyle())

                Button { done() } label: {
                    Text("done".localized).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(AppColor.ink, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                }
                .buttonStyle(PressableStyle())
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 16)
        .padding(.bottom, 34)
    }

    // MARK: Crop

    @MainActor
    private func done() {
        guard let raw = session.captured, areaSize.width > 0 else { app.navi.pop(last: 2); return }
        let box = cropSize(areaSize)
        let content = Color.black
            .frame(width: areaSize.width, height: areaSize.height)
            .overlay(imageLayer(areaSize))
            .frame(width: areaSize.width, height: areaSize.height)
            .clipped()
        let renderer = ImageRenderer(content: content)
        let s = UIScreen.main.scale
        renderer.scale = s
        if let full = renderer.uiImage {
            let origin = CGPoint(x: (areaSize.width - box.width) / 2, y: (areaSize.height - box.height) / 2)
            let rect = CGRect(x: origin.x * s, y: origin.y * s, width: box.width * s, height: box.height * s)
            session.sourcePhoto = PhotoTools.normalized(PhotoTools.cropped(full, to: rect))
        } else {
            session.sourcePhoto = raw
        }
        session.captured = nil
        app.navi.pop(last: 2)
    }
}

/// White-bordered crop box with a thirds grid and coral corner handles.
private struct CropBox: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let len: CGFloat = 20
            ZStack {
                Rectangle().strokeBorder(.white.opacity(0.9), lineWidth: 1)
                Path { p in
                    p.move(to: CGPoint(x: w/3, y: 0));   p.addLine(to: CGPoint(x: w/3, y: h))
                    p.move(to: CGPoint(x: 2*w/3, y: 0)); p.addLine(to: CGPoint(x: 2*w/3, y: h))
                    p.move(to: CGPoint(x: 0, y: h/3));   p.addLine(to: CGPoint(x: w, y: h/3))
                    p.move(to: CGPoint(x: 0, y: 2*h/3)); p.addLine(to: CGPoint(x: w, y: 2*h/3))
                }.stroke(.white.opacity(0.35), lineWidth: 1)
                Path { p in
                    p.move(to: CGPoint(x: 0, y: len)); p.addLine(to: CGPoint(x: 0, y: 0)); p.addLine(to: CGPoint(x: len, y: 0))
                    p.move(to: CGPoint(x: w-len, y: 0)); p.addLine(to: CGPoint(x: w, y: 0)); p.addLine(to: CGPoint(x: w, y: len))
                    p.move(to: CGPoint(x: 0, y: h-len)); p.addLine(to: CGPoint(x: 0, y: h)); p.addLine(to: CGPoint(x: len, y: h))
                    p.move(to: CGPoint(x: w-len, y: h)); p.addLine(to: CGPoint(x: w, y: h)); p.addLine(to: CGPoint(x: w, y: h-len))
                }.stroke(AppColor.coral, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            }
        }
    }
}

private extension View {
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask {
            Rectangle().overlay(mask().blendMode(.destinationOut))
        }
    }
}
