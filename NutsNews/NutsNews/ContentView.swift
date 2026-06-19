//
//  ContentView.swift
//  NutsNews
//
//  Created by Rami Del Toro on 6/16/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingSplash = true
    @State private var isHomeVisible = false
    @State private var isSplashIconVisible = false
    @State private var isSplashTitleVisible = false
    @State private var isSplashSubtitleVisible = false

    var body: some View {
        ZStack {
            FeedView()
                .opacity(isHomeVisible ? 1 : 0)

            if isShowingSplash {
                SplashView(
                    isIconVisible: isSplashIconVisible,
                    isTitleVisible: isSplashTitleVisible,
                    isSubtitleVisible: isSplashSubtitleVisible
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.55), value: isShowingSplash)
        .animation(.easeInOut(duration: 0.55), value: isHomeVisible)
        .task {
            // 0ms - 250ms: background only.
            try? await Task.sleep(nanoseconds: 250_000_000)

            withAnimation(.easeOut(duration: 0.45)) {
                isSplashIconVisible = true
            }

            // 250ms after icon begins appearing: show title.
            try? await Task.sleep(nanoseconds: 250_000_000)

            withAnimation(.easeOut(duration: 0.45)) {
                isSplashTitleVisible = true
            }

            // 250ms after title begins appearing: show subtitle.
            try? await Task.sleep(nanoseconds: 250_000_000)

            withAnimation(.easeOut(duration: 0.45)) {
                isSplashSubtitleVisible = true
            }

            // Keep total splash timing at 3 seconds before transitioning home in.
            try? await Task.sleep(nanoseconds: 2_250_000_000)

            withAnimation(.easeInOut(duration: 0.55)) {
                isHomeVisible = true
                isShowingSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
