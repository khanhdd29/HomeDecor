//
//  AppConstant.swift
//  SwiftBase
//
//  Created by VanTuan on 18/6/26.
//

import Foundation

struct AppConstants {
    /// App Store numeric id — fill once the app is registered. Drives the
    /// share link (and the rate URL if you switch to a manual one).
    static let appId = ""
    /// Privacy-policy URL. The Settings "Privacy Policy" row opens an in-app
    /// web view that loads this page (content is hosted on the web, see
    /// AppStore/PRIVACY_POLICY.md). TODO: replace with the real hosted URL.
    static let policyLink = "https://abodi.app/privacy"
    static let appLi = "https://apps.apple.com/app/id\(appId)"
}
