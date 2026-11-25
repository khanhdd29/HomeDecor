//
//  LookStore.swift
//  HomeDecor
//
//  Persists AI-generated room designs ("My look") under Documents/Looks. Each
//  look is `<uuid>.jpg` (the render), with an optional `<uuid>.before.jpg`
//  (the source photo) and `<uuid>.json` (style name / room / inside-outside) so
//  the Gallery can show a Before/After slider and meta.
//

import UIKit

final class LookStore {
    static let shared = LookStore()

    struct Look: Identifiable, Hashable {
        let id: String          // render file name, e.g. "<uuid>.jpg"
        let url: URL            // render
        let beforeURL: URL?     // source photo, if saved
        let name: String?
        let room: String?
        let isOutside: Bool
        let date: Date
    }

    private let fm = FileManager.default
    private let dir: URL

    private init() {
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        dir = docs.appendingPathComponent("Looks", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    /// Save a generated look (render + optional before + meta). Returns it.
    @discardableResult
    func add(before: UIImage?, after: UIImage, name: String?, room: String?,
             isOutside: Bool, quality: CGFloat = 0.9) throws -> Look {
        guard let afterData = after.jpegData(compressionQuality: quality) else {
            throw CocoaError(.fileWriteUnknown)
        }
        let uuid = UUID().uuidString
        let afterName = uuid + ".jpg"
        let afterURL = dir.appendingPathComponent(afterName)
        try afterData.write(to: afterURL, options: .atomic)

        var beforeURL: URL?
        if let before, let data = before.jpegData(compressionQuality: quality) {
            let url = dir.appendingPathComponent(uuid + ".before.jpg")
            try? data.write(to: url, options: .atomic)
            beforeURL = url
        }

        let meta: [String: Any] = ["name": name ?? "", "room": room ?? "", "isOutside": isOutside]
        if let json = try? JSONSerialization.data(withJSONObject: meta) {
            try? json.write(to: dir.appendingPathComponent(uuid + ".json"), options: .atomic)
        }

        return Look(id: afterName, url: afterURL, beforeURL: beforeURL,
                    name: name, room: room, isOutside: isOutside, date: Date())
    }

    /// Back-compat single-image save.
    @discardableResult
    func add(_ image: UIImage, quality: CGFloat = 0.9) throws -> Look {
        try add(before: nil, after: image, name: nil, room: nil, isOutside: false, quality: quality)
    }

    /// All saved looks, newest first.
    func all() -> [Look] {
        let keys: [URLResourceKey] = [.creationDateKey]
        let items = (try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: keys)) ?? []
        return items
            .filter { $0.pathExtension.lowercased() == "jpg" && !$0.lastPathComponent.hasSuffix(".before.jpg") }
            .map { url in
                let uuid = url.deletingPathExtension().lastPathComponent
                let beforeURL = dir.appendingPathComponent(uuid + ".before.jpg")
                let before = fm.fileExists(atPath: beforeURL.path) ? beforeURL : nil
                var name: String?, room: String?, isOutside = false
                if let data = try? Data(contentsOf: dir.appendingPathComponent(uuid + ".json")),
                   let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    name = (obj["name"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                    room = (obj["room"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                    isOutside = obj["isOutside"] as? Bool ?? false
                }
                let date = (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                return Look(id: url.lastPathComponent, url: url, beforeURL: before,
                            name: name, room: room, isOutside: isOutside, date: date)
            }
            .sorted { $0.date > $1.date }
    }

    func image(for look: Look) -> UIImage? { UIImage(contentsOfFile: look.url.path) }
    func beforeImage(for look: Look) -> UIImage? { look.beforeURL.flatMap { UIImage(contentsOfFile: $0.path) } }

    func delete(_ look: Look) { delete(ids: [look.id]) }

    func delete(ids: [String]) {
        for id in ids {
            let uuid = (id as NSString).deletingPathExtension
            try? fm.removeItem(at: dir.appendingPathComponent(id))
            try? fm.removeItem(at: dir.appendingPathComponent(uuid + ".before.jpg"))
            try? fm.removeItem(at: dir.appendingPathComponent(uuid + ".json"))
        }
    }
}
