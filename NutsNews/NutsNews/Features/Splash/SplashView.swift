//
//  SplashView.swift
//  NutsNews
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            NutsNewsTheme.background
                .ignoresSafeArea()

            VStack(spacing: 22) {
                logoMark

                VStack(spacing: 8) {
                    Text("NutsNews")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(NutsNewsTheme.primaryText)

                    Text("Positive news, simplified")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(NutsNewsTheme.amberSoft)
                        .textCase(.uppercase)
                }
            }
            .padding(32)
        }
    }

    private var logoMark: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 36)
                .fill(NutsNewsTheme.cardBackgroundStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: 36)
                        .stroke(NutsNewsTheme.cardBorder, lineWidth: 1.5)
                )
                .shadow(color: NutsNewsTheme.amberGlow, radius: 24, x: 0, y: 12)

            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(NutsNewsTheme.buttonGradient)
                    .frame(width: 92, height: 92)
                    .overlay(
                        Text("N")
                            .font(.system(size: 50, weight: .black, design: .rounded))
                            .foregroundStyle(NutsNewsTheme.buttonText)
                    )

                Image(systemName: "leaf.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(NutsNewsTheme.amberSoft)
                    .offset(x: 10, y: -10)
            }
        }
        .frame(width: 150, height: 150)
    }
}

#Preview {
    SplashView()
}
