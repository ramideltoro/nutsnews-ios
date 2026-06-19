//
//  ArticleFeedViewModel.swift
//  NutsNews
//

import Combine
import Foundation

@MainActor
final class ArticleFeedViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = NutsNewsAPIClient()
    private var nextPage: Int? = 1

    var canLoadMore: Bool {
        nextPage != nil && !isLoading
    }

    func loadInitialArticles() async {
        guard articles.isEmpty else {
            return
        }

        await refresh()
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.fetchArticles(page: 1)
            articles = response.articles
            nextPage = response.nextPage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadMoreIfNeeded(currentArticle: Article) async {
        guard canLoadMore else {
            return
        }

        guard articles.last?.id == currentArticle.id else {
            return
        }

        guard let pageToLoad = nextPage else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.fetchArticles(page: pageToLoad)
            appendUniqueArticles(response.articles)
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
}
