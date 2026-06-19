//
//  SplashView.swift
//  NutsNews
//

import SwiftUI

struct SplashView: View {
    let isIconVisible: Bool
    let isTitleVisible: Bool
    let isSubtitleVisible: Bool

    private let splashBackground = LinearGradient(
        colors: [
            Color(red: 0.99, green: 0.76, blue: 0.20),
            Color(red: 0.95, green: 0.54, blue: 0.06),
            Color(red: 0.75, green: 0.29, blue: 0.00)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private let titleColor = Color(red: 1.00, green: 0.92, blue: 0.68)
    private let subtitleColor = Color(red: 1.00, green: 0.84, blue: 0.46)

    var body: some View {
        ZStack {
            splashBackground
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("SplashTransparentChestnuts")
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .opacity(isIconVisible ? 1 : 0)
                    .offset(y: isIconVisible ? 0 : 8)

                VStack(spacing: 5) {
                    Text("NutsNews")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(titleColor)
                        .opacity(isTitleVisible ? 1 : 0)
                        .offset(y: isTitleVisible ? 0 : 6)

                    Text("Positive News, Simplified")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(subtitleColor)
                        .opacity(isSubtitleVisible ? 1 : 0)
                        .offset(y: isSubtitleVisible ? 0 : 6)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    SplashView(
        isIconVisible: true,
        isTitleVisible: true,
        isSubtitleVisible: true
    )
}
