//
//  NutsNewsTheme.swift
//  NutsNews
//

import SwiftUI

enum NutsNewsTheme {
    static let amber = Color(red: 0.96, green: 0.62, blue: 0.18)
    static let amberSoft = Color(red: 1.0, green: 0.78, blue: 0.36)
    static let cardBackground = Color.white.opacity(0.08)
    static let cardBorder = Color.white.opacity(0.12)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.72)
    static let mutedText = Color.white.opacity(0.56)

    static let background = LinearGradient(
        colors: [
            Color(red: 0.06, green: 0.04, blue: 0.02),
            Color(red: 0.12, green: 0.08, blue: 0.03),
            Color(red: 0.03, green: 0.03, blue: 0.03)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
