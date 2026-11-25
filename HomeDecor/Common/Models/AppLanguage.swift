//
//  AppLanguage.swift
//  HomeDecor
//
//  The 16 supported languages (order + names + flags match the Figma
//  Language screen, node 10:23507). `rawValue` is the `.lproj` folder name.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case hindi              = "hi"
    case portugueseBrazil   = "pt-BR"
    case spanish            = "es"
    case english            = "en"
    case french             = "fr"
    case indonesian         = "id"
    case korean             = "ko"
    case japanese           = "ja"
    case german             = "de"
    case portuguesePortugal = "pt-PT"
    case arabic             = "ar"
    case bengali            = "bn"
    case russian            = "ru"
    case turkish            = "tr"
    case chineseSimplified  = "zh-Hans"
    case chineseTraditional = "zh-Hant"

    var id: String { rawValue }

    /// Primary row text — the language's own name.
    var displayName: String {
        switch self {
        case .hindi:              return "हिन्दी"
        case .portugueseBrazil:   return "Português"
        case .spanish:            return "Español"
        case .english:            return "English"
        case .french:             return "Français"
        case .indonesian:         return "Bahasa Indonesia"
        case .korean:             return "한국어"
        case .japanese:           return "日本語"
        case .german:             return "Deutsch"
        case .portuguesePortugal: return "Português"
        case .arabic:             return "العربية"
        case .bengali:            return "বাংলা"
        case .russian:            return "Русский"
        case .turkish:            return "Türkçe"
        case .chineseSimplified:  return "简体中文"
        case .chineseTraditional: return "繁體中文"
        }
    }

    /// English name shown as the row subtitle (nil for English — no subtitle).
    var englishName: String? {
        switch self {
        case .hindi:              return "Hindi"
        case .portugueseBrazil:   return "Brazil"
        case .spanish:            return "Spanish"
        case .english:            return nil
        case .french:             return "French"
        case .indonesian:         return "Indonesian"
        case .korean:             return "Korean"
        case .japanese:           return "Japanese"
        case .german:             return "German"
        case .portuguesePortugal: return "Portugal"
        case .arabic:             return "Arabic"
        case .bengali:            return "Bengali"
        case .russian:            return "Russian"
        case .turkish:            return "Turkish"
        case .chineseSimplified:  return "Chinese Simplified"
        case .chineseTraditional: return "Chinese Traditional"
        }
    }

    /// Circular flag image asset name.
    var flagAsset: String {
        switch self {
        case .hindi:              return "flag_hi"
        case .portugueseBrazil:   return "flag_pt_br"
        case .spanish:            return "flag_es"
        case .english:            return "flag_en"
        case .french:             return "flag_fr"
        case .indonesian:         return "flag_id"
        case .korean:             return "flag_ko"
        case .japanese:           return "flag_ja"
        case .german:             return "flag_de"
        case .portuguesePortugal: return "flag_pt_pt"
        case .arabic:             return "flag_ar"
        case .bengali:            return "flag_bn"
        case .russian:            return "flag_ru"
        case .turkish:            return "flag_tr"
        case .chineseSimplified:  return "flag_zh"
        case .chineseTraditional: return "flag_zh"
        }
    }

    /// Language code sent to the ArtMagic chat agent.
    var chatCode: String {
        switch self {
        case .portugueseBrazil, .portuguesePortugal: return "pt"
        case .chineseSimplified:  return "zh-CN"
        case .chineseTraditional: return "zh-TW"
        default:                  return rawValue
        }
    }

    /// Best match for the device language, falling back to English.
    static var deviceDefault: AppLanguage {
        let full = Locale.current.identifier                               // e.g. "pt_BR"
        if let exact = AppLanguage(rawValue: full.replacingOccurrences(of: "_", with: "-")) {
            return exact
        }
        let base = Locale.current.language.languageCode?.identifier ?? "en"
        if let exact = AppLanguage(rawValue: base) { return exact }
        switch base {
        case "pt": return .portugueseBrazil
        case "zh": return .chineseSimplified
        default:   return .english
        }
    }
}
