//
//  MyLookStore.swift
//  HomeDecor
//
//  Carries the look being opened in Gallery Detail (the router destination
//  takes no params). Shared singleton.
//

import SwiftUI
import Factory

@MainActor
final class MyLookStore: ObservableObject {
    @Published var detail: LookStore.Look?
}

extension Container {
    var myLook: Factory<MyLookStore> {
        Factory(self) { @MainActor in MyLookStore() }.singleton
    }
}

/// Soft shimmering placeholder used by loading skeletons.
struct ShimmerBox: View {
    @State private var phase: CGFloat = -1
    var body: some View {
        Rectangle()
            .fill(Color(hex: 0xDDD8D4))
            .overlay(
                LinearGradient(colors: [.clear, Color(hex: 0xEAE8E6).opacity(0.9), .clear],
                               startPoint: .leading, endPoint: .trailing)
                    .scaleEffect(x: 0.5, y: 1, anchor: .leading)
                    .offset(x: phase * 400)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) { phase = 1.5 }
            }
    }
}

/// Small toast shown at the bottom (Downloaded / Deleted confirmations).
struct ToastView: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 14, weight: .semibold))
            Text(text).font(.system(size: 14, weight: .medium))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 18).frame(height: 44)
        .background(Color(hex: 0x1A140F).opacity(0.92), in: Capsule())
        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
    }
}
