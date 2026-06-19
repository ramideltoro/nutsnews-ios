//
//  ArticleFeedViewModel.swift
//  NutsNews
//

import Foundation

@MainActor
final class ArticleFeedViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var availableCategories: [String] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = NutsNewsAPIClient()
    private var nextPage: Int? = 0
    private var selectedCategory: String?

    var canLoadMore: Bool {
        nextPage != nil && !isLoading
    }

    func loadInitialArticles() async {
        guard articles.isEmpty else {
            return
        }

        await refresh(category: selectedCategory)
    }

    func refresh(category: String? = nil) async {
        let normalizedCategory = normalizeSelectedCategory(category)

        selectedCategory = normalizedCategory
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.fetchArticles(page: 0, category: normalizedCategory)
            articles = response.articles
            mergeAvailableCategories(from: response.articles)
            nextPage = response.nextPage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func applyCategory(_ category: String?) async {
        await refresh(category: category)
    }

    func loadMoreIfNeeded(currentArticle: Article) async {
        guard canLoadMore else {
            return
        }

        guard articles.last?.id == currentArticle.id else {
            return
        }

        await loadMore()
    }

    func loadMore() async {
        guard canLoadMore,
              let pageToLoad = nextPage else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.fetchArticles(page: pageToLoad, category: selectedCategory)
            appendUniqueArticles(response.articles)
            mergeAvailableCategories(from: response.articles)
            nextPage = response.nextPage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func appendUniqueArticles(_ newArticles: [Article]) {
        let existingIDs = Set(articles.map { $0.id })
        let uniqueArticles = newArticles.filter { !existingIDs.contains($0.id) }
        articles.append(contentsOf: uniqueArticles)
    }

    private func mergeAvailableCategories(from articles: [Article]) {
        var seen = Set(availableCategories.map { $0.lowercased() })
        var mergedCategories = availableCategories

        for article in articles {
            for category in article.categories {
                let cleanedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !cleanedCategory.isEmpty else {
                    continue
                }

                let lookupKey = cleanedCategory.lowercased()
                guard !seen.contains(lookupKey) else {
                    continue
                }

                seen.insert(lookupKey)
                mergedCategories.append(cleanedCategory)
            }
        }

        availableCategories = mergedCategories
    }

    private func normalizeSelectedCategory(_ category: String?) -> String? {
        guard let category else {
            return nil
        }

        let cleanedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanedCategory.isEmpty ? nil : cleanedCategory
    }
}
