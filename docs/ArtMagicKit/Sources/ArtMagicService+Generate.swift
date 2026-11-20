//
//  ArtMagicService+Generate.swift
//

import UIKit

extension ArtMagicService {

    /// Restyles `photo` (a JPEG file, see `PhotoTools.jpegFile`) with the template `code` and returns the finished
    /// picture. The SDK document doesn't define the response, so this reads the picture URL from it
    /// (`GenerationParser`); while the answer has none but carries a `requestId`, it polls `result(requestId:)`
    /// every 2 s, up to about 3 minutes (doc 13.3 / 14.3).
    func generate(photo: URL, code: String) async throws -> UIImage {
        var payload = try await decorate(image: photo, code: code)
        for _ in 0..<90 {
            if let url = GenerationParser.imageURL(in: payload) { return try await download(url) }
            guard let id = GenerationParser.requestId(in: payload) else { break }
            try await Task.sleep(nanoseconds: 2_000_000_000)
            payload = try await result(requestId: id)
        }
        throw CatalogError.unrecognized("picture", in: payload)
    }

    private func download(_ url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else { throw CatalogError(message: "Not a picture: " + url.absoluteString) }
        return image
    }
}
