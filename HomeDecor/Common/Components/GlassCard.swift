//
//  GlassCard.swift
//  HomeDecor
//
//  Frosted "Coral Glass" surface. Two entry points:
//   • `.glassCard()`      — applies the surface to any view (caller pads).
//   • `GlassCard { ... }`  — a padded container.
//

import SwiftUI

extension View {
    /// Wraps the view in the frosted glass surface (frost + hairline + soft shadow).
    func glassCard(cornerRadius: CGFloat = AppRadius.md,
                   strokeOpacity: Double = 1.0) -> some View {
        self
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(AppColor.glassStroke.opacity(strokeOpacity), lineWidth: 1)
            )
            .shadow(color: AppColor.ink.opacity(0.06), radius: 18, x: 0, y: 10)
    }
}

/// A padded frosted-glass container.
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = AppRadius.md
    var padding: CGFloat = AppSpacing.md
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(cornerRadius: cornerRadius)
    }
}

#if DEBUG
#Preview {
    ZStack {
        BlobBackground()
        VStack(spacing: 20) {
            GlassCard {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Glass card").font(.appHeading())
                    Text("Frosted surface with a hairline border.")
                        .font(.subheadline)
                        .foregroundStyle(AppColor.inkSecondary)
                }
            }

            Text("Chip")
                .font(.appLabel(14))
                .padding(.horizontal, 14).padding(.vertical, 8)
                .glassCard(cornerRadius: AppRadius.pill)
        }
        .padding()
    }
}
#endif
