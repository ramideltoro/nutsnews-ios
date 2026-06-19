//
//  ArticlesResponse.swift
//  NutsNews
//

import Foundation

struct ArticlesResponse: Decodable {
    let articles: [Article]
    let nextPage: Int?

    enum CodingKeys: String, CodingKey {
        case articles
        case nextPage
        case nextPageSnake = "next_page"
    }

    init(articles: [Article], nextPage: Int?) {
        self.articles = articles
        self.nextPage = nextPage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        articles = (try? container.decode([Article].self, forKey: .articles)) ?? []
        nextPage = (try? container.decode(Int.self, forKey: .nextPage))
            ?? (try? container.decode(Int.self, forKey: .nextPageSnake))
    }
}
