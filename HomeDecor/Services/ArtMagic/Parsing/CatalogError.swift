//
//  CatalogError.swift
//

import Foundation

/// Why a call couldn't be turned into a result: an SDK/network error, or a payload the parsers don't recognise
/// (the message then carries the start of that payload). Used by the catalog, generation and chat parsers.
struct CatalogError: LocalizedError {
    let message: String
    var errorDescription: String? { message }

    static func unrecognized(_ what: String, in payload: Any) -> CatalogError {
        CatalogError(message: "No \(what) in: " + preview(payload, limit: 300))
    }

    /// The start of `payload` as JSON text, for error messages and the smoke test.
    static func preview(_ payload: Any, limit: Int) -> String {
        let text = JSONSerialization.isValidJSONObject(payload)
            ? (try? JSONSerialization.data(withJSONObject: payload)).flatMap { String(data: $0, encoding: .utf8) }
            : nil
        return String((text ?? String(describing: payload)).prefix(limit))
    }
}
