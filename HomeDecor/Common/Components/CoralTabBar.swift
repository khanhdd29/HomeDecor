//
//  CoralTabBar.swift
//  HomeDecor
//
//  Floating glass tab bar (Figma 10:2199) + AI Chat FAB (Figma 12:32998).
//

import SwiftUI

struct CoralTabBar: View {
    @Binding var selection: HomeTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                item(tab)
            }
        }
        .padding(.horizontal, 6)
        .frame(height: 68)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 34, style: .continuous).strokeBorder(.white.opacity(0.8), lineWidth: 1))
        .shadow(color: Color(hex: 0x4D3326).opacity(0.1), radius: 15, x: 0, y: 10)
    }

    private func item(_ tab: HomeTab) -> some View {
        let active = tab == selection
        return Button {
            selection = tab
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: active ? .semibold : .regular))
                Text(tab.title)
                    .font(.system(size: 11, weight: active ? .semibold : .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(active ? AppColor.coral : AppColor.inkSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(active ? Color.white : Color.clear,
                       in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: active ? Color(hex: 0x4D3326).opacity(0.08) : .clear,
                    radius: active ? 12 : 0, x: 0, y: 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle())
    }
}

/// Floating coral AI-chat button (Figma 12:32998). Rebuilt natively so it reads
/// as a clean floating circle — a coral gradient avatar with a soft radial glow
/// (real circular shadow, not a baked square) and a green online dot.
struct AIChatFAB: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                AIAvatarView()
                    .shadow(color: AppColor.coral.opacity(0.45), radius: 14, x: 0, y: 6)
                    .shadow(color: AppColor.coral.opacity(0.22), radius: 26, x: 0, y: 12)
                onlineDot
                    .offset(x: 25, y: 25)
            }
            .frame(width: 64, height: 64)
            .contentShape(Circle())
        }
        .buttonStyle(PressableStyle())
    }

    private var onlineDot: some View {
        ZStack {
            Circle().fill(.white).frame(width: 18, height: 18)
            Circle().fill(Color(hex: 0x4DCC80)).frame(width: 13.5, height: 13.5)
        }
    }
}

/// Coral AI avatar (Figma 12:33003) rebuilt natively: a coral gradient circle
/// with a glossy top highlight, a thin light rim, and the white chevron +
/// sparkle glyph. Drawn 1:1 in the Figma 64×64 coordinate space.
struct AIAvatarView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [Color(hex: 0xFFA880), Color(hex: 0xE04229)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))

            // Glossy top highlight (Figma "Highlight" blurred ellipse).
            Ellipse()
                .fill(.white.opacity(0.28))
                .frame(width: 44, height: 21)
                .blur(radius: 6)
                .offset(y: -19)
        }
        .frame(width: 64, height: 64)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(.white.opacity(0.9), lineWidth: 1.94))
        .overlay(AIGlyph())
    }
}

/// White chevron + two sparkles, traced from the Figma "Symbol" vector paths
/// and drawn in a Canvas so all three keep their exact relative positions.
private struct AIGlyph: View {
    var body: some View {
        Canvas { ctx, _ in
            ctx.stroke(chevron, with: .color(.white),
                       style: StrokeStyle(lineWidth: 2.909, lineCap: .round, lineJoin: .round))
            ctx.fill(bigStar, with: .color(.white))
            ctx.fill(smallStar, with: .color(.white.opacity(0.85)))
        }
        .frame(width: 64, height: 64)
        .shadow(color: Color(hex: 0x992608).opacity(0.22), radius: 1.4, x: 0, y: 1)
    }

    private var chevron: Path {
        var p = Path()
        p.move(to: CGPoint(x: 17.4545, y: 30.0606))
        p.addLine(to: CGPoint(x: 32, y: 18.4242))
        p.addLine(to: CGPoint(x: 46.5455, y: 30.0606))
        return p
    }

    private var bigStar: Path {
        var s = Path()
        s.move(to: CGPoint(x: 32, y: 26.1818))
        s.addCurve(to: CGPoint(x: 39.7576, y: 33.9394),
                   control1: CGPoint(x: 32.7758, y: 31.5152), control2: CGPoint(x: 34.4242, y: 33.2121))
        s.addCurve(to: CGPoint(x: 32, y: 41.697),
                   control1: CGPoint(x: 34.4242, y: 34.6667), control2: CGPoint(x: 32.7758, y: 36.3636))
        s.addCurve(to: CGPoint(x: 24.2424, y: 33.9394),
                   control1: CGPoint(x: 31.2242, y: 36.3636), control2: CGPoint(x: 29.5758, y: 34.6667))
        s.addCurve(to: CGPoint(x: 32, y: 26.1818),
                   control1: CGPoint(x: 29.5758, y: 33.2121), control2: CGPoint(x: 31.2242, y: 31.5152))
        s.closeSubpath()
        return s
    }

    private var smallStar: Path {
        var s = Path()
        s.move(to: CGPoint(x: 41.697, y: 36.8485))
        s.addCurve(to: CGPoint(x: 44.8485, y: 40),
                   control1: CGPoint(x: 42.0364, y: 39.0303), control2: CGPoint(x: 42.6667, y: 39.6606))
        s.addCurve(to: CGPoint(x: 41.697, y: 43.1515),
                   control1: CGPoint(x: 42.6667, y: 40.3394), control2: CGPoint(x: 42.0364, y: 40.9697))
        s.addCurve(to: CGPoint(x: 38.5455, y: 40),
                   control1: CGPoint(x: 41.3576, y: 40.9697), control2: CGPoint(x: 40.7273, y: 40.3394))
        s.addCurve(to: CGPoint(x: 41.697, y: 36.8485),
                   control1: CGPoint(x: 40.7273, y: 39.6606), control2: CGPoint(x: 41.3576, y: 39.0303))
        s.closeSubpath()
        return s
    }
}

#if DEBUG
private struct CoralTabBarPreview: View {
    @State private var tab: HomeTab = .create
    var body: some View {
        ZStack(alignment: .bottom) {
            BlobBackground()
            ZStack(alignment: .topTrailing) {
                CoralTabBar(selection: $tab)
                AIChatFAB(action: {}).offset(x: -4, y: -56)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
}
#Preview { CoralTabBarPreview() }
#endif
