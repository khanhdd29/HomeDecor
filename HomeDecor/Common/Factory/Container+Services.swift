//
//  Container+Services.swift
//  HomeDecor
//
//  DI registration for app services (ArtMagic AI generation).
//

import Foundation
import Factory

extension Container {
    /// Single shared ArtMagic service (it caches the SDK client).
    /// Credentials come from `ArtMagicCredentials` (local). While they are empty
    /// the service throws `ServiceError.notConfigured` and the app uses mock data.
    var artMagic: Factory<ArtMagicService> {
        Factory(self) {
            ArtMagicService {
                (ArtMagicCredentials.appId, ArtMagicCredentials.secretKey)
            }
        }.singleton
    }
}

/// Convenience access to ArtMagic config that isn't part of the service itself.
enum ArtMagicConfig {
    /// Chat agent id (Code12).
    static var agentId: String { ArtMagicCredentials.agentId }
}
