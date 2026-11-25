//
//  ArtMagicService+Chat.swift
//

import Foundation
import IosArtMagic

extension ArtMagicService {

    /// The agent's answer to `text` (Markdown). `agentId` is the chat agent Code12 gave your app (the app this was
    /// extracted from uses "400"; do NOT assume it is yours). `language` is the `lang` code the endpoint expects
    /// ("en", "vi", "pt", "zh-CN"…). The server remembers the conversation per `userId`: keep one per install and
    /// use a new one to start a fresh conversation.
    func chat(_ text: String, language: String, userId: String, agentId: String) async throws -> String {
        let payload = try await call { client, done in
            client.sendMessage(content: text, userId: userId, agentId: agentId, lang: language, callback: done)
        }
        return try ChatReplyParser.reply(in: payload)
    }
}
