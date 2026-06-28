//
//  NutsNewsReflectionStore.swift
//  NutsNews
//

import Foundation

enum NutsNewsReflectionReaction: String, CaseIterable, Identifiable, Codable, Equatable {
    case smile
    case hope
    case revisit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .smile:
            return "Made me smile"
        case .hope:
            return "Gave me hope"
        case .revisit:
            return "Worth revisiting"
        }
    }

    var shortTitle: String {
        switch self {
        case .smile:
            return "Smile"
        case .hope:
            return "Hope"
        case .revisit:
            return "Revisit"
        }
    }

    var savedTitle: String {
        switch self {
        case .smile:
            return "This one made you smile"
        case .hope:
            return "This one gave you hope"
        case .revisit:
            return "Saved as worth revisiting"
        }
    }

    var iconName: String {
        switch self {
        case .smile:
            return "face.smiling"
        case .hope:
            return "sparkles"
        case .revisit:
            return "bookmark.fill"
        }
    }
}

struct NutsNewsStoryReflection: Codable, Equatable, Identifiable {
    let articleID: String
    let articleTitle: String
    let articleSource: String
    let reactionID: String
    let createdAt: Date

    var id: String { articleID }

    var formattedDate: String {
        createdAt.formatted(date: .abbreviated, time: .omitted)
    }
}

enum NutsNewsReflectionStore {
    static let storageKey = "nutsnews.storyReflections.v1"
    static let emptyRawValue = "{}"

    static func reflections(from rawValue: String) -> [String: NutsNewsStoryReflection] {
        guard let data = rawValue.data(using: .utf8) else {
            return [:]
        }

        return (try? JSONDecoder().decode([String: NutsNewsStoryReflection].self, from: data)) ?? [:]
    }

    static func reflection(for article: Article, rawValue: String) -> NutsNewsStoryReflection? {
        let currentReflections = reflections(from: rawValue)

        if let reflection = currentReflections[reflectionKey(for: article)] {
            return reflection
        }

        let legacyKey = legacyArticleIDKey(for: article)
        if let legacyReflection = currentReflections[legacyKey] {
            return legacyReflection
        }

        return nil
    }

    static func reflectionCount(from rawValue: String) -> Int {
        reflections(from: rawValue).count
    }

    static func rawValue(
        settingReaction reaction: NutsNewsReflectionReaction,
        article: Article,
        currentRawValue: String
    ) -> String {
        var currentReflections = reflections(from: currentRawValue)
        let stableKey = reflectionKey(for: article)
        let legacyKey = legacyArticleIDKey(for: article)

        if legacyKey != stableKey {
            currentReflections.removeValue(forKey: legacyKey)
        }

        currentReflections[stableKey] = NutsNewsStoryReflection(
            articleID: stableKey,
            articleTitle: article.title,
            articleSource: article.source,
            reactionID: reaction.rawValue,
            createdAt: Date()
        )

        return encodedRawValue(from: currentReflections)
    }

    private static func reflectionKey(for article: Article) -> String {
        LikedStoryStore.stableID(for: article)
    }

    private static func legacyArticleIDKey(for article: Article) -> String {
        article.id.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func encodedRawValue(from reflections: [String: NutsNewsStoryReflection]) -> String {
        guard let data = try? JSONEncoder().encode(reflections),
              let rawValue = String(data: data, encoding: .utf8) else {
            return emptyRawValue
        }

        return rawValue
    }
}
