//
//  GlassPanel.swift
//  HomeDecor
//
//  Coral Glass panel background used across the Create flow and cards:
//  frosted fill + light rim + soft warm shadow. Matches Figma's
//  `rgba(255,255,255,0.6)` + `rgba(255,255,255,0.8)` border + blur.
//

import SwiftUI

extension View {
    func glassPanel(_ radius: CGFloat = 28, dashed: Bool = false) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(.white.opacity(0.8),
                                  style: StrokeStyle(lineWidth: 1, dash: dashed ? [6, 5] : []))
            )
            .shadow(color: Color(hex: 0x593826).opacity(0.07), radius: 12, x: 0, y: 8)
    }
}
