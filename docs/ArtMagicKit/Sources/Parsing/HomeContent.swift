//
//  HomeContent.swift
//

import Foundation

/// A template category from the server (a room type or theme: "Living room", "Anime style"…).
struct HomeCategory: Identifiable, Hashable {
    let id: String // category code, what `getTemplateApps(category:)` expects
    let name: String
}

/// A template (style) shown as a card.
struct HomeTemplate: Identifiable, Hashable {
    let id: String // template code, what `processImageEditing(code:)` expects
    let name: String
    let imageURL: URL
    let isPremium: Bool
}

/// One catalog row: a category and its templates.
struct HomeSection: Identifiable {
    let category: HomeCategory
    let templates: [HomeTemplate]
    var id: String { category.id }
}

/// Reads the SDK's raw JSON. The SDK document doesn't define the response shape, so this takes the first array of
/// objects it finds (top level, or under `content` / `data` / `items`…) and reads the usual key names. The server
/// answers `{status, data: [...], page}`; templates carry `code`, `categoryCode`, `imageUrl`, `premium`, `templateType`.
// ponytail: the key lists also keep guesses (animeCode, thumbnailEdited…). Trim them once all payloads have been seen.
enum HomeContentParser {

    static func categories(from payload: Any) -> [HomeCategory] {
        objects(in: payload).compactMap { item in
            guard let code = string(item, ["code", "categoryCode", "id"]) else { return nil }
            return HomeCategory(id: code, name: string(item, ["name", "title", "displayName", "categoryName", "label"]) ?? code)
        }
    }

    /// Category groups (`groupCode` / `groupName`), e.g. Discovery, Inside, Outside.
    static func groups(from payload: Any) -> [HomeCategory] {
        objects(in: payload).compactMap { item in
            guard let code = string(item, ["groupCode", "code", "id"]) else { return nil }
            return HomeCategory(id: code, name: string(item, ["groupName", "name", "title"]) ?? code)
        }
    }

    static func templates(from payload: Any) -> [HomeTemplate] {
        objects(in: payload).compactMap { item in
            guard let code = string(item, ["code", "animeCode", "templateCode", "id"]) else { return nil }
            // A template without a picture isn't shown at all.
            guard let imageURL = string(item, ["thumbnailEdited", "thumbnailOriginal", "thumbnail", "thumbnailUrl", "thumbnailURL", "previewImage",
                                               "previewUrl", "previewURL", "imageUrl", "imageURL", "image", "coverUrl", "cover", "url"])
                .flatMap(URL.init(string:)) else { return nil }
            return HomeTemplate(
                id: code,
                name: string(item, ["displayName", "name", "title", "templateName", "label"]) ?? code,
                imageURL: imageURL,
                isPremium: (item["premium"] as? Bool) ?? (item["isPremium"] as? Bool) ?? false)
        }
    }

    // MARK: - JSON helpers

    private static let containerKeys = ["content", "items", "data", "list", "results", "records", "templates", "categories", "templateApps"]

    private static func objects(in payload: Any, depth: Int = 0) -> [[String: Any]] {
        if let array = payload as? [Any] { return array.compactMap { $0 as? [String: Any] } }
        guard depth < 3, let dict = payload as? [String: Any] else { return [] }
        for key in containerKeys {
            if let value = dict[key] {
                let found = objects(in: value, depth: depth + 1)
                if !found.isEmpty { return found }
            }
        }
        return []
    }

    private static func string(_ dict: [String: Any], _ keys: [String]) -> String? {
        for key in keys {
            if let s = dict[key] as? String, !s.isEmpty { return s }
            if let n = dict[key] as? NSNumber { return n.stringValue }
        }
        return nil
    }
}
