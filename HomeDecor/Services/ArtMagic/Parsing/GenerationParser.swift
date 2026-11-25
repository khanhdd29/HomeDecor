//
//  GenerationParser.swift
//

import Foundation

/// Reads the server's `{status, data: {...}}` answer of a generation.
// ponytail: key lists are guesses, trim them once real payloads have been seen (see README, "Smoke test").
enum GenerationParser {
    private static let urlKeys = ["resultUrl", "resultURL", "outputUrl", "outputURL", "editedUrl", "imageUrl", "imageURL", "image", "url", "output", "result"]
    /// Keys that hold the user's own upload or catalog art, never the result.
    private static let skippedKeys = ["original", "input", "source", "thumb", "template", "preview"]

    /// The first http(s) URL of the result (an image; a video URL under the same keys is found too).
    static func imageURL(in payload: Any) -> URL? {
        find(body(payload), depth: 0)
    }

    /// The id to poll with. Only `data.requestId` counts: `status.requestId` belongs to the call itself.
    static func requestId(in payload: Any) -> String? {
        guard let data = body(payload) as? [String: Any] else { return nil }
        return (data["requestId"] as? String) ?? (data["id"] as? String)
    }

    private static func body(_ payload: Any) -> Any {
        (payload as? [String: Any])?["data"] ?? payload
    }

    private static func find(_ value: Any, depth: Int) -> URL? {
        guard depth < 4 else { return nil }
        if let text = value as? String { return web(text) }
        if let list = value as? [Any] { return list.lazy.compactMap { find($0, depth: depth + 1) }.first }
        guard let dict = value as? [String: Any] else { return nil }
        for key in urlKeys {
            if let text = dict[key] as? String, let url = web(text) { return url }
        }
        for (key, inner) in dict where !skippedKeys.contains(where: { key.localizedCaseInsensitiveContains($0) }) {
            if let url = find(inner, depth: depth + 1) { return url }
        }
        return nil
    }

    private static func web(_ text: String) -> URL? {
        guard text.hasPrefix("http"), let url = URL(string: text) else { return nil }
        return url
    }
}
