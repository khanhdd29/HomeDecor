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
    /// Credentials are read lazily on every call from Remote Config `app_configs`
    /// (`appId` / `secretKey`), so calls made before the Splash fetch completes
    /// throw `ServiceError.notConfigured` until the values arrive.
    var artMagic: Factory<ArtMagicService> {
        Factory(self) {
            ArtMagicService {
                let cfg = RemoteConfigManager.shared.appConfig
                return (cfg.appId, cfg.secretKey)
            }
        }.singleton
    }
}

/// Convenience access to ArtMagic config that isn't part of the service itself.
enum ArtMagicConfig {
    /// Chat agent id (Code12), from Remote Config `app_configs`.
    static var agentId: String { RemoteConfigManager.shared.appConfig.agentId }
}
