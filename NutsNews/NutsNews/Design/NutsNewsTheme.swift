//
//  NutsNewsTheme.swift
//  NutsNews
//

import SwiftUI

enum NutsNewsTheme {
    static let amber = Color(red: 1.0, green: 0.68, blue: 0.16)
    static let amberDeep = Color(red: 0.88, green: 0.42, blue: 0.04)
    static let amberSoft = Color(red: 1.0, green: 0.82, blue: 0.38)
    static let amberGlow = Color(red: 1.0, green: 0.57, blue: 0.08).opacity(0.34)

    static let cardBackground = Color(red: 0.24, green: 0.13, blue: 0.03).opacity(0.58)
    static let cardBackgroundStrong = Color(red: 0.32, green: 0.17, blue: 0.04).opacity(0.72)
    static let cardBorder = Color(red: 1.0, green: 0.62, blue: 0.16).opacity(0.34)
    static let badgeBackground = Color(red: 1.0, green: 0.62, blue: 0.16).opacity(0.14)

    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.80)
    static let mutedText = Color.white.opacity(0.62)
    static let buttonText = Color(red: 0.09, green: 0.05, blue: 0.01)

    static let background = LinearGradient(
        colors: [
            Color(red: 0.20, green: 0.10, blue: 0.02),
            Color(red: 0.12, green: 0.06, blue: 0.01),
            Color(red: 0.04, green: 0.03, blue: 0.02)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let buttonGradient = LinearGradient(
        colors: [
            amberSoft,
            amber,
            amberDeep
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
