//
//  ArchiveSearchView.swift
//  NutsNews
//

import SwiftUI
import UIKit

@MainActor
final class ArchiveSearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isSearching = false
    @Published private(set) var searchedQuery = ""
    @Published var errorMessage: String?

    private let apiClient = NutsNewsAPIClient()
    private var nextPage: Int?
    private let pageSize = 20

    var canLoadMore: Bool {
        nextPage != nil && !isSearching
    }

    var hasSearched: Bool {
        !searchedQuery.isEmpty
    }

    func submitSearch() async {
        let cleanedQuery = cleanQuery(query)

        guard cleanedQuery.count >= 2 else {
            articles = []
            searchedQuery = ""
            nextPage = nil
            errorMessage = nil
            return
        }

        query = cleanedQuery
        searchedQuery = cleanedQuery
        isSearching = true
        errorMessage = nil
        nextPage = nil

        do {
            let response = try await apiClient.searchArticles(
                query: cleanedQuery,
                page: 0,
                limit: pageSize,
                fetchPolicy: .reloadIgnoringCache
            )

            articles = response.articles
            nextPage = response.nextPage
        } catch {
            articles = []
            nextPage = nil
            errorMessage = error.localizedDescription
        }

        isSearching = false
    }

    func loadMore() async {
        guard canLoadMore,
              let pageToLoad = nextPage else {
            return
        }

        let cleanedQuery = cleanQuery(searchedQuery)
        guard cleanedQuery.count >= 2 else { return }

        isSearching = true
        errorMessage = nil

        do {
            let response = try await apiClient.searchArticles(
                query: cleanedQuery,
                page: pageToLoad,
                limit: pageSize
            )

            appendUniqueArticles(response.articles)
            nextPage = response.nextPage
        } catch {
            errorMessage = error.localizedDescription
        }

        isSearching = false
    }

    func clearSearch() {
        query = ""
        searchedQuery = ""
        articles = []
        nextPage = nil
        errorMessage = nil
    }

    private func appendUniqueArticles(_ newArticles: [Article]) {
        let existingIDs = Set(articles.map { $0.id })
        let uniqueArticles = newArticles.filter { !existingIDs.contains($0.id) }
        articles.append(contentsOf: uniqueArticles)
    }

    private func cleanQuery(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}

struct ArchiveSearchView: View {
    @StateObject private var viewModel = ArchiveSearchViewModel()
    @State private var selectedArticle: Article?
    @FocusState private var isSearchFocused: Bool
    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue

    let onClose: () -> Void

    private var selectedTheme: NutsNewsAppTheme {
        NutsNewsAppTheme(rawValue: themeRawValue) ?? NutsNewsTheme.defaultTheme
    }

    var body: some View {
        content
            .preferredColorScheme(selectedTheme.preferredColorScheme)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isSearchFocused = true
                }
            }
    }

    private var content: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .overlay(NutsNewsTheme.backgroundOverlay)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                    searchControls
                    resultsContent
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
                    .preferredColorScheme(selectedTheme.preferredColorScheme)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: NutsNewsTheme.spacingM) {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                Text("Search")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(NutsNewsTheme.amberHighlight)

                Text("Find stories across the full NutsNews archive.")
                    .font(.caption)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(NutsNewsTheme.amberHighlight)
                    .frame(width: 36, height: 36)
                    .background(NutsNewsTheme.badgeBackground)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close search")
        }
        .padding(.horizontal, NutsNewsTheme.spacingM)
        .padding(.top, NutsNewsTheme.spacingM)
        .padding(.bottom, NutsNewsTheme.spacingS)
        .background(
            NutsNewsTheme.background
                .overlay(NutsNewsTheme.backgroundOverlay)
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(NutsNewsTheme.cardBorder)
                .frame(height: 1)
        }
    }

    private var searchControls: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
            HStack(spacing: NutsNewsTheme.spacingS) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(NutsNewsTheme.amberSoft)

                TextField("Search dogs, community, science...", text: $viewModel.query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .focused($isSearchFocused)
                    .foregroundStyle(NutsNewsTheme.primaryText)
                    .onSubmit {
                        Task {
                            await viewModel.submitSearch()
                        }
                    }

                if !viewModel.query.isEmpty {
                    Button {
                        viewModel.clearSearch()
                        isSearchFocused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(NutsNewsTheme.secondaryText)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, NutsNewsTheme.spacingM)
            .frame(height: 48)
            .background(NutsNewsTheme.cardBackgroundStrong)
            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous)
                    .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
            )

            Button {
                Task {
                    await viewModel.submitSearch()
                }
            } label: {
                HStack(spacing: NutsNewsTheme.spacingXS) {
                    if viewModel.isSearching && viewModel.articles.isEmpty {
                        ProgressView()
                            .tint(NutsNewsTheme.buttonText)
                            .scaleEffect(0.8)
                    }

                    Text("Search all NutsNews")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                .foregroundStyle(NutsNewsTheme.buttonText)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(NutsNewsTheme.buttonGradient)
                .clipShape(Capsule())
                .shadow(color: NutsNewsTheme.amberGlow, radius: 18, x: 0, y: 8)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 || viewModel.isSearching)
            .opacity(viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 ? 0.55 : 1)
        }
        .padding(NutsNewsTheme.spacingM)
    }

    @ViewBuilder
    private var resultsContent: some View {
        if viewModel.isSearching && viewModel.articles.isEmpty {
            loadingView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !viewModel.hasSearched {
            startState
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.articles.isEmpty {
            noResultsState
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            resultsList
        }
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                resultHeader

                ForEach(viewModel.articles) { article in
                    SearchResultRow(article: article) { selectedArticle in
                        self.selectedArticle = selectedArticle
                    }
                    .task {
                        if viewModel.articles.last?.id == article.id {
                            await viewModel.loadMore()
                        }
                    }
                }

                if viewModel.isSearching {
                    ProgressView()
                        .tint(NutsNewsTheme.amber)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, NutsNewsTheme.spacingM)
                } else if viewModel.canLoadMore {
                    loadMoreButton
                }

                if let errorMessage = viewModel.errorMessage {
                    errorBanner(message: errorMessage)
                }
            }
            .padding(.horizontal, NutsNewsTheme.spacingM)
            .padding(.bottom, NutsNewsTheme.spacingL)
        }
    }

    private var resultHeader: some View {
        HStack(spacing: NutsNewsTheme.spacingS) {
            Text("Results for “\(viewModel.searchedQuery)”")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(NutsNewsTheme.primaryText)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            Text("\(viewModel.articles.count)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(NutsNewsTheme.buttonText)
                .padding(.horizontal, NutsNewsTheme.spacingS)
                .padding(.vertical, NutsNewsTheme.spacingXXS)
                .background(NutsNewsTheme.buttonGradient)
                .clipShape(Capsule())
        }
        .padding(.bottom, NutsNewsTheme.spacingXS)
    }

    private var loadMoreButton: some View {
        Button {
            Task {
                await viewModel.loadMore()
            }
        } label: {
            Text("Load more results")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(NutsNewsTheme.buttonText)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(NutsNewsTheme.buttonGradient)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.top, NutsNewsTheme.spacingS)
    }

    private var startState: some View {
        VStack(spacing: NutsNewsTheme.spacingM) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amber)

            Text("Search the archive")
                .font(.headline)
                .foregroundStyle(NutsNewsTheme.primaryText)

            Text("Find uplifting stories by topic, source, or category.")
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, NutsNewsTheme.spacingL)
        }
        .padding(NutsNewsTheme.spacingM)
    }

    private var loadingView: some View {
        VStack(spacing: NutsNewsTheme.spacingS) {
            ProgressView()
                .tint(NutsNewsTheme.amber)

            Text("Searching good news...")
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
        }
    }

    private var noResultsState: some View {
        VStack(spacing: NutsNewsTheme.spacingM) {
            Image(systemName: "leaf")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amber)

            Text("No matching stories yet")
                .font(.headline)
                .foregroundStyle(NutsNewsTheme.primaryText)

            Text("Try a broader search like “animals”, “community”, or “science”.")
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, NutsNewsTheme.spacingL)
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

private struct SearchResultRow: View {
    @AppStorage(SavedStoryStore.storageKey) private var savedStoriesRawValue = SavedStoryStore.emptyRawValue

    let article: Article
    let onOpen: (Article) -> Void

    private var isSaved: Bool {
        SavedStoryStore.isSaved(article, rawValue: savedStoriesRawValue)
    }

    var body: some View {
        Button {
            onOpen(article)
        } label: {
            HStack(alignment: .top, spacing: NutsNewsTheme.spacingS) {
                thumbnail

                VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXS) {
                    metadataRow

                    Text(article.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(NutsNewsTheme.primaryText)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    if !article.summary.isEmpty {
                        Text(article.summary)
                            .font(.caption)
                            .foregroundStyle(NutsNewsTheme.secondaryText)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    }

                    HStack(spacing: NutsNewsTheme.spacingS) {
                        Text(article.displayDate)
                            .font(.caption2)
                            .foregroundStyle(NutsNewsTheme.mutedText)
                            .lineLimit(1)

                        Spacer(minLength: NutsNewsTheme.spacingXS)

                        saveButton
                    }
                    .padding(.top, NutsNewsTheme.spacingXXS)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(NutsNewsTheme.spacingS)
            .background(NutsNewsTheme.cardBackgroundStrong)
            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous)
                    .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open search result")
    }

    private var thumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: NutsNewsTheme.radiusS, style: .continuous)
                .fill(NutsNewsTheme.badgeBackground)

            if let thumbnailURL = article.thumbnailURL {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholderIcon
                    case .empty:
                        ProgressView()
                            .tint(NutsNewsTheme.amber)
                            .scaleEffect(0.7)
                    @unknown default:
                        placeholderIcon
                    }
                }
            } else {
                placeholderIcon
            }
        }
        .frame(width: 94, height: 70)
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusS, style: .continuous))
        .clipped()
    }

    private var placeholderIcon: some View {
        Image(systemName: "newspaper")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(NutsNewsTheme.amber)
    }

    private var metadataRow: some View {
        HStack(spacing: NutsNewsTheme.spacingXS) {
            Text(article.source)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(NutsNewsTheme.amberSoft)
                .lineLimit(1)

            if let firstCategory = article.categories.first {
                Text(firstCategory)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .lineLimit(1)
                    .padding(.horizontal, NutsNewsTheme.spacingXS)
                    .padding(.vertical, 3)
                    .background(NutsNewsTheme.badgeBackground)
                    .clipShape(Capsule())
            }
        }
    }

    private var saveButton: some View {
        Button {
            savedStoriesRawValue = SavedStoryStore.rawValue(
                settingSaved: !isSaved,
                article: article,
                currentRawValue: savedStoriesRawValue
            )
        } label: {
            Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(isSaved ? NutsNewsTheme.buttonText : NutsNewsTheme.amberHighlight)
                .padding(.horizontal, NutsNewsTheme.spacingS)
                .padding(.vertical, NutsNewsTheme.spacingXS)
                .background(isSaved ? AnyShapeStyle(NutsNewsTheme.buttonGradient) : AnyShapeStyle(NutsNewsTheme.badgeBackground))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSaved ? Color.clear : NutsNewsTheme.cardBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSaved ? "Remove saved story" : "Save story")
    }
}
