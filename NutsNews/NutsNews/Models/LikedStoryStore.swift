//
//  LikedStoryStore.swift
//  NutsNews
//

import Foundation

enum LikedStoryStore {
    static let storageKey = "nutsnews.likedStoryIDs"
    static let emptyRawValue = "[]"

    static func isLiked(_ article: Article, rawValue: String) -> Bool {
        likedIDs(from: rawValue).contains(stableID(for: article))
    }

    static func rawValue(settingLiked isLiked: Bool, article: Article, currentRawValue: String) -> String {
        var ids = likedIDs(from: currentRawValue)
        let articleID = stableID(for: article)

        if isLiked {
            ids.insert(articleID)
        } else {
            ids.remove(articleID)
        }

        return rawValue(from: ids)
    }

    static func stableID(for article: Article) -> String {
        if let originalURL = article.originalURL?.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines),
           !originalURL.isEmpty {
            return originalURL
        }

        let trimmedID = article.id.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedID.isEmpty {
            return trimmedID
        }

        return article.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func likedIDs(from rawValue: String) -> Set<String> {
        guard let data = rawValue.data(using: .utf8),
              let decodedIDs = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }

        return Set(decodedIDs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
    }

    private static func rawValue(from ids: Set<String>) -> String {
        let sortedIDs = ids.sorted()

        guard let data = try? JSONEncoder().encode(sortedIDs),
              let encodedValue = String(data: data, encoding: .utf8) else {
            return emptyRawValue
        }

        return encodedValue
    }
}
