//
//  ChatStore.swift
//  HomeDecor
//
//  Phase 7 — AI Chat. Holds the conversation and drives replies.
//
//  Mechanism (docs/ArtMagicKit/REFERENCE.md §5.3–5.4): the real answer comes
//  from Code12's server agent, NOT a local model —
//    • text  → ArtMagicService.chat(text, language, userId, agentId)  → Markdown
//    • photo → ArtMagicService.analyze(image, code, …) (processGeneralAgent)
//  Conversation memory lives server-side keyed by `userId`; "New / Clear chat"
//  renews it. The app's domain context ("interior designer") is baked into the
//  agent (agentId) on Code12's side — we don't send it.
//
//  Until Code12 gives this app its appId / secretKey / agentId, `useMock` is
//  true and replies are produced locally so the whole UI is exercisable. Flip
//  `useMock` off and fill `agentId` to go live — the call sites are marked.
//

import SwiftUI
import Factory

// MARK: - Model

struct PaletteSwatch: Identifiable {
    let id = UUID()
    var hex: UInt? = nil          // nil → a glass swatch
}

struct StyleIdea: Identifiable {
    let id = UUID()
    var name: String
    var asset: String
}

struct ChatMessage: Identifiable {
    enum Role { case user, assistant }

    let id: String
    let role: Role
    var date: Date = Date()

    // Content (any subset present)
    var text: String? = nil            // Markdown
    var image: UIImage? = nil          // user-attached photo
    var asset: String? = nil           // bundled image (AI idea / preview)
    var caption: String? = nil         // text under a user photo
    var palette: [PaletteSwatch]? = nil
    var paletteCaption: String? = nil  // "Walnut · Brass · Linen · Navy"
    var styleIdeas: [StyleIdea]? = nil
    var ctaLabel: String? = nil        // "Try Warm Minimal" / "Redesign this room"
    var quickReplies: [String]? = nil

    // State
    var failed: Bool = false           // couldn't be delivered (user row)

    static func user(_ text: String) -> ChatMessage {
        ChatMessage(id: UUID().uuidString, role: .user, text: text)
    }
}

// MARK: - Store

@MainActor
final class ChatStore: ObservableObject {
    enum Pending: Equatable { case typing, analyzing }

    @Published var messages: [ChatMessage] = []
    @Published var pending: Pending? = nil

    /// Server-side conversation key. One per install; renewed on New/Clear chat.
    private(set) var userId: String

    /// Flip to false once Code12 credentials + a real `agentId` are wired.
    private let useMock = true
    /// The chat agent Code12 assigns THIS app. The original app used "400"
    /// ("AI Designer") — do NOT assume it is ours. Empty until provisioned.
    private let agentId = ""

    private let userIdKey = "chat.userId"

    init() {
        userId = UserDefaults.standard.string(forKey: userIdKey) ?? UUID().uuidString
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }

    var isEmpty: Bool { messages.isEmpty && pending == nil }

    // MARK: Sending

    func send(_ raw: String) {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(.user(text))
        answer(to: text)
    }

    func sendPhoto(_ image: UIImage, caption: String?) {
        var m = ChatMessage(id: UUID().uuidString, role: .user, image: image)
        m.caption = (caption?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 }
        messages.append(m)
        analyzePhoto()
    }

    func retry(_ message: ChatMessage) {
        guard let idx = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[idx].failed = false
        if let text = messages[idx].text { answer(to: text) }
    }

    func clear() {
        messages.removeAll()
        pending = nil
        renewUserId()
    }

    func renewUserId() {
        userId = UUID().uuidString
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }

    // MARK: Reply engine

    private func answer(to text: String) {
        pending = .typing
        Task {
            if useMock {
                try? await Task.sleep(nanoseconds: 1_100_000_000)
                await MainActor.run {
                    pending = nil
                    messages.append(Self.mockReply(for: text))
                }
            } else {
                // GO LIVE: swap the mock above for the real server call.
                // let reply = try await Container.shared.artMagic().chat(
                //     text, language: AppLanguage.current.chatCode,
                //     userId: userId, agentId: agentId)
                // pending = nil; messages.append(ChatMessage(id: UUID().uuidString, role: .assistant, text: reply))
            }
        }
    }

    private func analyzePhoto() {
        pending = .analyzing
        Task {
            try? await Task.sleep(nanoseconds: 1_700_000_000)
            await MainActor.run {
                pending = nil
                messages.append(Self.mockPhotoAdvice())
            }
        }
    }

    // MARK: Mock content (local; replaced by the server agent when live)

    private static func mockReply(for text: String) -> ChatMessage {
        let t = text.lowercased()
        if t.contains("style") || t.contains("which") || t.contains("cheaper") || t.contains("more") {
            return ChatMessage(
                id: UUID().uuidString, role: .assistant,
                text: "Based on your room, these **3 styles** would work beautifully:",
                styleIdeas: [
                    .init(name: "Warm Minimal", asset: "cat_warm_minimal"),
                    .init(name: "Earthy Loft", asset: "cat_earthy_loft"),
                    .init(name: "Sunlit", asset: "cat_linen_calm"),
                ],
                ctaLabel: "Try Warm Minimal",
                quickReplies: ["Show more styles", "Cheaper options"])
        }
        return ChatMessage(
            id: UUID().uuidString, role: .assistant,
            text: "Here's an idea: **walnut shelves**, a brass desk lamp and a deep navy accent wall for a calm, focused mood.",
            asset: "cat_earthy_loft",
            palette: [.init(hex: 0x5B3A24), .init(hex: 0xC9A26B), .init(hex: 0xE9DFCF), .init(hex: nil)],
            paletteCaption: "Walnut · Brass · Linen · Navy")
    }

    private static func mockPhotoAdvice() -> ChatMessage {
        ChatMessage(
            id: UUID().uuidString, role: .assistant,
            text: "Warm lighting, a soft rug and a navy velvet sofa would make it cozy. Here's a preview:",
            asset: "cat_snow_cozy",
            ctaLabel: "Redesign this room")
    }
}

extension Container {
    var chatStore: Factory<ChatStore> {
        Factory(self) { @MainActor in ChatStore() }.singleton
    }
}
