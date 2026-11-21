//
//  AppConfig.swift
//  AdmobSwitUI
//
//  Decode từ key Remote Config `app_configs` (tách khỏi `ad_config`).
//  Chứa các cờ vận hành app + cờ phát hiện "đang bị review".
//

import Foundation

struct AppConfig: Codable {

    var onlyShowLanguage: Bool = true
    var appVersion: String = ""
    var appToken: String = ""
    var eventToken: String = ""

    // ArtMagic (Code12) credentials — supplied via Remote Config `app_configs`,
    // never committed. `ArtMagicService` reads appId/secretKey; chat uses agentId.
    var appId: String = ""
    var secretKey: String = ""
    var agentId: String = ""

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        onlyShowLanguage = try c.decodeIfPresent(Bool.self, forKey: .onlyShowLanguage) ?? false
        appVersion = try c.decodeIfPresent(String.self, forKey: .appVersion) ?? ""
        appToken = try c.decodeIfPresent(String.self, forKey: .appToken) ?? ""
        eventToken = try c.decodeIfPresent(String.self, forKey: .eventToken) ?? ""
        appId = try c.decodeIfPresent(String.self, forKey: .appId) ?? ""
        secretKey = try c.decodeIfPresent(String.self, forKey: .secretKey) ?? ""
        agentId = try c.decodeIfPresent(String.self, forKey: .agentId) ?? ""
    }

    var isInReview: Bool {
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        return appVersion == bundleVersion
    }
}
