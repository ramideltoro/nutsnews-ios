//
//  NutsNewsWidget.swift
//  NutsNewsWidgetExtension
//
//  A native Home Screen widget for the App Store approval-focused build.
//  It gives NutsNews a visible iOS-native daily good-news surface outside the app.
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
        return cleaned.isEmpty ? "NutsNews" : cleaned
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

private struct NutsNewsWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let summary: String
    let source: String
    let mood: String
    let isPlaceholder: Bool

    static let placeholder = NutsNewsWidgetEntry(
        date: .now,
        title: "Your daily good-news reset is ready",
        summary: "A calm, positive story from NutsNews for a brighter moment today.",
        source: "NutsNews",
        mood: "Daily Reset",
        isPlaceholder: true
    )

    static let fallback = NutsNewsWidgetEntry(
        date: .now,
        title: "Open NutsNews for today’s positive story",
        summary: "Your good-news dashboard, saved stories, mood picker, and daily reset are waiting.",
        source: "NutsNews",
        mood: "Good News",
        isPlaceholder: false
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
        guard var components = URLComponents(string: "https://www.nutsnews.com/api/articles") else {
            return .fallback
        }

        components.queryItems = [
            URLQueryItem(name: "page", value: "0"),
            URLQueryItem(name: "limit", value: "5")
        ]

        guard let url = components.url else {
            return .fallback
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.cachePolicy = .returnCacheDataElseLoad

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return .fallback
            }

            let decoded = try JSONDecoder().decode(NutsNewsWidgetResponse.self, from: data)
            guard let article = decoded.articles.first else {
                return .fallback
            }

            return NutsNewsWidgetEntry(
                date: .now,
                title: article.title,
                summary: article.displaySummary,
                source: article.displaySource,
                mood: article.displayMood,
                isPlaceholder: false
            )
        } catch {
            return .fallback
        }
    }
}

private struct NutsNewsWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let entry: NutsNewsWidgetEntry

    var body: some View {
        ZStack {
            widgetBackground

            VStack(alignment: .leading, spacing: family == .systemSmall ? 8 : 10) {
                header

                Text(entry.title)
                    .font(family == .systemSmall ? .headline.weight(.semibold) : .title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(family == .systemSmall ? 4 : 3)
                    .minimumScaleFactor(0.82)
                    .multilineTextAlignment(.leading)

                if family != .systemSmall {
                    Text(entry.summary)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.74))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                footer
            }
            .padding(family == .systemSmall ? 14 : 16)
        }
        .containerBackground(for: .widget) {
            widgetBackground
        }
    }

    private var header: some View {
        HStack(spacing: 7) {
            Image(systemName: "sparkles")
                .font(.caption.weight(.bold))
                .foregroundStyle(NutsNewsWidgetPalette.amber)

            Text("NutsNews")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .tracking(0.4)

            Spacer(minLength: 0)
        }
    }

    private var footer: some View {
        HStack(spacing: 7) {
            Text(entry.mood)
                .font(.caption2.weight(.bold))
                .foregroundStyle(NutsNewsWidgetPalette.darkText)
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    Capsule(style: .continuous)
                        .fill(NutsNewsWidgetPalette.amber)
                )

            Text(entry.source)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.68))
                .lineLimit(1)

            Spacer(minLength: 0)
        }
    }

    private var widgetBackground: some View {
        LinearGradient(
            colors: [
                NutsNewsWidgetPalette.deepBackground,
                NutsNewsWidgetPalette.surface,
                NutsNewsWidgetPalette.warmSurface
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private enum NutsNewsWidgetPalette {
    static let deepBackground = Color(red: 0.055, green: 0.047, blue: 0.035)
    static let surface = Color(red: 0.145, green: 0.105, blue: 0.055)
    static let warmSurface = Color(red: 0.235, green: 0.145, blue: 0.055)
    static let amber = Color(red: 0.965, green: 0.680, blue: 0.255)
    static let darkText = Color(red: 0.110, green: 0.075, blue: 0.035)
}

struct NutsNewsDailyWidget: Widget {
    private let kind = "NutsNewsDailyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NutsNewsWidgetProvider()) { entry in
            NutsNewsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NutsNews Daily")
        .description("A calm good-news headline for your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
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
