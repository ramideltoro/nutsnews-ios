//
//  NutsNewsTheme.swift
//  NutsNews
//

import SwiftUI

enum NutsNewsAppTheme: String, CaseIterable, Identifiable {
    case amber
    case sakura
    case modernSaaS
    case sanJuan
    case creativePremium
    case moodyCyberpunk

    var id: String { rawValue }

    var title: String {
        switch self {
        case .amber:
            return "Amber"
        case .sakura:
            return "Sakura"
        case .modernSaaS:
            return "SaaS"
        case .sanJuan:
            return "Foxy"
        case .creativePremium:
            return "Friday"
        case .moodyCyberpunk:
            return "Bambi"
        }
    }

    var description: String {
        switch self {
        case .amber:
            return "Classic NutsNews amber glow."
        case .sakura:
            return "Cherry pink matcha calm."
        case .modernSaaS:
            return "Sleek dark blue polish."
        case .sanJuan:
            return "Pastel streets tropical glow."
        case .creativePremium:
            return "Navy purple premium glow."
        case .moodyCyberpunk:
            return "Green cyber yellow glow."
        }
    }

    var iconName: String {
        switch self {
        case .amber:
            return "sun.max.fill"
        case .sakura:
            return "camera.macro"
        case .modernSaaS:
            return "bolt.fill"
        case .sanJuan:
            return "sparkles"
        case .creativePremium:
            return "wand.and.stars"
        case .moodyCyberpunk:
            return "leaf.fill"
        }
    }

    var preferredColorScheme: ColorScheme {
        switch self {
        case .sakura, .sanJuan:
            return .light
        case .amber, .modernSaaS, .creativePremium, .moodyCyberpunk:
            return .dark
        }
    }
}

enum NutsNewsSettings {
    static let hapticsEnabledKey = "nutsnews.hapticsEnabled"
    static let hapticsDefaultEnabled = true
}

enum NutsNewsTheme {
    static let storageKey = "nutsnews.selectedTheme"
    static let defaultTheme = NutsNewsAppTheme.amber

    static var selectedTheme: NutsNewsAppTheme {
        let rawValue = UserDefaults.standard.string(forKey: storageKey) ?? defaultTheme.rawValue
        return NutsNewsAppTheme(rawValue: rawValue) ?? legacyTheme(for: rawValue) ?? defaultTheme
    }

    private static func legacyTheme(for rawValue: String) -> NutsNewsAppTheme? {
        switch rawValue {
        case "plain", "dark":
            return .amber
        case "darkPink":
            return .sanJuan
        case "lilac":
            return .sakura
        default:
            return nil
        }
    }

    static let phi: CGFloat = 1.61803398875

    static let spacingXXS: CGFloat = 4
    static let spacingXS: CGFloat = 6
    static let spacingS: CGFloat = 10
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 26
    static let spacingXL: CGFloat = 42

    static let radiusXS: CGFloat = 6
    static let radiusS: CGFloat = 10
    static let radiusM: CGFloat = 16
    static let radiusL: CGFloat = 26
    static let radiusXL: CGFloat = 42

    static let cardPadding = spacingM
    static let cardCornerRadius = radiusL
    static let imageCornerRadius = radiusM
    static let controlCornerRadius = radiusM
    static let chipVerticalPadding: CGFloat = 8
    static let chipHorizontalPadding: CGFloat = 13
    static let feedImageHeight: CGFloat = 188
    static let detailHeroHeight: CGFloat = 210

    private static func color(hex: UInt, opacity: Double = 1) -> Color {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue).opacity(opacity)
    }

    static var amber: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0xFACC15)
        case .sakura:
            return color(hex: 0x7AA95C)
        case .modernSaaS:
            return color(hex: 0x3B82F6)
        case .sanJuan:
            return color(hex: 0x0077B6)
        case .creativePremium:
            return color(hex: 0x7C3AED)
        case .moodyCyberpunk:
            return color(hex: 0xFACC15)
        }
    }

    static var amberRich: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0xF59E0B)
        case .sakura:
            return color(hex: 0x98C379)
        case .modernSaaS:
            return color(hex: 0x60A5FA)
        case .sanJuan:
            return color(hex: 0xE76F51)
        case .creativePremium:
            return color(hex: 0xA78BFA)
        case .moodyCyberpunk:
            return color(hex: 0xFDE047)
        }
    }

    static var amberDeep: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0xF97316)
        case .sakura:
            return color(hex: 0x4F7F35)
        case .modernSaaS:
            return color(hex: 0x2563EB)
        case .sanJuan:
            return color(hex: 0x005F73)
        case .creativePremium:
            return color(hex: 0x5B21B6)
        case .moodyCyberpunk:
            return color(hex: 0xEAB308)
        }
    }

    static var amberSoft: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0xFDE68A)
        case .sakura:
            return color(hex: 0xDCEBC9)
        case .modernSaaS:
            return color(hex: 0xBFDBFE)
        case .sanJuan:
            return color(hex: 0xCCEFFF)
        case .creativePremium:
            return color(hex: 0xDDD6FE)
        case .moodyCyberpunk:
            return color(hex: 0xFEF08A)
        }
    }

    static var amberHighlight: Color {
        switch selectedTheme {
        case .amber, .modernSaaS:
            return color(hex: 0xFFFFFF)
        case .sakura:
            return color(hex: 0x3F2B34)
        case .sanJuan:
            return color(hex: 0x3F2415)
        case .creativePremium, .moodyCyberpunk:
            return color(hex: 0xF8FAFC)
        }
    }

    static var amberGlow: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0xFACC15, opacity: 0.34)
        case .sakura:
            return color(hex: 0xF472B6, opacity: 0.28)
        case .modernSaaS:
            return color(hex: 0x3B82F6, opacity: 0.36)
        case .sanJuan:
            return color(hex: 0x2A9DF4, opacity: 0.30)
        case .creativePremium:
            return color(hex: 0x7C3AED, opacity: 0.42)
        case .moodyCyberpunk:
            return color(hex: 0xFACC15, opacity: 0.32)
        }
    }

    static var cardBackground: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0x121212, opacity: 0.88)
        case .sakura:
            return color(hex: 0xFFF7FB, opacity: 0.92)
        case .modernSaaS:
            return color(hex: 0x1E1E1E, opacity: 0.90)
        case .sanJuan:
            return color(hex: 0xFFF8E5, opacity: 0.94)
        case .creativePremium:
            return color(hex: 0x1E293B, opacity: 0.90)
        case .moodyCyberpunk:
            return color(hex: 0x2C362F, opacity: 0.91)
        }
    }

    static var cardBackgroundStrong: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0x171717)
        case .sakura:
            return color(hex: 0xFFF7FB)
        case .modernSaaS:
            return color(hex: 0x1E1E1E)
        case .sanJuan:
            return color(hex: 0xFFF6DF)
        case .creativePremium:
            return color(hex: 0x1E293B)
        case .moodyCyberpunk:
            return color(hex: 0x2C362F)
        }
    }

    static var cardBorder: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0xFACC15, opacity: 0.24)
        case .sakura:
            return color(hex: 0xDB7093, opacity: 0.30)
        case .modernSaaS:
            return color(hex: 0x3B82F6, opacity: 0.30)
        case .sanJuan:
            return color(hex: 0x0077B6, opacity: 0.26)
        case .creativePremium:
            return color(hex: 0x7C3AED, opacity: 0.34)
        case .moodyCyberpunk:
            return color(hex: 0xFACC15, opacity: 0.30)
        }
    }

    static var likedCardAccent: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0xF59E0B)
        case .sakura:
            return color(hex: 0x98C379)
        case .modernSaaS:
            return color(hex: 0x60A5FA)
        case .sanJuan:
            return color(hex: 0xE76F51)
        case .creativePremium:
            return color(hex: 0xA78BFA)
        case .moodyCyberpunk:
            return color(hex: 0xFDE047)
        }
    }

    static var likedCardBorder: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0xFACC15, opacity: 0.46)
        case .sakura:
            return color(hex: 0x7AA95C, opacity: 0.50)
        case .modernSaaS:
            return color(hex: 0x60A5FA, opacity: 0.54)
        case .sanJuan:
            return color(hex: 0xE76F51, opacity: 0.46)
        case .creativePremium:
            return color(hex: 0xA78BFA, opacity: 0.56)
        case .moodyCyberpunk:
            return color(hex: 0xFDE047, opacity: 0.54)
        }
    }

    static var likedCardGlow: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0xF59E0B, opacity: 0.16)
        case .sakura:
            return color(hex: 0x7AA95C, opacity: 0.18)
        case .modernSaaS:
            return color(hex: 0x3B82F6, opacity: 0.16)
        case .sanJuan:
            return color(hex: 0xE76F51, opacity: 0.16)
        case .creativePremium:
            return color(hex: 0x7C3AED, opacity: 0.18)
        case .moodyCyberpunk:
            return color(hex: 0xFACC15, opacity: 0.14)
        }
    }

    static var badgeBackground: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0x451A03, opacity: 0.30)
        case .sakura:
            return color(hex: 0x7AA95C, opacity: 0.16)
        case .modernSaaS:
            return color(hex: 0x3B82F6, opacity: 0.13)
        case .sanJuan:
            return color(hex: 0x2A9DF4, opacity: 0.14)
        case .creativePremium:
            return color(hex: 0x7C3AED, opacity: 0.14)
        case .moodyCyberpunk:
            return color(hex: 0xFACC15, opacity: 0.12)
        }
    }

    static var primaryText: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0xF5F5F4)
        case .sakura:
            return color(hex: 0x49363D)
        case .modernSaaS:
            return color(hex: 0xE0E0E0)
        case .sanJuan:
            return color(hex: 0x4F3424)
        case .creativePremium:
            return color(hex: 0xCBD5E1)
        case .moodyCyberpunk:
            return color(hex: 0xE5E7EB)
        }
    }

    static var secondaryText: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0xD6D3D1)
        case .sakura:
            return color(hex: 0x6F5B62)
        case .modernSaaS:
            return color(hex: 0xB7BEC8)
        case .sanJuan:
            return color(hex: 0x75513D)
        case .creativePremium:
            return color(hex: 0x94A3B8)
        case .moodyCyberpunk:
            return color(hex: 0xCBD5C9)
        }
    }

    static var mutedText: Color {
        switch selectedTheme {
        case .amber:
            return color(hex: 0x78716C)
        case .sakura:
            return color(hex: 0x9B7C86)
        case .modernSaaS:
            return color(hex: 0x7E8794)
        case .sanJuan:
            return color(hex: 0x94684F)
        case .creativePremium:
            return color(hex: 0x64748B)
        case .moodyCyberpunk:
            return color(hex: 0x8B968B)
        }
    }

    static var buttonText: Color {
        switch selectedTheme {
        case .amber, .moodyCyberpunk:
            return color(hex: 0x111827)
        case .sakura:
            return color(hex: 0x17210F)
        case .modernSaaS, .creativePremium:
            return color(hex: 0xF8FAFC)
        case .sanJuan:
            return color(hex: 0xFFFAF0)
        }
    }

    static var background: LinearGradient {
        switch selectedTheme {
        case .amber:
            return LinearGradient(colors: [color(hex: 0x0A0A0A), color(hex: 0x17120A), color(hex: 0x0A0A0A)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sakura:
            return LinearGradient(colors: [color(hex: 0xFDEFF4), color(hex: 0xFFF7ED), color(hex: 0xF4EAD2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .modernSaaS:
            return LinearGradient(colors: [color(hex: 0x121212), color(hex: 0x181818), color(hex: 0x101010)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sanJuan:
            return LinearGradient(colors: [color(hex: 0xFFF2D0), color(hex: 0xFFE4B0), color(hex: 0xD8F1E4)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .creativePremium:
            return LinearGradient(colors: [color(hex: 0x0F172A), color(hex: 0x111827), color(hex: 0x0B1120)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .moodyCyberpunk:
            return LinearGradient(colors: [color(hex: 0x1A211B), color(hex: 0x20281F), color(hex: 0x151A16)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    static var backgroundOverlay: RadialGradient {
        switch selectedTheme {
        case .amber:
            return RadialGradient(colors: [color(hex: 0xFACC15, opacity: 0.18), Color.clear], center: .topLeading, startRadius: spacingS, endRadius: 430)
        case .sakura:
            return RadialGradient(colors: [color(hex: 0xFDE2E7, opacity: 0.92), Color.clear], center: .topLeading, startRadius: spacingS, endRadius: 430)
        case .modernSaaS:
            return RadialGradient(colors: [color(hex: 0x3B82F6, opacity: 0.20), Color.clear], center: .topLeading, startRadius: spacingS, endRadius: 430)
        case .sanJuan:
            return RadialGradient(colors: [color(hex: 0xF6C453, opacity: 0.76), Color.clear], center: .topLeading, startRadius: spacingS, endRadius: 430)
        case .creativePremium:
            return RadialGradient(colors: [color(hex: 0x7C3AED, opacity: 0.22), Color.clear], center: .topLeading, startRadius: spacingS, endRadius: 430)
        case .moodyCyberpunk:
            return RadialGradient(colors: [color(hex: 0xFACC15, opacity: 0.18), Color.clear], center: .topLeading, startRadius: spacingS, endRadius: 430)
        }
    }

    static var buttonGradient: LinearGradient {
        switch selectedTheme {
        case .amber:
            return LinearGradient(colors: [color(hex: 0xFACC15), color(hex: 0xF59E0B)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sakura:
            return LinearGradient(colors: [color(hex: 0x7AA95C), color(hex: 0x98C379)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .modernSaaS:
            return LinearGradient(colors: [color(hex: 0x3B82F6), color(hex: 0x2563EB)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sanJuan:
            return LinearGradient(colors: [color(hex: 0x0077B6), color(hex: 0xE76F51)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .creativePremium:
            return LinearGradient(colors: [color(hex: 0xA78BFA), color(hex: 0x7C3AED), color(hex: 0x5B21B6)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .moodyCyberpunk:
            return LinearGradient(colors: [color(hex: 0xFACC15), color(hex: 0xFDE047)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    static func categoryDotColor(index: Int, isSelected: Bool) -> Color {
        let selectedPalette: [Color] = [buttonText, buttonText.opacity(0.78), buttonText.opacity(0.58)]
        let idlePalette: [Color]

        switch selectedTheme {
        case .amber:
            idlePalette = [color(hex: 0xFACC15), color(hex: 0xF59E0B), color(hex: 0xF97316), color(hex: 0xFDE68A)]
        case .sakura:
            idlePalette = [color(hex: 0x7AA95C), color(hex: 0x98C379), color(hex: 0x4F7F35), color(hex: 0xDB7093)]
        case .modernSaaS:
            idlePalette = [color(hex: 0x3B82F6), color(hex: 0x60A5FA), color(hex: 0x2563EB), color(hex: 0xBFDBFE)]
        case .sanJuan:
            idlePalette = [color(hex: 0x0077B6), color(hex: 0xE76F51), color(hex: 0x2A9DF4), color(hex: 0x2F9E44)]
        case .creativePremium:
            idlePalette = [color(hex: 0x7C3AED), color(hex: 0xA78BFA), color(hex: 0x5B21B6), color(hex: 0xDDD6FE)]
        case .moodyCyberpunk:
            idlePalette = [color(hex: 0xFACC15), color(hex: 0xFDE047), color(hex: 0xEAB308), color(hex: 0x22C55E)]
        }

        let palette = isSelected ? selectedPalette : idlePalette
        return palette[abs(index) % palette.count]
    }
}
