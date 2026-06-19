//
//  SplashView.swift
//  NutsNews
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            NutsNewsTheme.background
                .overlay(NutsNewsTheme.backgroundOverlay)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                logoMark

                VStack(spacing: 8) {
                    Text("NutsNews")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(NutsNewsTheme.primaryText)

                    Text("Positive news, simplified")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(NutsNewsTheme.amberHighlight)
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
                        .stroke(NutsNewsTheme.cardBorder, lineWidth: 1.6)
                )
                .shadow(color: NutsNewsTheme.amberGlow, radius: 26, x: 0, y: 12)

            ZStack {
                NutBadge()
                    .fill(NutsNewsTheme.buttonGradient)
                    .frame(width: 102, height: 110)
                    .shadow(color: NutsNewsTheme.amberGlow.opacity(0.9), radius: 10, x: 0, y: 8)

                Text("NN")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(NutsNewsTheme.buttonText)
                    .offset(y: 2)
            }
        }
        .frame(width: 156, height: 156)
    }
}

private struct NutBadge: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: 0.50*w, y: 0.02*h))
        p.addCurve(to: CGPoint(x: 0.86*w, y: 0.22*h),
                   control1: CGPoint(x: 0.69*w, y: 0.01*h),
                   control2: CGPoint(x: 0.83*w, y: 0.10*h))
        p.addCurve(to: CGPoint(x: 0.95*w, y: 0.54*h),
                   control1: CGPoint(x: 0.92*w, y: 0.33*h),
                   control2: CGPoint(x: 0.97*w, y: 0.43*h))
        p.addCurve(to: CGPoint(x: 0.76*w, y: 0.96*h),
                   control1: CGPoint(x: 0.93*w, y: 0.73*h),
                   control2: CGPoint(x: 0.86*w, y: 0.90*h))
        p.addCurve(to: CGPoint(x: 0.24*w, y: 0.96*h),
                   control1: CGPoint(x: 0.61*w, y: 1.02*h),
                   control2: CGPoint(x: 0.39*w, y: 1.02*h))
        p.addCurve(to: CGPoint(x: 0.05*w, y: 0.54*h),
                   control1: CGPoint(x: 0.14*w, y: 0.90*h),
                   control2: CGPoint(x: 0.07*w, y: 0.73*h))
        p.addCurve(to: CGPoint(x: 0.14*w, y: 0.22*h),
                   control1: CGPoint(x: 0.03*w, y: 0.43*h),
                   control2: CGPoint(x: 0.08*w, y: 0.33*h))
        p.addCurve(to: CGPoint(x: 0.50*w, y: 0.02*h),
                   control1: CGPoint(x: 0.17*w, y: 0.10*h),
                   control2: CGPoint(x: 0.31*w, y: 0.01*h))
        p.closeSubpath()
        return p
    }
}

#Preview {
    SplashView()
}
