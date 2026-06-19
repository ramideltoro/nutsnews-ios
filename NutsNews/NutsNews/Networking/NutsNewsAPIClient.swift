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

struct NutsNewsAPIClient {
    private let endpoint = "https://www.nutsnews.com/api/articles"

    func fetchArticles(page: Int = 1) async throws -> ArticlesResponse {
        guard var components = URLComponents(string: endpoint) else {
            throw NutsNewsAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]

        guard let url = components.url else {
            throw NutsNewsAPIError.invalidURL
        }

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

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(ArticlesResponse.self, from: data)
        } catch {
            throw NutsNewsAPIError.decodingFailed
        }
    }
}
