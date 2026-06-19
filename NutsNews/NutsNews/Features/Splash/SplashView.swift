//
//  SplashView.swift
//  NutsNews
//

import SwiftUI

struct SplashView: View {
    let showIcon: Bool
    let showTitle: Bool
    let showSubtitle: Bool

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

            VStack(spacing: 10) {
                Image("SplashTransparentChestnuts")
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .opacity(showIcon ? 1 : 0)

                VStack(spacing: 4) {
                    Text("NutsNews")
                        .font(.system(size: 38, weight: .semibold, design: .rounded))
                        .foregroundStyle(titleColor)
                        .opacity(showTitle ? 1 : 0)

                    Text("Positive News, Simplified")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(subtitleColor)
                        .opacity(showSubtitle ? 1 : 0)
                }
            }
            .padding(.horizontal, 24)
        }
        .animation(.easeInOut(duration: 0.35), value: showIcon)
        .animation(.easeInOut(duration: 0.35), value: showTitle)
        .animation(.easeInOut(duration: 0.35), value: showSubtitle)
    }
}

#Preview {
    SplashView(showIcon: true, showTitle: true, showSubtitle: true)
}
