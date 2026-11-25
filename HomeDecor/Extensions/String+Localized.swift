//
//  String+Localized.swift
//  SwiftBase
//
//  Created by VanTuan on 18/6/26.
//

import Foundation

extension String {
    /// Localized value for the user-selected language. Falls back to English
    /// when a key is missing in that language's `.lproj` (otherwise iOS returns
    /// the raw key), and to the key itself only if English is missing too.
    var localized: String {
        let lang = UserDefaults.standard.string(forKey: Constants.Key.languageSelected) ?? "en"
        let sentinel = "\u{1}__missing__\u{1}"

        if lang != "en",
           let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let value = NSLocalizedString(self, tableName: nil, bundle: bundle, value: sentinel, comment: "")
            if value != sentinel { return value }
        }

        if let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(self, tableName: nil, bundle: bundle, value: self, comment: "")
        }

        return NSLocalizedString(self, comment: "")
    }
}
