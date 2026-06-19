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

        case originalURLSnake = "original_url"
        case originalURLCamel = "originalUrl"

        case publishedAtSnake = "published_at"
        case publishedAtCamel = "publishedAt"

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
        self.categories = categories
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
            keys: [.summary]
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
            keys: [.createdAtCamel, .createdAtSnake]
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

        if let decodedCategories = try? container.decode([String].self, forKey: .categories) {
            categories = decodedCategories
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        } else if let categoryString = try? container.decode(String.self, forKey: .categories) {
            categories = categoryString
                .components(separatedBy: CharacterSet(charactersIn: "|,"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        } else {
            categories = []
        }
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
