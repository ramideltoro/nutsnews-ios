//
//  NutsNewsTheme.swift
//  NutsNews
//

import SwiftUI

enum NutsNewsTheme {
    static let amber = Color(red: 1.0, green: 0.66, blue: 0.08)
    static let amberRich = Color(red: 0.96, green: 0.56, blue: 0.03)
    static let amberDeep = Color(red: 0.72, green: 0.28, blue: 0.00)
    static let amberSoft = Color(red: 1.0, green: 0.80, blue: 0.32)
    static let amberHighlight = Color(red: 1.0, green: 0.89, blue: 0.58)
    static let amberGlow = Color(red: 1.0, green: 0.62, blue: 0.08).opacity(0.46)

    static let cardBackground = Color(red: 0.32, green: 0.15, blue: 0.02).opacity(0.72)
    static let cardBackgroundStrong = Color(red: 0.40, green: 0.19, blue: 0.03).opacity(0.86)
    static let cardBorder = Color(red: 1.0, green: 0.70, blue: 0.18).opacity(0.46)
    static let badgeBackground = Color(red: 1.0, green: 0.70, blue: 0.18).opacity(0.18)

    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.86)
    static let mutedText = Color.white.opacity(0.68)
    static let buttonText = Color(red: 0.18, green: 0.07, blue: 0.00)

    static let background = LinearGradient(
        colors: [
            Color(red: 0.36, green: 0.18, blue: 0.03),
            Color(red: 0.23, green: 0.11, blue: 0.02),
            Color(red: 0.12, green: 0.06, blue: 0.01)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundOverlay = RadialGradient(
        colors: [
            amberSoft.opacity(0.20),
            Color.clear
        ],
        center: .top,
        startRadius: 10,
        endRadius: 420
    )

    static let buttonGradient = LinearGradient(
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
}
