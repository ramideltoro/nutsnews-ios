//
//  ContentView.swift
//  NutsNews
//
//  Created by Rami Del Toro on 6/16/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingSplash = true
    @State private var isSplashContentVisible = false

    var body: some View {
        ZStack {
            FeedView()
                .opacity(isShowingSplash ? 0 : 1)
                .scaleEffect(isShowingSplash ? 0.985 : 1.0)

            if isShowingSplash {
                SplashView()
                    .opacity(isSplashContentVisible ? 1 : 0)
                    .scaleEffect(isSplashContentVisible ? 1.0 : 0.965)
                    .blur(radius: isSplashContentVisible ? 0 : 4)
                    .transition(
                        .opacity
                            .combined(with: .scale(scale: 0.985))
                    )
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: isShowingSplash)
        .animation(.easeOut(duration: 0.55), value: isSplashContentVisible)
        .task {
            withAnimation(.easeOut(duration: 0.55)) {
                isSplashContentVisible = true
            }

            try? await Task.sleep(nanoseconds: 1_500_000_000)

            withAnimation(.easeInOut(duration: 0.45)) {
                isSplashContentVisible = false
            }

            try? await Task.sleep(nanoseconds: 450_000_000)

            withAnimation(.easeInOut(duration: 0.45)) {
                isShowingSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
