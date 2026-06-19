//
//  FeedView.swift
//  NutsNews
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = ArticleFeedViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("Nuts News")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(NutsNewsTheme.amber)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .task {
            await viewModel.loadInitialArticles()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.articles.isEmpty && viewModel.isLoading {
            loadingView
        } else if viewModel.articles.isEmpty {
            emptyView
        } else {
            articleList
        }
    }

    private var articleList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                header

                ForEach(viewModel.articles) { article in
                    ArticleCardView(article: article)
                        .task {
                            await viewModel.loadMoreIfNeeded(currentArticle: article)
                        }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .tint(NutsNewsTheme.amber)
                        .padding(.vertical, 16)
                }

                if let errorMessage = viewModel.errorMessage {
                    errorBanner(message: errorMessage)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Positive news, simplified")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.amber)
                .textCase(.uppercase)

            Text("A calm feed of uplifting stories, filtered by AI and linked back to trusted publishers.")
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(NutsNewsTheme.amber)

            Text("Loading good news...")
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amber)

            Text("No stories loaded yet")
                .font(.headline)
                .foregroundStyle(NutsNewsTheme.primaryText)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Button {
                Task {
                    await viewModel.refresh()
                }
            } label: {
                Text("Try again")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(NutsNewsTheme.amber)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }

    private func errorBanner(message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(NutsNewsTheme.secondaryText)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    FeedView()
}
