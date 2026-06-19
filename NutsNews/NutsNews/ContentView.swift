//
//  ContentView.swift
//  NutsNews
//
//  Created by Rami Del Toro on 6/16/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingSplash = true
    @State private var showSplashIcon = false
    @State private var showSplashTitle = false
    @State private var showSplashSubtitle = false

    var body: some View {
        ZStack {
            FeedView()
                .opacity(isShowingSplash ? 0 : 1)
                .scaleEffect(isShowingSplash ? 0.99 : 1.0)

            if isShowingSplash {
                SplashView(
                    showIcon: showSplashIcon,
                    showTitle: showSplashTitle,
                    showSubtitle: showSplashSubtitle
                )
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: isShowingSplash)
        .task {
            try? await Task.sleep(nanoseconds: 500_000_000)

            withAnimation(.easeInOut(duration: 0.35)) {
                showSplashIcon = true
            }

            try? await Task.sleep(nanoseconds: 500_000_000)

            withAnimation(.easeInOut(duration: 0.35)) {
                showSplashTitle = true
            }

            try? await Task.sleep(nanoseconds: 500_000_000)

            withAnimation(.easeInOut(duration: 0.35)) {
                showSplashSubtitle = true
            }

            try? await Task.sleep(nanoseconds: 1_000_000_000)

            withAnimation(.easeInOut(duration: 0.35)) {
                showSplashIcon = false
            }

            try? await Task.sleep(nanoseconds: 500_000_000)

            withAnimation(.easeInOut(duration: 0.35)) {
                showSplashTitle = false
            }

            try? await Task.sleep(nanoseconds: 500_000_000)

            withAnimation(.easeInOut(duration: 0.35)) {
                showSplashSubtitle = false
            }

            try? await Task.sleep(nanoseconds: 500_000_000)

            withAnimation(.easeInOut(duration: 0.45)) {
                isShowingSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
