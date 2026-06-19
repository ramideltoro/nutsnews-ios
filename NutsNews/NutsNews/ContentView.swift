//
//  ContentView.swift
//  NutsNews
//
//  Created by Rami Del Toro on 6/16/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            FeedView()
                .opacity(isShowingSplash ? 0 : 1)

            if isShowingSplash {
                SplashView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 950_000_000)

            withAnimation(.easeOut(duration: 0.35)) {
                isShowingSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
