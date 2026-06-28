//
//  NutsNewsUserPreferences.swift
//  NutsNews
//

import Foundation

struct NutsNewsTopicPreference: Identifiable, Equatable {
    let id: String
    let title: String
    let iconName: String
    let keywords: [String]
}

struct NutsNewsMoodPreference: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let keywords: [String]
}

enum NutsNewsReminderTime: Int, CaseIterable, Identifiable {
    case morning = 8
    case afternoon = 15
    case evening = 20

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .morning:
            return "Morning reset"
        case .afternoon:
            return "Afternoon lift"
        case .evening:
            return "Evening calm"
        }
    }

    var displayTime: String {
        switch self {
        case .morning:
            return "8:00 AM"
        case .afternoon:
            return "3:00 PM"
        case .evening:
            return "8:00 PM"
        }
    }
}

enum NutsNewsUserPreferences {
    static let hasCompletedOnboardingKey = "nutsnews.onboarding.completed.v1"
    static let selectedTopicsKey = "nutsnews.preferences.topics.v1"
    static let selectedMoodKey = "nutsnews.preferences.mood.v1"
    static let dailyGoalKey = "nutsnews.preferences.dailyGoal.v1"
    static let reminderEnabledKey = "nutsnews.preferences.reminder.enabled.v1"
    static let reminderHourKey = "nutsnews.preferences.reminder.hour.v1"

    static let defaultTopicIDs: Set<String> = ["community", "science", "animals"]
    static let defaultMoodID = "calm"
    static let defaultDailyGoal = 3
    static let defaultReminderHour = NutsNewsReminderTime.morning.rawValue

    static let topics: [NutsNewsTopicPreference] = [
        NutsNewsTopicPreference(
            id: "animals",
            title: "Animals",
            iconName: "pawprint.fill",
            keywords: ["animal", "animals", "dog", "cat", "wildlife", "bird", "rescue", "pet", "zoo", "habitat", "species"]
        ),
        NutsNewsTopicPreference(
            id: "science",
            title: "Science",
            iconName: "atom",
            keywords: ["science", "space", "nasa", "research", "discovery", "breakthrough", "technology", "study", "innovation", "climate"]
        ),
        NutsNewsTopicPreference(
            id: "community",
            title: "Community",
            iconName: "person.3.fill",
            keywords: ["community", "neighbors", "volunteer", "local", "school", "family", "kindness", "help", "support", "together"]
        ),
        NutsNewsTopicPreference(
            id: "wellness",
            title: "Wellness",
            iconName: "leaf.fill",
            keywords: ["wellness", "health", "mental", "calm", "mindful", "fitness", "healing", "therapy", "garden", "peace"]
        ),
        NutsNewsTopicPreference(
            id: "achievements",
            title: "Achievements",
            iconName: "trophy.fill",
            keywords: ["achievement", "record", "milestone", "award", "graduate", "winner", "success", "first", "goal", "champion"]
        ),
        NutsNewsTopicPreference(
            id: "travel",
            title: "Travel",
            iconName: "airplane.departure",
            keywords: ["travel", "park", "trail", "beach", "city", "island", "museum", "journey", "tour", "destination"]
        ),
        NutsNewsTopicPreference(
            id: "culture",
            title: "Culture",
            iconName: "theatermasks.fill",
            keywords: ["culture", "art", "music", "film", "book", "artist", "museum", "dance", "festival", "creative"]
        ),
        NutsNewsTopicPreference(
            id: "nature",
            title: "Nature",
            iconName: "tree.fill",
            keywords: ["nature", "forest", "tree", "river", "ocean", "garden", "wildlife", "conservation", "restore", "environment"]
        )
    ]

    static let moods: [NutsNewsMoodPreference] = [
        NutsNewsMoodPreference(
            id: "calm",
            title: "Calm",
            subtitle: "Soft, peaceful stories",
            iconName: "sun.horizon.fill",
            keywords: ["calm", "peace", "garden", "nature", "healing", "wellness", "quiet", "gentle", "restored", "beautiful"]
        ),
        NutsNewsMoodPreference(
            id: "hopeful",
            title: "Hopeful",
            subtitle: "Progress and kindness",
            iconName: "sparkles",
            keywords: ["hope", "progress", "kindness", "help", "support", "community", "volunteer", "improve", "restore", "future"]
        ),
        NutsNewsMoodPreference(
            id: "inspired",
            title: "Inspired",
            subtitle: "People doing amazing things",
            iconName: "bolt.heart.fill",
            keywords: ["inspire", "achievement", "record", "award", "first", "goal", "winner", "dream", "success", "milestone"]
        ),
        NutsNewsMoodPreference(
            id: "curious",
            title: "Curious",
            subtitle: "Science, culture, and discovery",
            iconName: "lightbulb.fill",
            keywords: ["science", "discovery", "research", "space", "museum", "technology", "innovation", "study", "ancient", "reveals"]
        )
    ]

    static func selectedTopicIDs(from rawValue: String) -> Set<String> {
        let ids = rawValue
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let validIDs = Set(topics.map(\.id))
        let selectedIDs = Set(ids).intersection(validIDs)
        return selectedIDs.isEmpty ? defaultTopicIDs : selectedIDs
    }

    static func rawValue(forTopicIDs topicIDs: Set<String>) -> String {
        let validIDs = Set(topics.map(\.id))
        let cleanedIDs = topicIDs.intersection(validIDs)
        let finalIDs = cleanedIDs.isEmpty ? defaultTopicIDs : cleanedIDs
        return finalIDs.sorted().joined(separator: ",")
    }

    static func mood(for rawValue: String) -> NutsNewsMoodPreference {
        moods.first { $0.id == rawValue } ?? moods.first { $0.id == defaultMoodID } ?? moods[0]
    }

    static func reminderTime(for hour: Int) -> NutsNewsReminderTime {
        NutsNewsReminderTime(rawValue: hour) ?? .morning
    }

    static func dailyGoal(from value: Int) -> Int {
        min(max(value, 1), 5)
    }

    static func topicTitles(from rawValue: String) -> [String] {
        let selectedIDs = selectedTopicIDs(from: rawValue)
        return topics
            .filter { selectedIDs.contains($0.id) }
            .map(\.title)
    }

    static func topPersonalizedArticles(
        from articles: [Article],
        topicsRawValue: String,
        moodRawValue: String,
        limit: Int = 3
    ) -> [Article] {
        let selectedIDs = selectedTopicIDs(from: topicsRawValue)
        let selectedTopics = topics.filter { selectedIDs.contains($0.id) }
        let selectedMood = mood(for: moodRawValue)

        let scoredArticles = articles.map { article in
            (article: article, score: personalizationScore(article: article, topics: selectedTopics, mood: selectedMood))
        }

        let positiveMatches = scoredArticles
            .filter { $0.score > 0 }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.article.title < rhs.article.title
                }

                return lhs.score > rhs.score
            }
            .map(\.article)

        if positiveMatches.count >= limit {
            return Array(positiveMatches.prefix(limit))
        }

        let remainingArticles = articles.filter { article in
            !positiveMatches.contains(article)
        }

        return Array((positiveMatches + remainingArticles).prefix(limit))
    }

    static func personalizationSummary(topicsRawValue: String, moodRawValue: String) -> String {
        let topicTitles = topicTitles(from: topicsRawValue).prefix(3).joined(separator: ", ")
        let moodTitle = mood(for: moodRawValue).title
        return "For You is tuned for \(topicTitles) with a \(moodTitle.lowercased()) feel."
    }

    private static func personalizationScore(
        article: Article,
        topics: [NutsNewsTopicPreference],
        mood: NutsNewsMoodPreference
    ) -> Int {
        let searchableText = ([article.title, article.summary, article.source] + article.categories)
            .joined(separator: " ")
            .lowercased()

        var score = 0

        for topic in topics {
            if article.categories.contains(where: { $0.localizedCaseInsensitiveContains(topic.title) }) {
                score += 4
            }

            score += topic.keywords.filter { searchableText.contains($0) }.count * 2
        }

        score += mood.keywords.filter { searchableText.contains($0) }.count
        return score
    }
}
