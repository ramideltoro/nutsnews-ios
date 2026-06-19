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
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: isShowingSplash)
        .animation(.easeOut(duration: 0.4), value: isSplashContentVisible)
        .task {
            withAnimation(.easeOut(duration: 0.4)) {
                isSplashContentVisible = true
            }

            try? await Task.sleep(nanoseconds: 2_000_000_000)

            withAnimation(.easeInOut(duration: 0.35)) {
                isSplashContentVisible = false
            }

            try? await Task.sleep(nanoseconds: 350_000_000)

            withAnimation(.easeInOut(duration: 0.35)) {
                isShowingSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
