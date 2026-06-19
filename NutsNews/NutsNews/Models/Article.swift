//
//  Article.swift
//  NutsNews
//

import Foundation

struct Article: Identifiable, Decodable, Equatable {
    let id: String
    let title: String
    let summary: String
    let originalURL: URL?
    let source: String
    let publishedAt: String?
    let createdAt: String?
    let thumbnailURL: URL?
    let categories: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case summary
        case source
        case categories
        case category

        case aiSummarySnake = "ai_summary"
        case aiSummaryCamel = "aiSummary"

        case originalURLSnake = "original_url"
        case originalURLCamel = "originalUrl"

        case publishedAtSnake = "published_at"
        case publishedAtCamel = "publishedAt"

        case publishedOnSiteAtSnake = "published_on_site_at"
        case publishedOnSiteAtCamel = "publishedOnSiteAt"

        case createdAtSnake = "created_at"
        case createdAtCamel = "createdAt"

        case thumbnailURLSnake = "thumbnail_url"
        case thumbnailURLCamel = "thumbnailUrl"

        case imageURLSnake = "image_url"
        case imageURLCamel = "imageUrl"
    }

    init(
        id: String,
        title: String,
        summary: String,
        originalURL: URL?,
        source: String,
        publishedAt: String?,
        createdAt: String?,
        thumbnailURL: URL?,
        categories: [String]
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.originalURL = originalURL
        self.source = source
        self.publishedAt = publishedAt
        self.createdAt = createdAt
        self.thumbnailURL = thumbnailURL
        self.categories = Self.cleanCategoryLabels(categories)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else if let intID = try? container.decode(Int.self, forKey: .id) {
            id = String(intID)
        } else {
            id = UUID().uuidString
        }

        title = Self.decodeString(
            from: container,
            keys: [.title]
        ) ?? "Untitled story"

        summary = Self.decodeString(
            from: container,
            keys: [.summary, .aiSummaryCamel, .aiSummarySnake]
        ) ?? ""

        source = Self.decodeString(
            from: container,
            keys: [.source]
        ) ?? "NutsNews"

        publishedAt = Self.decodeString(
            from: container,
            keys: [.publishedAtCamel, .publishedAtSnake]
        )

        createdAt = Self.decodeString(
            from: container,
            keys: [
                .publishedOnSiteAtCamel,
                .publishedOnSiteAtSnake,
                .createdAtCamel,
                .createdAtSnake
            ]
        )

        originalURL = Self.decodeURL(
            from: container,
            keys: [.originalURLCamel, .originalURLSnake]
        )

        thumbnailURL = Self.decodeURL(
            from: container,
            keys: [
                .thumbnailURLCamel,
                .thumbnailURLSnake,
                .imageURLCamel,
                .imageURLSnake
            ]
        )

        categories = Self.decodeCategoryLabels(from: container)
    }

    var displayDate: String {
        guard let rawDate = publishedAt ?? createdAt else {
            return "Recently"
        }

        if let date = Self.parseDate(rawDate) {
            return Self.displayDateFormatter.string(from: date)
        }

        return rawDate
    }

    private static func decodeCategoryLabels(
        from container: KeyedDecodingContainer<CodingKeys>
    ) -> [String] {
        if let decodedCategories = try? container.decode([String].self, forKey: .categories) {
            return cleanCategoryLabels(decodedCategories)
        }

        if let categoriesString = decodeString(from: container, keys: [.categories, .category]) {
            return splitCategoryString(categoriesString)
        }

        // The web app falls back to an Uplifting badge when a row has no category.
        return ["Uplifting"]
    }

    private static func splitCategoryString(_ value: String) -> [String] {
        let labels = value
            .components(separatedBy: CharacterSet(charactersIn: "|,;/"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return labels.isEmpty ? ["Uplifting"] : cleanCategoryLabels(labels)
    }

    private static func cleanCategoryLabels(_ labels: [String]) -> [String] {
        var seen = Set<String>()
        var cleanedLabels: [String] = []

        for label in labels {
            let cleanedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanedLabel.isEmpty else {
                continue
            }

            let lookupKey = cleanedLabel.lowercased()
            guard !seen.contains(lookupKey) else {
                continue
            }

            seen.insert(lookupKey)
            cleanedLabels.append(cleanedLabel)
        }

        return cleanedLabels.isEmpty ? ["Uplifting"] : cleanedLabels
    }

    private static func decodeString(
        from container: KeyedDecodingContainer<CodingKeys>,
        keys: [CodingKeys]
    ) -> String? {
        for key in keys {
            if let value = try? container.decode(String.self, forKey: key) {
                let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)

                if !trimmedValue.isEmpty {
                    return trimmedValue
                }
            }
        }

        return nil
    }

    private static func decodeURL(
        from container: KeyedDecodingContainer<CodingKeys>,
        keys: [CodingKeys]
    ) -> URL? {
        guard let urlString = decodeString(from: container, keys: keys) else {
            return nil
        }

        return URL(string: urlString)
    }

    private static func parseDate(_ value: String) -> Date? {
        let formatterWithFractionalSeconds = ISO8601DateFormatter()
        formatterWithFractionalSeconds.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date = formatterWithFractionalSeconds.date(from: value) {
            return date
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        if let date = formatter.date(from: value) {
            return date
        }

        return nil
    }

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
