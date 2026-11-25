//
//  BeforeAfterSlider.swift
//  HomeDecor
//
//  Draggable before/after image comparison. Used on the Home hero, the
//  generation Result, and the fullscreen Compare screen.
//

import SwiftUI

struct BeforeAfterSlider: View {
    let before: Image
    let after: Image
    var beforeLabel: String = "before".localized
    var afterLabel: String = "after".localized
    var cornerRadius: CGFloat = AppRadius.lg
    var showLabels: Bool = true

    @State private var fraction: CGFloat = 0.5

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let splitX = max(0, min(w, w * fraction))

            ZStack(alignment: .topLeading) {
                after
                    .resizable()
                    .scaledToFill()

                before
                    .resizable()
                    .scaledToFill()
                    .mask(alignment: .leading) {
                        Rectangle().frame(width: splitX)
                    }

                if showLabels {
                    labelPill(beforeLabel, bg: AppColor.ink.opacity(0.65), fg: .white)
                        .padding(AppSpacing.sm)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    labelPill(afterLabel, bg: AppColor.coral, fg: .white)
                        .padding(AppSpacing.sm)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }

                handle(height: h)
                    .position(x: splitX, y: h / 2)
            }
            .frame(width: w, height: h)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        fraction = min(max(value.location.x / w, 0), 1)
                    }
            )
        }
    }

    private func labelPill(_ text: String, bg: Color, fg: Color) -> some View {
        Text(text)
            .font(.appLabel(12))
            .foregroundStyle(fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(bg, in: Capsule())
    }

    private func handle(height: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(.white.opacity(0.9))
                .frame(width: 2, height: height)
            Image(systemName: "arrow.left.and.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppColor.ink)
                .frame(width: 36, height: 36)
                .background(.white, in: Circle())
                .shadow(color: AppColor.ink.opacity(0.18), radius: 6, y: 2)
        }
    }
}

#if DEBUG
#Preview {
    ZStack {
        BlobBackground()
        BeforeAfterSlider(
            before: Image(systemName: "photo"),
            after: Image(systemName: "photo.fill")
        )
        .frame(height: 360)
        .padding()
    }
}
#endif
