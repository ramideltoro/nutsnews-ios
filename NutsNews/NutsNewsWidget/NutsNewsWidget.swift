//
//  NutsNewsWidget.swift
//  NutsNewsWidgetExtension
//

import SwiftUI
import WidgetKit

private struct NutsNewsWidgetArticle: Decodable {
    let title: String
    let summary: String?
    let source: String?
    let categories: [String]?
    let category: String?

    enum CodingKeys: String, CodingKey {
        case title
        case summary
        case source
        case categories
        case category
        case aiSummarySnake = "ai_summary"
        case aiSummaryCamel = "aiSummary"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = (try? container.decode(String.self, forKey: .title)) ?? "A good-news story is ready"
        summary = (try? container.decode(String.self, forKey: .summary))
            ?? (try? container.decode(String.self, forKey: .aiSummaryCamel))
            ?? (try? container.decode(String.self, forKey: .aiSummarySnake))
        source = try? container.decode(String.self, forKey: .source)
        categories = try? container.decode([String].self, forKey: .categories)
        category = try? container.decode(String.self, forKey: .category)
    }

    var displaySummary: String {
        let cleaned = (summary ?? "Open NutsNews for a calm, positive story picked to brighten your day.")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty
            ? "Open NutsNews for a calm, positive story picked to brighten your day."
            : cleaned
    }

    var displaySource: String {
        let cleaned = (source ?? "NutsNews")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? "" : cleaned
    }

    var displayMood: String {
        if let first = categories?.first?.trimmingCharacters(in: .whitespacesAndNewlines), !first.isEmpty {
            return first
        }

        if let category = category?.trimmingCharacters(in: .whitespacesAndNewlines), !category.isEmpty {
            return category
        }

        return "Uplifting"
    }
}

private struct NutsNewsWidgetResponse: Decodable {
    let articles: [NutsNewsWidgetArticle]
}

private struct NutsNewsWidgetStats: Equatable {
    let todayCount: Int
    let dailyGoal: Int
    let currentStreak: Int
    let totalStoryCount: Int

    static let empty = NutsNewsWidgetStats(todayCount: 0, dailyGoal: 3, currentStreak: 0, totalStoryCount: 0)

    var progressText: String {
        "\(min(todayCount, dailyGoal))/\(dailyGoal)"
    }

    var progressFraction: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(todayCount) / Double(dailyGoal), 1)
    }
}

private struct NutsNewsWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let summary: String
    let source: String
    let mood: String
    let isPlaceholder: Bool
    let theme: NutsNewsWidgetTheme
    let stats: NutsNewsWidgetStats
    let showStatsOnLargeWidget: Bool

    static let placeholder = NutsNewsWidgetEntry(
        date: .now,
        title: "Your daily good-news reset is ready",
        summary: "A calm, positive story from NutsNews for a brighter moment today.",
        source: "",
        mood: "Daily Reset",
        isPlaceholder: true,
        theme: .amber,
        stats: NutsNewsWidgetStats(todayCount: 2, dailyGoal: 3, currentStreak: 4, totalStoryCount: 18),
        showStatsOnLargeWidget: true
    )

    static let fallback = NutsNewsWidgetEntry(
        date: .now,
        title: "Open NutsNews for today’s positive story",
        summary: "Your good-news dashboard, saved stories, mood picker, and daily reset are waiting.",
        source: "",
        mood: "Good News",
        isPlaceholder: false,
        theme: NutsNewsWidgetSharedSettings.currentTheme,
        stats: NutsNewsWidgetSharedSettings.currentStats,
        showStatsOnLargeWidget: NutsNewsWidgetSharedSettings.showStatsOnLargeWidget
    )
}

private struct NutsNewsWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> NutsNewsWidgetEntry {
        .placeholder
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (NutsNewsWidgetEntry) -> Void
    ) {
        if context.isPreview {
            completion(.placeholder)
            return
        }

        Task {
            completion(await fetchEntry())
        }
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<NutsNewsWidgetEntry>) -> Void
    ) {
        Task {
            let entry = await fetchEntry()
            let nextRefresh = Calendar.current.date(byAdding: .hour, value: 3, to: .now) ?? .now.addingTimeInterval(3 * 60 * 60)
            completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
        }
    }

    private func fetchEntry() async -> NutsNewsWidgetEntry {
        let theme = NutsNewsWidgetSharedSettings.currentTheme
        let stats = NutsNewsWidgetSharedSettings.currentStats
        let showStats = NutsNewsWidgetSharedSettings.showStatsOnLargeWidget

        guard var components = URLComponents(string: "https://www.nutsnews.com/api/articles") else {
            return NutsNewsWidgetEntry.fallback
        }

        components.queryItems = [
            URLQueryItem(name: "page", value: "0"),
            URLQueryItem(name: "limit", value: "5")
        ]

        guard let url = components.url else {
            return NutsNewsWidgetEntry.fallback
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.cachePolicy = .returnCacheDataElseLoad

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return NutsNewsWidgetEntry.fallback
            }

            let decoded = try JSONDecoder().decode(NutsNewsWidgetResponse.self, from: data)
            guard let article = decoded.articles.first else {
                return NutsNewsWidgetEntry.fallback
            }

            return NutsNewsWidgetEntry(
                date: .now,
                title: article.title,
                summary: article.displaySummary,
                source: article.displaySource,
                mood: article.displayMood,
                isPlaceholder: false,
                theme: theme,
                stats: stats,
                showStatsOnLargeWidget: showStats
            )
        } catch {
            return NutsNewsWidgetEntry.fallback
        }
    }
}

private struct NutsNewsWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let entry: NutsNewsWidgetEntry

    private var palette: NutsNewsWidgetPalette {
        entry.theme.palette
    }

    var body: some View {
        ZStack {
            widgetBackground

            VStack(alignment: .leading, spacing: contentSpacing) {
                header

                Text(entry.title)
                    .font(titleFont)
                    .foregroundStyle(palette.primaryText)
                    .lineLimit(titleLineLimit)
                    .minimumScaleFactor(0.82)
                    .multilineTextAlignment(.leading)

                if family != .systemSmall {
                    Text(entry.summary)
                        .font(summaryFont)
                        .foregroundStyle(palette.secondaryText)
                        .lineLimit(family == .systemLarge && shouldShowStats ? 3 : 4)
                        .multilineTextAlignment(.leading)
                }

                if shouldShowStats {
                    statsPanel
                }

                Spacer(minLength: 0)

                footer
            }
            .padding(contentPadding)
        }
        .containerBackground(for: .widget) {
            widgetBackground
        }
    }

    private var shouldShowStats: Bool {
        family == .systemLarge && entry.showStatsOnLargeWidget
    }

    private var contentSpacing: CGFloat {
        switch family {
        case .systemSmall:
            return 8
        case .systemLarge:
            return 12
        default:
            return 10
        }
    }

    private var contentPadding: CGFloat {
        switch family {
        case .systemSmall:
            return 14
        case .systemLarge:
            return 18
        default:
            return 16
        }
    }

    private var titleFont: Font {
        switch family {
        case .systemSmall:
            return .headline.weight(.semibold)
        case .systemLarge:
            return .title2.weight(.semibold)
        default:
            return .title3.weight(.semibold)
        }
    }

    private var summaryFont: Font {
        family == .systemLarge ? .callout.weight(.medium) : .caption.weight(.medium)
    }

    private var titleLineLimit: Int {
        switch family {
        case .systemSmall:
            return 4
        case .systemLarge:
            return 4
        default:
            return 3
        }
    }

    private var header: some View {
        HStack(spacing: 7) {
            Image(systemName: entry.theme.iconName)
                .font(.caption.weight(.bold))
                .foregroundStyle(palette.accent)

            Spacer(minLength: 0)
        }
        .accessibilityHidden(true)
    }

    private var statsPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today’s calm reset")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.primaryText)

                Spacer(minLength: 0)

                Text(entry.stats.progressText)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.accent)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(palette.border.opacity(0.45))

                    Capsule(style: .continuous)
                        .fill(palette.accent)
                        .frame(width: proxy.size.width * CGFloat(entry.stats.progressFraction))
                }
            }
            .frame(height: 7)

            HStack(spacing: 8) {
                statPill(title: "Streak", value: "\(entry.stats.currentStreak)")
                statPill(title: "Stories", value: "\(entry.stats.totalStoryCount)")
            }
        }
        .padding(12)
        .background(palette.card.opacity(0.92))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func statPill(title: String, value: String) -> some View {
        HStack(spacing: 5) {
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(palette.buttonText)

            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(palette.buttonText.opacity(0.72))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(palette.accent)
        .clipShape(Capsule(style: .continuous))
    }

    private var footer: some View {
        HStack(spacing: 7) {
            Text(entry.mood)
                .font(.caption2.weight(.bold))
                .foregroundStyle(palette.buttonText)
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    Capsule(style: .continuous)
                        .fill(palette.accent)
                )

            if !entry.source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(entry.source)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(palette.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
    }

    private var widgetBackground: some View {
        LinearGradient(
            colors: palette.backgroundColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private enum NutsNewsWidgetSharedSettings {
    static let appGroupID = "group.com.nutsnews.app"
    static let themeRawValueKey = "nutsnews.widget.selectedTheme"
    static let readingStatsRawValueKey = "nutsnews.widget.readingStatsRawValue"
    static let dailyGoalKey = "nutsnews.widget.dailyGoal"
    static let showStatsOnLargeWidgetKey = "nutsnews.widget.showStatsOnLargeWidget"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static var currentTheme: NutsNewsWidgetTheme {
        let rawValue = defaults.string(forKey: themeRawValueKey) ?? NutsNewsWidgetTheme.amber.rawValue
        return NutsNewsWidgetTheme(rawValue: rawValue) ?? NutsNewsWidgetTheme.legacyTheme(for: rawValue) ?? .amber
    }

    static var showStatsOnLargeWidget: Bool {
        if defaults.object(forKey: showStatsOnLargeWidgetKey) == nil {
            return true
        }

        return defaults.bool(forKey: showStatsOnLargeWidgetKey)
    }

    static var currentStats: NutsNewsWidgetStats {
        let rawValue = defaults.string(forKey: readingStatsRawValueKey) ?? "{}"
        let goal = max(1, min(defaults.integer(forKey: dailyGoalKey) == 0 ? 3 : defaults.integer(forKey: dailyGoalKey), 5))
        return NutsNewsWidgetStatsReader.stats(from: rawValue, dailyGoal: goal)
    }
}

private enum NutsNewsWidgetStatsReader {
    static func stats(from rawValue: String, dailyGoal: Int) -> NutsNewsWidgetStats {
        guard let data = rawValue.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return NutsNewsWidgetStats(todayCount: 0, dailyGoal: dailyGoal, currentStreak: 0, totalStoryCount: 0)
        }

        let opened = object["openedStoryIDsByDay"] as? [String: [String]] ?? [:]
        let todayKey = key(for: Date())
        let todayCount = Set(opened[todayKey] ?? []).count
        let totalStoryCount = Set(opened.values.flatMap { $0 }).count
        let streak = currentStreak(from: opened)

        return NutsNewsWidgetStats(
            todayCount: todayCount,
            dailyGoal: dailyGoal,
            currentStreak: streak,
            totalStoryCount: totalStoryCount
        )
    }

    private static func currentStreak(from openedStoryIDsByDay: [String: [String]]) -> Int {
        var cursor = Calendar.current.startOfDay(for: Date())
        var streak = 0

        while true {
            let count = Set(openedStoryIDsByDay[key(for: cursor)] ?? []).count
            if count <= 0 { break }

            streak += 1

            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }

            cursor = previousDay
        }

        return streak
    }

    private static func key(for date: Date) -> String {
        dayKeyFormatter.string(from: Calendar.current.startOfDay(for: date))
    }

    private static let dayKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

private enum NutsNewsWidgetTheme: String {
    case amber
    case sakura
    case modernSaaS
    case sanJuan
    case creativePremium
    case moodyCyberpunk

    static func legacyTheme(for rawValue: String) -> NutsNewsWidgetTheme? {
        switch rawValue {
        case "plain", "dark":
            return .amber
        case "darkPink":
            return .sanJuan
        case "lilac":
            return .sakura
        default:
            return nil
        }
    }

    var title: String {
        switch self {
        case .amber:
            return "Amber"
        case .sakura:
            return "Sakura"
        case .modernSaaS:
            return "SaaS"
        case .sanJuan:
            return "Foxy"
        case .creativePremium:
            return "Friday"
        case .moodyCyberpunk:
            return "Bambi"
        }
    }

    var iconName: String {
        switch self {
        case .amber:
            return "sun.max.fill"
        case .sakura:
            return "camera.macro"
        case .modernSaaS:
            return "bolt.fill"
        case .sanJuan:
            return "sparkles"
        case .creativePremium:
            return "wand.and.stars"
        case .moodyCyberpunk:
            return "leaf.fill"
        }
    }

    var palette: NutsNewsWidgetPalette {
        switch self {
        case .amber:
            return NutsNewsWidgetPalette(
                backgroundColors: [color(0x0A0A0A), color(0x17120A), color(0x0A0A0A)],
                card: color(0x171717),
                border: color(0xFACC15, opacity: 0.38),
                primaryText: color(0xF5F5F4),
                secondaryText: color(0xD6D3D1, opacity: 0.78),
                accent: color(0xFACC15),
                buttonText: color(0x111827)
            )
        case .sakura:
            return NutsNewsWidgetPalette(
                backgroundColors: [color(0xFDEFF4), color(0xFFF7ED), color(0xF4EAD2)],
                card: color(0xFFF7FB),
                border: color(0x7AA95C, opacity: 0.34),
                primaryText: color(0x49363D),
                secondaryText: color(0x6F5B62),
                accent: color(0x7AA95C),
                buttonText: color(0x17210F)
            )
        case .modernSaaS:
            return NutsNewsWidgetPalette(
                backgroundColors: [color(0x121212), color(0x181818), color(0x101010)],
                card: color(0x1E1E1E),
                border: color(0x3B82F6, opacity: 0.38),
                primaryText: color(0xE0E0E0),
                secondaryText: color(0xB7BEC8),
                accent: color(0x3B82F6),
                buttonText: color(0xF8FAFC)
            )
        case .sanJuan:
            return NutsNewsWidgetPalette(
                backgroundColors: [color(0xFFF2D0), color(0xFFE4B0), color(0xD8F1E4)],
                card: color(0xFFF8E5),
                border: color(0xE76F51, opacity: 0.34),
                primaryText: color(0x4F3424),
                secondaryText: color(0x75513D),
                accent: color(0x0077B6),
                buttonText: color(0xFFFAF0)
            )
        case .creativePremium:
            return NutsNewsWidgetPalette(
                backgroundColors: [color(0x0F172A), color(0x111827), color(0x0B1120)],
                card: color(0x1E293B),
                border: color(0x7C3AED, opacity: 0.42),
                primaryText: color(0xCBD5E1),
                secondaryText: color(0x94A3B8),
                accent: color(0x7C3AED),
                buttonText: color(0xF8FAFC)
            )
        case .moodyCyberpunk:
            return NutsNewsWidgetPalette(
                backgroundColors: [color(0x1A211B), color(0x20281F), color(0x151A16)],
                card: color(0x2C362F),
                border: color(0xFACC15, opacity: 0.38),
                primaryText: color(0xE5E7EB),
                secondaryText: color(0xCBD5C9),
                accent: color(0xFACC15),
                buttonText: color(0x111827)
            )
        }
    }

    private func color(_ hex: UInt, opacity: Double = 1) -> Color {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue).opacity(opacity)
    }
}

private struct NutsNewsWidgetPalette {
    let backgroundColors: [Color]
    let card: Color
    let border: Color
    let primaryText: Color
    let secondaryText: Color
    let accent: Color
    let buttonText: Color
}

struct NutsNewsDailyWidget: Widget {
    private let kind = "NutsNewsDailyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NutsNewsWidgetProvider()) { entry in
            NutsNewsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NutsNews Daily")
        .description("A calm good-news headline for your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

@main
struct NutsNewsWidgetBundle: WidgetBundle {
    var body: some Widget {
        NutsNewsDailyWidget()
    }
}

#Preview(as: .systemMedium) {
    NutsNewsDailyWidget()
} timeline: {
    NutsNewsWidgetEntry.placeholder
}

#Preview(as: .systemLarge) {
    NutsNewsDailyWidget()
} timeline: {
    NutsNewsWidgetEntry.placeholder
}
