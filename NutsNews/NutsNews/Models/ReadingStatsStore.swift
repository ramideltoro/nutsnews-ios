//
//  ReadingStatsStore.swift
//  NutsNews
//

import Foundation

struct ReadingStatsDay: Identifiable, Equatable {
    let id: String
    let date: Date
    let storyCount: Int

    var displayLabel: String {
        Self.weekdayFormatter.string(from: date)
    }

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
}

private struct ReadingStatsActivity: Codable {
    var openedStoryIDsByDay: [String: [String]] = [:]
    var originalStoryOpenCountByDay: [String: Int] = [:]
    var lastOpenedAtByStoryID: [String: Date] = [:]
}

enum ReadingStatsStore {
    static let storageKey = "nutsnews.readingStats"
    static let emptyRawValue = "{}"

    static func rawValue(recordingView article: Article, currentRawValue: String, date: Date = Date()) -> String {
        var activity = decodedActivity(from: currentRawValue)
        let dayKey = key(for: date)
        let articleID = LikedStoryStore.stableID(for: article)
        var storyIDs = Set(activity.openedStoryIDsByDay[dayKey] ?? [])

        storyIDs.insert(articleID)
        activity.openedStoryIDsByDay[dayKey] = Array(storyIDs).sorted()
        activity.lastOpenedAtByStoryID[articleID] = date

        return rawValue(from: activity)
    }

    static func rawValue(recordingOriginalStoryOpen currentRawValue: String, date: Date = Date()) -> String {
        var activity = decodedActivity(from: currentRawValue)
        let dayKey = key(for: date)
        activity.originalStoryOpenCountByDay[dayKey, default: 0] += 1
        return rawValue(from: activity)
    }

    static func openedTodayCount(from rawValue: String, date: Date = Date()) -> Int {
        openedCount(on: date, from: rawValue)
    }

    static func originalOpensTodayCount(from rawValue: String, date: Date = Date()) -> Int {
        let activity = decodedActivity(from: rawValue)
        return activity.originalStoryOpenCountByDay[key(for: date)] ?? 0
    }

    static func totalUniqueStoryCount(from rawValue: String) -> Int {
        let activity = decodedActivity(from: rawValue)
        return Set(activity.openedStoryIDsByDay.values.flatMap { $0 }).count
    }

    static func currentStreak(from rawValue: String, today: Date = Date()) -> Int {
        let activity = decodedActivity(from: rawValue)
        var cursor = calendar.startOfDay(for: today)
        var streak = 0

        while true {
            let dayKey = key(for: cursor)
            let count = activity.openedStoryIDsByDay[dayKey]?.count ?? 0

            if count <= 0 {
                break
            }

            streak += 1

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }

            cursor = previousDay
        }

        return streak
    }

    static func recentDays(from rawValue: String, count: Int = 7, today: Date = Date()) -> [ReadingStatsDay] {
        let safeCount = max(1, min(count, 30))
        let startOfToday = calendar.startOfDay(for: today)

        return (0..<safeCount).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -(safeCount - 1 - offset), to: startOfToday) else {
                return nil
            }

            return ReadingStatsDay(
                id: key(for: date),
                date: date,
                storyCount: openedCount(on: date, from: rawValue)
            )
        }
    }

    private static func openedCount(on date: Date, from rawValue: String) -> Int {
        let activity = decodedActivity(from: rawValue)
        return activity.openedStoryIDsByDay[key(for: date)]?.count ?? 0
    }

    private static func decodedActivity(from rawValue: String) -> ReadingStatsActivity {
        guard let data = rawValue.data(using: .utf8) else {
            return ReadingStatsActivity()
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let activity = try? decoder.decode(ReadingStatsActivity.self, from: data) else {
            return ReadingStatsActivity()
        }

        return activity
    }

    private static func rawValue(from activity: ReadingStatsActivity) -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(activity),
              let encodedValue = String(data: data, encoding: .utf8) else {
            return emptyRawValue
        }

        return encodedValue
    }

    private static func key(for date: Date) -> String {
        dayKeyFormatter.string(from: calendar.startOfDay(for: date))
    }

    private static let calendar = Calendar.current

    private static let dayKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
