//
//  SavedStoryStore.swift
//  NutsNews
//

import Foundation

struct SavedStory: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let summary: String
    let originalURLString: String?
    let source: String
    let publishedAt: String?
    let createdAt: String?
    let thumbnailURLString: String?
    let categories: [String]
    let savedAt: Date

    init(article: Article, savedAt: Date = Date()) {
        self.id = LikedStoryStore.stableID(for: article)
        self.title = article.title
        self.summary = article.summary
        self.originalURLString = article.originalURL?.absoluteString
        self.source = article.source
        self.publishedAt = article.publishedAt
        self.createdAt = article.createdAt
        self.thumbnailURLString = article.thumbnailURL?.absoluteString
        self.categories = article.categories
        self.savedAt = savedAt
    }

    var article: Article {
        Article(
            id: id,
            title: title,
            summary: summary,
            originalURL: originalURLString.flatMap(URL.init(string:)),
            source: source,
            publishedAt: publishedAt,
            createdAt: createdAt,
            thumbnailURL: thumbnailURLString.flatMap(URL.init(string:)),
            categories: categories
        )
    }

    var savedAtDisplayText: String {
        Self.savedDateFormatter.string(from: savedAt)
    }

    private static let savedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

enum SavedStoryStore {
    static let storageKey = "nutsnews.savedStories"
    static let emptyRawValue = "[]"

    static func stories(from rawValue: String) -> [SavedStory] {
        guard let data = rawValue.data(using: .utf8),
              let decodedStories = try? JSONDecoder().decode([SavedStory].self, from: data) else {
            return []
        }

        return decodedStories.sorted { $0.savedAt > $1.savedAt }
    }

    static func isSaved(_ article: Article, rawValue: String) -> Bool {
        let articleID = LikedStoryStore.stableID(for: article)
        return stories(from: rawValue).contains { $0.id == articleID }
    }

    static func rawValue(settingSaved isSaved: Bool, article: Article, currentRawValue: String) -> String {
        var savedStories = stories(from: currentRawValue)
        let articleID = LikedStoryStore.stableID(for: article)

        savedStories.removeAll { $0.id == articleID }

        if isSaved {
            savedStories.insert(SavedStory(article: article), at: 0)
        }

        return rawValue(from: savedStories)
    }

    static func rawValue(removing story: SavedStory, currentRawValue: String) -> String {
        let remainingStories = stories(from: currentRawValue).filter { $0.id != story.id }
        return rawValue(from: remainingStories)
    }

    static func rawValue(from stories: [SavedStory]) -> String {
        let uniqueStories = deduplicated(stories)

        guard let data = try? JSONEncoder().encode(uniqueStories),
              let encodedValue = String(data: data, encoding: .utf8) else {
            return emptyRawValue
        }

        return encodedValue
    }

    private static func deduplicated(_ stories: [SavedStory]) -> [SavedStory] {
        var seen = Set<String>()
        var cleanedStories: [SavedStory] = []

        for story in stories.sorted(by: { $0.savedAt > $1.savedAt }) {
            guard !seen.contains(story.id) else { continue }
            seen.insert(story.id)
            cleanedStories.append(story)
        }

        return cleanedStories
    }
}
