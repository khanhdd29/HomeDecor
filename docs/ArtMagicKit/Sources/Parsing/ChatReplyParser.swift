//
//  ChatReplyParser.swift
//

import Foundation

/// Reads `{status: {code, message}, data: {content}}`. Throws the server's message when `status.code` isn't a success.
enum ChatReplyParser {
    static func reply(in payload: Any) throws -> String {
        let root = payload as? [String: Any]
        if let status = root?["status"] as? [String: Any], let code = (status["code"] as? Int) ?? Int(status["code"] as? String ?? ""),
           code != 0, code != 200 {
            throw CatalogError(message: (status["message"] as? String) ?? "Chat failed (\(code))")
        }
        let body = root?["data"] ?? payload
        let text = ((body as? [String: Any])?["content"] as? String) ?? (body as? String)
        guard let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CatalogError.unrecognized("reply", in: payload)
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
