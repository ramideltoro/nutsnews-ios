//
//  NutsNewsAPIClient.swift
//  NutsNews
//

import Foundation

enum NutsNewsAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverStatusCode(Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The NutsNews API URL is invalid."
        case .invalidResponse:
            return "The NutsNews API returned an invalid response."
        case .serverStatusCode(let statusCode):
            return "The NutsNews API returned status code \(statusCode)."
        case .decodingFailed:
            return "NutsNews could not read the article response."
        }
    }
}

enum NutsNewsArticleFetchPolicy: Equatable {
    case useCache
    case reloadIgnoringCache
}

struct NutsNewsAPIClient {
    private let endpoint = "https://www.nutsnews.com/api/articles"
    private let responseCache = NutsNewsArticlesCache.shared

    // Keeps normal app launches/re-enters from hitting the API repeatedly.
    // Pull-to-refresh still bypasses this cache and fetches fresh stories.
    private let freshCacheAge: TimeInterval = 15 * 60

    func fetchArticles(
        page: Int = 0,
        category: String? = nil,
        fetchPolicy: NutsNewsArticleFetchPolicy = .useCache
    ) async throws -> ArticlesResponse {
        let url = try articleURL(page: page, category: category)
        let cacheKey = Self.cacheKey(page: page, category: category)

        if fetchPolicy == .useCache,
           let cachedData = await responseCache.cachedData(for: cacheKey, maxAge: freshCacheAge) {
            do {
                return try decodeArticlesResponse(from: cachedData)
            } catch {
                await responseCache.removeCachedData(for: cacheKey)
            }
        }

        do {
            let freshData = try await fetchFreshArticleData(from: url)
            await responseCache.store(freshData, for: cacheKey)
            return try decodeArticlesResponse(from: freshData)
        } catch {
            // If the network is unavailable or the API has a temporary issue,
            // show the last known good response instead of an empty feed.
            if let staleData = await responseCache.cachedData(for: cacheKey, maxAge: nil),
               let staleResponse = try? decodeArticlesResponse(from: staleData) {
                return staleResponse
            }

            throw error
        }
    }

    private func articleURL(page: Int, category: String?) throws -> URL {
        guard var components = URLComponents(string: endpoint) else {
            throw NutsNewsAPIError.invalidURL
        }

        var queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]

        if let category,
           !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw NutsNewsAPIError.invalidURL
        }

        return url
    }

    private func fetchFreshArticleData(from url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NutsNewsAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NutsNewsAPIError.serverStatusCode(httpResponse.statusCode)
        }

        return data
    }

    private func decodeArticlesResponse(from data: Data) throws -> ArticlesResponse {
        do {
            return try JSONDecoder().decode(ArticlesResponse.self, from: data)
        } catch {
            throw NutsNewsAPIError.decodingFailed
        }
    }

    private static func cacheKey(page: Int, category: String?) -> String {
        let normalizedCategory = category?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let categoryKey: String
        if let normalizedCategory,
           !normalizedCategory.isEmpty {
            categoryKey = normalizedCategory
        } else {
            categoryKey = "all"
        }

        return "articles:v1:page=\(page):category=\(categoryKey)"
    }
}
