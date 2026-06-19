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
        .animation(.easeInOut(duration: 0.45), value: isShowingSplash)
        .animation(.easeInOut(duration: 0.45), value: isHomeVisible)
        .task {
            // Background only.
            try? await Task.sleep(nanoseconds: 400_000_000)

            withAnimation(.easeOut(duration: 0.4)) {
                isSplashIconVisible = true
            }

            try? await Task.sleep(nanoseconds: 400_000_000)

            withAnimation(.easeOut(duration: 0.4)) {
                isSplashTitleVisible = true
            }

            try? await Task.sleep(nanoseconds: 400_000_000)

            withAnimation(.easeOut(duration: 0.4)) {
                isSplashSubtitleVisible = true
            }

            try? await Task.sleep(nanoseconds: 400_000_000)

            withAnimation(.easeInOut(duration: 0.4)) {
                isSplashIconVisible = false
            }

            try? await Task.sleep(nanoseconds: 400_000_000)

            withAnimation(.easeInOut(duration: 0.4)) {
                isSplashTitleVisible = false
            }

            try? await Task.sleep(nanoseconds: 400_000_000)

            withAnimation(.easeInOut(duration: 0.4)) {
                isSplashSubtitleVisible = false
            }

            try? await Task.sleep(nanoseconds: 400_000_000)

            withAnimation(.easeInOut(duration: 0.45)) {
                isHomeVisible = true
                isShowingSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
