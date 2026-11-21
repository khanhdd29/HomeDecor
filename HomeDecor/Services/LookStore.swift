//
//  LookStore.swift
//  HomeDecor
//
//  Persists AI-generated room designs ("My look") as JPEGs under
//  Documents/Looks. Used by the Result screen (save) and the My look tab.
//

import UIKit

final class LookStore {
    static let shared = LookStore()

    struct Look: Identifiable, Hashable {
        let id: String          // file name, e.g. "<uuid>.jpg"
        let url: URL
        let date: Date
    }

    private let fm = FileManager.default
    private let dir: URL

    private init() {
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        dir = docs.appendingPathComponent("Looks", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    /// Save a generated image. Returns the stored look.
    @discardableResult
    func add(_ image: UIImage, quality: CGFloat = 0.9) throws -> Look {
        guard let data = image.jpegData(compressionQuality: quality) else {
            throw CocoaError(.fileWriteUnknown)
        }
        let name = UUID().uuidString + ".jpg"
        let url = dir.appendingPathComponent(name)
        try data.write(to: url, options: .atomic)
        return Look(id: name, url: url, date: Date())
    }

    /// All saved looks, newest first.
    func all() -> [Look] {
        let keys: [URLResourceKey] = [.creationDateKey]
        let items = (try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: keys)) ?? []
        return items
            .filter { $0.pathExtension.lowercased() == "jpg" }
            .map { url in
                let date = (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                return Look(id: url.lastPathComponent, url: url, date: date)
            }
            .sorted { $0.date > $1.date }
    }

    func image(for look: Look) -> UIImage? {
        UIImage(contentsOfFile: look.url.path)
    }

    func delete(_ look: Look) {
        try? fm.removeItem(at: look.url)
    }

    func delete(ids: [String]) {
        for id in ids {
            try? fm.removeItem(at: dir.appendingPathComponent(id))
        }
    }
}
