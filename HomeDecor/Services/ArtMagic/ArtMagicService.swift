//
//  ArtMagicService.swift
//

import Foundation
import IosArtMagic

/// Async wrapper over the Code12 ArtMagic SDK (`ArtMagicClient`): template catalog, AI image editing and video,
/// image-analysis agents and chat. The SDK document defines no response models, so every raw call returns the
/// SDK's JSON payload (`Any`, in practice `[String: Any]`); the extensions in this folder parse the common ones.
///
/// Keep ONE instance for the whole app (a singleton / your DI container): it caches the SDK client.
final class ArtMagicService {

    enum ServiceError: LocalizedError {
        case notConfigured

        var errorDescription: String? {
            "ArtMagic credentials are missing: appId / secretKey are empty (are they loaded yet?)."
        }
    }

    typealias Credentials = (appId: String, secretKey: String)

    private let credentials: () -> Credentials
    private let lock = NSLock()
    private var client: ArtMagicClient?
    private var clientKey = ""

    /// `credentials` is read on every call, so it can return values that arrive later (Remote Config after the
    /// splash fetch). While either value is empty the calls throw `ServiceError.notConfigured`.
    init(credentials: @escaping () -> Credentials) {
        self.credentials = credentials
    }

    /// Fixed credentials. Don't commit real keys to a public repo: prefer the closure form fed from Remote Config.
    convenience init(appId: String, secretKey: String) {
        self.init { (appId, secretKey) }
    }

    /// The SDK client, built on first use and rebuilt if the credentials change.
    private func currentClient() throws -> ArtMagicClient {
        let (rawId, rawSecret) = credentials()
        let id = rawId.trimmingCharacters(in: .whitespacesAndNewlines)
        let secret = rawSecret.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty, !secret.isEmpty else { throw ServiceError.notConfigured }

        lock.lock()
        defer { lock.unlock() }
        let key = id + "\n" + secret
        if let client, clientKey == key { return client }
        let fresh = ArtMagicClient(appId: id, appSecretKey: secret)
        client = fresh
        clientKey = key
        return fresh
    }

    // MARK: - Templates

    /// Template category groups (doc 14.4).
    func categoryGroups() async throws -> Any {
        try await call { client, done in client.getImageEditingCategoryGroups(callback: done) }
    }

    /// Template categories, e.g. room types: living room, bathroom… (doc 13.1 / 14.5).
    func categories(page: Int = 0, size: Int = 10, groupCode: String? = nil) async throws -> Any {
        try await call { client, done in
            client.getImageEditingCategories(page: page, size: size, groupCode: groupCode, callback: done)
        }
    }

    /// Templates the app was granted, e.g. decor styles: Wabi Sabi, Japan… (doc 13.2 / 14.6).
    /// A template with `premium == true` in the response is a premium one.
    func templates(page: Int = 0, size: Int = 10, category: String? = nil) async throws -> Any {
        try await call { client, done in
            client.getTemplateApps(page: page, size: size, category: category, callback: done)
        }
    }

    func templateDetail(code: String) async throws -> Any {
        try await call { client, done in client.getTemplateDetail(templateCode: code, callback: done) }
    }

    // MARK: - Image editing

    /// Restyles a photo with a template, e.g. `code: "home_decor_japan"` (doc 13.3).
    /// Also starts premium video templates (`GENERATE_VIDEO`, doc 14.2): pass `options` as the JSON string
    /// `{"aspectRatio":"PORTRAIT","duration":"5"}`. If the answer has no result yet but carries a `requestId`,
    /// poll with `result(requestId:)` (`generate` does this for you).
    func decorate(image: URL, code: String, options: String = "{}", attachments: [URL] = [], prompt: String? = nil) async throws -> Any {
        try await call { client, done in
            client.processImageEditing(fileURL: image, code: code, options: options,
                                       attachmentFiles: attachments, prompt: prompt, callback: done)
        }
    }

    /// Status / result of a request started by `decorate` or `staticVideo` (doc 14.3).
    func result(requestId: String) async throws -> Any {
        try await call { client, done in client.getImageEditingResult(requestId: requestId, callback: done) }
    }

    /// Video from a photo and a `GENERATE_STATIC_VIDEO` template, e.g. `static_frame_02` (doc 14.1).
    /// NOT exercised by the app this was extracted from.
    func staticVideo(image: URL, templateCode: String, options: String = "{}", prompt: String? = nil) async throws -> Any {
        try await call { client, done in
            client.generateStaticVideo(templateCode: templateCode, fileURL: image, options: options, prompt: prompt, callback: done)
        }
    }

    // MARK: - General agent

    /// Image analysis agents (food, plant, flower, garden advice…, doc sections 1, 7–12): `code` picks the
    /// agent (`ai_plant_identification`, `ai_garden_recommendation`…) and `options` is its JSON string.
    /// NOT exercised by the app this was extracted from.
    func analyze(image: URL?, code: String, options: String = "{}", attachments: [URL] = [], uuid: String? = nil) async throws -> Any {
        try await call { client, done in
            client.processGeneralAgent(fileURL: image, code: code, options: options,
                                       attachmentFiles: attachments, uuid: uuid, callback: done)
        }
    }

    // MARK: - SDK bridge

    /// Runs one SDK call and awaits its callback. Wrap any other `ArtMagicClient` method like the ones above.
    /// The request can't be cancelled once sent: `Task.cancel()` only stops what happens after it.
    func call(_ body: (ArtMagicClient, @escaping (Result<Any, Error>) -> Void) -> Void) async throws -> Any {
        let client = try currentClient()
        return try await withCheckedThrowingContinuation { continuation in
            body(client) { continuation.resume(with: $0) }
        }
    }
}
