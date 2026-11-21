//
//  CreateSession.swift
//  HomeDecor
//
//  Shared state for the Create / Generate flow (Phase 4). One instance is
//  injected via Factory and read/written by every screen in the flow
//  (Style Detail → Upload Photo → Choose Style → Generating → Result).
//

import SwiftUI
import Factory

/// A style the user can try. Sample catalog for now (asset-backed); `templateCode`
/// is filled from `HomeTemplate` once Code12 credentials arrive so `generate` can
/// run for real.
struct CreateStyle: Identifiable, Hashable {
    var id: String { image }
    let image: String        // asset name (sample catalog)
    let name: String
    let category: String
    var templateCode: String? = nil
}

@MainActor
final class CreateSession: ObservableObject {
    /// The style being applied.
    @Published var style: CreateStyle?
    /// Other styles in the same category (for "More in <category>" / Change Style).
    @Published var categoryStyles: [CreateStyle] = []
    /// Choose Style toggle + room type.
    @Published var isOutside: Bool = false
    @Published var roomType: String = ""
    /// The room photo the user captured or picked (already `PhotoTools.normalized`).
    @Published var sourcePhoto: UIImage?
    /// The finished AI render.
    @Published var result: UIImage?

    var siblings: [CreateStyle] { categoryStyles.filter { $0.id != style?.id } }

    /// Begin a fresh flow for `style` within its category.
    func start(_ style: CreateStyle, in categoryStyles: [CreateStyle]) {
        self.style = style
        self.categoryStyles = categoryStyles
        sourcePhoto = nil
        result = nil
    }

    /// Swap the chosen style without resetting the picked photo.
    func select(_ style: CreateStyle) { self.style = style }

    func reset() {
        style = nil
        categoryStyles = []
        sourcePhoto = nil
        result = nil
    }
}

extension Container {
    /// Shared Create-flow state (one per app session).
    var createSession: Factory<CreateSession> {
        Factory(self) { @MainActor in CreateSession() }.singleton
    }
}
