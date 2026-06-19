//
//  NutsNewsTheme.swift
//  NutsNews
//

import SwiftUI

enum NutsNewsAppTheme: String, CaseIterable, Identifiable {
    case plain
    case dark
    case darkPink
    case amber

    var id: String { rawValue }

    var title: String {
        switch self {
        case .plain:
            return "Plain"
        case .dark:
            return "Dark"
        case .darkPink:
            return "Dark Pink"
        case .amber:
            return "Amber"
        }
    }

    var description: String {
        switch self {
        case .plain:
            return "White background with black text."
        case .dark:
            return "Black background with white text."
        case .darkPink:
            return "Dark pink background with soft pink text."
        case .amber:
            return "Dark amber background with light amber text."
        }
    }

    var iconName: String {
        switch self {
        case .plain:
            return "circle"
        case .dark:
            return "moon.fill"
        case .darkPink:
            return "heart.fill"
        case .amber:
            return "sun.max.fill"
        }
    }

    var preferredColorScheme: ColorScheme {
        switch self {
        case .plain:
            return .light
        case .dark, .darkPink, .amber:
            return .dark
        }
    }
}

enum NutsNewsTheme {
    static let storageKey = "nutsnews.selectedTheme"
    static let defaultTheme = NutsNewsAppTheme.amber

    static var selectedTheme: NutsNewsAppTheme {
        let rawValue = UserDefaults.standard.string(forKey: storageKey) ?? defaultTheme.rawValue
        return NutsNewsAppTheme(rawValue: rawValue) ?? defaultTheme
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

    static var amber: Color {
        switch selectedTheme {
        case .plain:
            return Color.black
        case .dark:
            return Color.white
        case .darkPink:
            return Color(red: 1.0, green: 0.31, blue: 0.64)
        case .amber:
            return Color(red: 1.0, green: 0.66, blue: 0.08)
        }
    }

    static var amberRich: Color {
        switch selectedTheme {
        case .plain:
            return Color.black.opacity(0.82)
        case .dark:
            return Color.white.opacity(0.82)
        case .darkPink:
            return Color(red: 0.92, green: 0.13, blue: 0.48)
        case .amber:
            return Color(red: 0.96, green: 0.56, blue: 0.03)
        }
    }

    static var amberDeep: Color {
        switch selectedTheme {
        case .plain:
            return Color.black
        case .dark:
            return Color.white.opacity(0.72)
        case .darkPink:
            return Color(red: 0.50, green: 0.02, blue: 0.25)
        case .amber:
            return Color(red: 0.72, green: 0.28, blue: 0.00)
        }
    }

    static var amberSoft: Color {
        switch selectedTheme {
        case .plain:
            return Color.black.opacity(0.72)
        case .dark:
            return Color.white.opacity(0.72)
        case .darkPink:
            return Color(red: 1.0, green: 0.66, blue: 0.82)
        case .amber:
            return Color(red: 1.0, green: 0.80, blue: 0.32)
        }
    }

    static var amberHighlight: Color {
        switch selectedTheme {
        case .plain:
            return Color.black
        case .dark:
            return Color.white
        case .darkPink:
            return Color(red: 1.0, green: 0.84, blue: 0.93)
        case .amber:
            return Color(red: 1.0, green: 0.89, blue: 0.58)
        }
    }

    static var amberGlow: Color {
        switch selectedTheme {
        case .plain:
            return Color.black.opacity(0.08)
        case .dark:
            return Color.white.opacity(0.10)
        case .darkPink:
            return Color(red: 1.0, green: 0.22, blue: 0.56).opacity(0.38)
        case .amber:
            return Color(red: 1.0, green: 0.62, blue: 0.08).opacity(0.42)
        }
    }

    static var cardBackground: Color {
        switch selectedTheme {
        case .plain:
            return Color.white.opacity(0.92)
        case .dark:
            return Color(red: 0.08, green: 0.08, blue: 0.09).opacity(0.92)
        case .darkPink:
            return Color(red: 0.22, green: 0.04, blue: 0.13).opacity(0.72)
        case .amber:
            return Color(red: 0.32, green: 0.15, blue: 0.02).opacity(0.68)
        }
    }

    static var cardBackgroundStrong: Color {
        switch selectedTheme {
        case .plain:
            return Color.white
        case .dark:
            return Color(red: 0.10, green: 0.10, blue: 0.11)
        case .darkPink:
            return Color(red: 0.28, green: 0.06, blue: 0.17).opacity(0.92)
        case .amber:
            return Color(red: 0.40, green: 0.19, blue: 0.03).opacity(0.82)
        }
    }

    static var cardBorder: Color {
        switch selectedTheme {
        case .plain:
            return Color.black.opacity(0.14)
        case .dark:
            return Color.white.opacity(0.18)
        case .darkPink:
            return Color(red: 1.0, green: 0.36, blue: 0.68).opacity(0.40)
        case .amber:
            return Color(red: 1.0, green: 0.70, blue: 0.18).opacity(0.42)
        }
    }

    static var badgeBackground: Color {
        switch selectedTheme {
        case .plain:
            return Color.black.opacity(0.06)
        case .dark:
            return Color.white.opacity(0.10)
        case .darkPink:
            return Color(red: 1.0, green: 0.36, blue: 0.68).opacity(0.16)
        case .amber:
            return Color(red: 1.0, green: 0.70, blue: 0.18).opacity(0.16)
        }
    }

    static var primaryText: Color {
        switch selectedTheme {
        case .plain:
            return Color.black
        case .dark:
            return Color.white
        case .darkPink:
            return amberHighlight
        case .amber:
            return amberHighlight
        }
    }

    static var secondaryText: Color {
        switch selectedTheme {
        case .plain:
            return Color.black.opacity(0.78)
        case .dark:
            return Color.white.opacity(0.84)
        case .darkPink:
            return amberSoft
        case .amber:
            return amberSoft
        }
    }

    static var mutedText: Color {
        switch selectedTheme {
        case .plain:
            return Color.black.opacity(0.58)
        case .dark:
            return Color.white.opacity(0.62)
        case .darkPink:
            return amberSoft.opacity(0.70)
        case .amber:
            return amberSoft.opacity(0.72)
        }
    }

    static var buttonText: Color {
        switch selectedTheme {
        case .plain:
            return Color.white
        case .dark:
            return Color.black
        case .darkPink:
            return Color(red: 0.16, green: 0.00, blue: 0.08)
        case .amber:
            return Color(red: 0.18, green: 0.07, blue: 0.00)
        }
    }

    static var background: LinearGradient {
        switch selectedTheme {
        case .plain:
            return LinearGradient(
                colors: [Color.white, Color(red: 0.98, green: 0.98, blue: 0.96)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            return LinearGradient(
                colors: [Color.black, Color(red: 0.06, green: 0.06, blue: 0.07)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .darkPink:
            return LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.03, blue: 0.13),
                    Color(red: 0.12, green: 0.02, blue: 0.08),
                    Color(red: 0.05, green: 0.00, blue: 0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .amber:
            return LinearGradient(
                colors: [
                    Color(red: 0.36, green: 0.18, blue: 0.03),
                    Color(red: 0.23, green: 0.11, blue: 0.02),
                    Color(red: 0.12, green: 0.06, blue: 0.01)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    static var backgroundOverlay: RadialGradient {
        switch selectedTheme {
        case .plain:
            return RadialGradient(
                colors: [Color.black.opacity(0.03), Color.clear],
                center: .top,
                startRadius: spacingS,
                endRadius: 420
            )
        case .dark:
            return RadialGradient(
                colors: [Color.white.opacity(0.06), Color.clear],
                center: .top,
                startRadius: spacingS,
                endRadius: 420
            )
        case .darkPink:
            return RadialGradient(
                colors: [amberSoft.opacity(0.16), Color.clear],
                center: .top,
                startRadius: spacingS,
                endRadius: 420
            )
        case .amber:
            return RadialGradient(
                colors: [amberSoft.opacity(0.18), Color.clear],
                center: .top,
                startRadius: spacingS,
                endRadius: 420
            )
        }
    }

    static var buttonGradient: LinearGradient {
        switch selectedTheme {
        case .plain:
            return LinearGradient(
                colors: [
                    Color(red: 0.22, green: 0.22, blue: 0.24),
                    Color(red: 0.10, green: 0.10, blue: 0.11)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            return LinearGradient(
                colors: [Color.white, Color.white.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .darkPink:
            return LinearGradient(
                colors: [
                    amberHighlight,
                    amberSoft,
                    amber,
                    amberRich,
                    amberDeep
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .amber:
            return LinearGradient(
                colors: [amberHighlight, amberSoft, amber, amberRich, amberDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    static func categoryDotColor(index: Int, isSelected: Bool) -> Color {
        let palette: [Color]

        switch selectedTheme {
        case .plain:
            palette = isSelected
                ? [Color.white, Color.white.opacity(0.82), Color.white.opacity(0.68), Color(red: 0.78, green: 0.78, blue: 0.80)]
                : [Color.black, Color.black.opacity(0.76), Color.black.opacity(0.58), Color(red: 0.28, green: 0.28, blue: 0.30)]
        case .dark:
            palette = isSelected
                ? [Color.black, Color.black.opacity(0.78), Color.black.opacity(0.62), Color(red: 0.30, green: 0.30, blue: 0.32)]
                : [Color.white, Color.white.opacity(0.78), Color.white.opacity(0.60), Color(red: 0.72, green: 0.72, blue: 0.76)]
        case .darkPink:
            palette = isSelected
                ? [buttonText, amberDeep, Color(red: 0.36, green: 0.00, blue: 0.18), Color(red: 0.58, green: 0.03, blue: 0.30)]
                : [amberHighlight, amberSoft, amber, amberRich, amberDeep]
        case .amber:
            palette = isSelected
                ? [buttonText, amberDeep, Color(red: 0.42, green: 0.14, blue: 0.00), Color(red: 0.62, green: 0.22, blue: 0.00)]
                : [amberHighlight, amberSoft, amber, amberRich, amberDeep]
        }

        return palette[abs(index) % palette.count]
    }

}
