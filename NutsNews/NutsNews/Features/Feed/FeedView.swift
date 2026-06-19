//
//  FeedView.swift
//  NutsNews
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = ArticleFeedViewModel()
    @State private var selectedArticle: Article?
    @State private var selectedCategory: String?

    var body: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .overlay(NutsNewsTheme.backgroundOverlay)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    staticHeader
                    content
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
            }
        }
        .task {
            await viewModel.loadInitialArticles()
        }
    }

    private var staticHeader: some View {
        VStack(spacing: NutsNewsTheme.spacingS) {
            HStack(spacing: NutsNewsTheme.spacingM) {
                Spacer()

                Text("NutsNews")
                    .font(.system(size: 31, weight: .light, design: .serif))
                    .tracking(1.8)
                    .foregroundStyle(NutsNewsTheme.amberHighlight)
                    .shadow(color: NutsNewsTheme.amberGlow, radius: NutsNewsTheme.spacingS, x: 0, y: NutsNewsTheme.spacingXXS)

                Spacer()

                Button {
                    Task {
                        await viewModel.refresh(category: selectedCategory)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(NutsNewsTheme.amberHighlight)
                        .frame(width: 34, height: 34)
                        .background(NutsNewsTheme.badgeBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
                        )
                }
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, NutsNewsTheme.spacingM)
            .padding(.top, NutsNewsTheme.spacingS)

            categoryFilterRow
        }
        .padding(.bottom, NutsNewsTheme.spacingM)
        .background(
            NutsNewsTheme.background
                .overlay(NutsNewsTheme.backgroundOverlay)
                .ignoresSafeArea(edges: .top)
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(NutsNewsTheme.cardBorder)
                .frame(height: 1)
        }
    }

    private var categoryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: NutsNewsTheme.spacingXS) {
                CategoryChip(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                    Task {
                        await viewModel.applyCategory(nil)
                    }
                }

                ForEach(viewModel.availableCategories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: selectedCategory?.caseInsensitiveCompare(category) == .orderedSame
                    ) {
                        selectedCategory = category
                        Task {
                            await viewModel.applyCategory(category)
                        }
                    }
                }
            }
            .padding(.horizontal, NutsNewsTheme.spacingM)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.articles.isEmpty && viewModel.isLoading {
            loadingView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.articles.isEmpty {
            emptyView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            articleList
        }
    }

    private var articleList: some View {
        ScrollView {
            LazyVStack(spacing: NutsNewsTheme.spacingM) {
                ForEach(viewModel.articles) { article in
                    ArticleCardView(article: article) { selectedArticle in
                        self.selectedArticle = selectedArticle
                    }
                    .task {
                        await viewModel.loadMoreIfNeeded(currentArticle: article)
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .tint(NutsNewsTheme.amber)
                        .padding(.vertical, NutsNewsTheme.spacingM)
                }

                if let errorMessage = viewModel.errorMessage {
                    errorBanner(message: errorMessage)
                }
            }
            .padding(.horizontal, NutsNewsTheme.spacingM)
            .padding(.top, NutsNewsTheme.spacingM)
            .padding(.bottom, NutsNewsTheme.spacingL)
        }
        .refreshable {
            await viewModel.refresh(category: selectedCategory)
        }
    }

    private var loadingView: some View {
        VStack(spacing: NutsNewsTheme.spacingS) {
            ProgressView()
                .tint(NutsNewsTheme.amber)

            Text("Loading good news...")
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
        }
    }

    private var emptyView: some View {
        VStack(spacing: NutsNewsTheme.spacingM) {
            Image(systemName: "leaf")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amber)

            Text(selectedCategory == nil ? "No stories loaded yet" : "No \(selectedCategory ?? "category") stories yet")
                .font(.headline)
                .foregroundStyle(NutsNewsTheme.primaryText)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, NutsNewsTheme.spacingL)
            }

            Button {
                Task {
                    if viewModel.canLoadMore {
                        await viewModel.loadMore()
                    } else {
                        await viewModel.refresh(category: selectedCategory)
                    }
                }
            } label: {
                Text(viewModel.canLoadMore ? "Load more stories" : "Try again")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.buttonText)
                    .padding(.horizontal, NutsNewsTheme.spacingM)
                    .padding(.vertical, NutsNewsTheme.spacingS)
                    .background(NutsNewsTheme.buttonGradient)
                    .clipShape(Capsule())
            }
        }
        .padding(NutsNewsTheme.spacingM)
    }

    private func errorBanner(message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(NutsNewsTheme.secondaryText)
            .padding(NutsNewsTheme.spacingS)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusS, style: .continuous))
    }
}

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: NutsNewsTheme.spacingXS) {
                Circle()
                    .fill(isSelected ? NutsNewsTheme.buttonText : NutsNewsTheme.amber)
                    .frame(width: NutsNewsTheme.spacingXS, height: NutsNewsTheme.spacingXS)

                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? NutsNewsTheme.buttonText : NutsNewsTheme.secondaryText)
                    .lineLimit(1)
            }
            .padding(.horizontal, NutsNewsTheme.chipHorizontalPadding)
            .padding(.vertical, NutsNewsTheme.chipVerticalPadding)
            .background(chipBackground)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : NutsNewsTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var chipBackground: some View {
        if isSelected {
            NutsNewsTheme.buttonGradient
        } else {
            NutsNewsTheme.badgeBackground
        }
    }
}

#Preview {
    FeedView()
}
