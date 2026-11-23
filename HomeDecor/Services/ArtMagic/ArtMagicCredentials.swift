//
//  ArtMagicCredentials.swift
//  HomeDecor
//
//  Local ArtMagic (Code12) credentials. These used to come from Firebase
//  Remote Config (`app_configs`); for the v1 App Store build we removed
//  Firebase/Remote Config entirely, so the values live here instead.
//
//  Fill these in with the real Code12 values before going live. While they are
//  empty, `ArtMagicService` throws `ServiceError.notConfigured` and the app
//  runs on its mock data (see `ChatStore.useMock`).
//

import Foundation

enum ArtMagicCredentials {
    static let appId = ""
    static let secretKey = ""
    static let agentId = ""
}
