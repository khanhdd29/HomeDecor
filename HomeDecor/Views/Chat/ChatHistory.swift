//
//  ChatHistory.swift
//  HomeDecor
//
//  Local persistence for AI Chat conversations: a JSON index in Documents plus
//  attached user photos on disk. Lets the chat list past conversations, reopen
//  one, and delete one or many.
//

import UIKit

// MARK: - Codable model

struct StoredStyleIdea: Codable { var name: String; var asset: String }

struct StoredMessage: Codable {
    var id: String
    var role: String                 // "user" | "assistant"
    var date: Date
    var text: String?
    var asset: String?
    var caption: String?
    var paletteHex: [Int]?           // -1 == glass swatch (nil hex)
    var paletteCaption: String?
    var styleIdeas: [StoredStyleIdea]?
    var ctaLabel: String?
    var quickReplies: [String]?
    var imageFile: String?           // filename under chat_images/
    var failed: Bool
}

struct ChatConversation: Codable, Identifiable {
    var id: String
    var userId: String
    var title: String
    var updatedAt: Date
    var messages: [StoredMessage]

    /// Last text line, for the history-row subtitle (Markdown markers stripped).
    var preview: String {
        let raw = messages.last(where: { ($0.text?.isEmpty == false) })?.text ?? ""
        return raw
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: "#", with: "")
    }
}

// MARK: - Storage (Documents/chat_history.json + chat_images/)

enum ChatHistoryStorage {
    private static var documents: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    static var indexURL: URL { documents.appendingPathComponent("chat_history.json") }
    static var imageDir: URL {
        let dir = documents.appendingPathComponent("chat_images", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func load() -> [ChatConversation] {
        guard let data = try? Data(contentsOf: indexURL),
              let list = try? JSONDecoder().decode([ChatConversation].self, from: data)
        else { return [] }
        return list.sorted { $0.updatedAt > $1.updatedAt }
    }

    static func save(_ list: [ChatConversation]) {
        guard let data = try? JSONEncoder().encode(list) else { return }
        try? data.write(to: indexURL, options: .atomic)
    }

    static func deleteImages(for conversation: ChatConversation) {
        for m in conversation.messages {
            if let file = m.imageFile {
                try? FileManager.default.removeItem(at: imageDir.appendingPathComponent(file))
            }
        }
    }
}

// MARK: - Conversion ChatMessage <-> StoredMessage

extension ChatMessage {
    func stored() -> StoredMessage {
        var imageFile: String?
        if let image, let data = image.jpegData(compressionQuality: 0.8) {
            let name = "\(id).jpg"
            try? data.write(to: ChatHistoryStorage.imageDir.appendingPathComponent(name))
            imageFile = name
        }
        return StoredMessage(
            id: id, role: role == .user ? "user" : "assistant", date: date,
            text: text, asset: asset, caption: caption,
            paletteHex: palette.map { arr in arr.map { sw in sw.hex.map { Int($0) } ?? -1 } },
            paletteCaption: paletteCaption,
            styleIdeas: styleIdeas.map { arr in arr.map { StoredStyleIdea(name: $0.name, asset: $0.asset) } },
            ctaLabel: ctaLabel, quickReplies: quickReplies,
            imageFile: imageFile, failed: failed)
    }
}

extension StoredMessage {
    func message() -> ChatMessage {
        var m = ChatMessage(
            id: id, role: role == "user" ? .user : .assistant, date: date,
            text: text, asset: asset, caption: caption,
            palette: paletteHex.map { arr in arr.map { h in PaletteSwatch(hex: h < 0 ? nil : UInt(h)) } },
            paletteCaption: paletteCaption,
            styleIdeas: styleIdeas.map { arr in arr.map { StyleIdea(name: $0.name, asset: $0.asset) } },
            ctaLabel: ctaLabel, quickReplies: quickReplies, failed: failed)
        if let imageFile,
           let img = UIImage(contentsOfFile: ChatHistoryStorage.imageDir.appendingPathComponent(imageFile).path) {
            m.image = img
        }
        return m
    }
}
