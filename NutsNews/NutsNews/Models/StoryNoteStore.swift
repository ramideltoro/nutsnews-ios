//
//  StoryNoteStore.swift
//  NutsNews
//

import Foundation

struct StoryNote: Codable, Equatable, Identifiable {
    let articleID: String
    let articleTitle: String
    var text: String
    var updatedAt: Date

    var id: String { articleID }
}

enum StoryNoteStore {
    static let storageKey = "nutsnews.storyNotes.v1"
    static let emptyRawValue = "{}"

    static func notes(from rawValue: String) -> [String: StoryNote] {
        guard let data = rawValue.data(using: .utf8) else {
            return [:]
        }

        return (try? JSONDecoder().decode([String: StoryNote].self, from: data)) ?? [:]
    }

    static func noteText(for article: Article, rawValue: String) -> String {
        notes(from: rawValue)[article.id]?.text ?? ""
    }

    static func hasNote(for article: Article, rawValue: String) -> Bool {
        !noteText(for: article, rawValue: rawValue)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    static func rawValue(
        settingNoteText noteText: String,
        article: Article,
        currentRawValue: String
    ) -> String {
        var currentNotes = notes(from: currentRawValue)
        let cleanedText = noteText.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanedText.isEmpty {
            currentNotes.removeValue(forKey: article.id)
        } else {
            currentNotes[article.id] = StoryNote(
                articleID: article.id,
                articleTitle: article.title,
                text: cleanedText,
                updatedAt: Date()
            )
        }

        return encodedRawValue(from: currentNotes)
    }

    private static func encodedRawValue(from notes: [String: StoryNote]) -> String {
        guard let data = try? JSONEncoder().encode(notes),
              let rawValue = String(data: data, encoding: .utf8) else {
            return emptyRawValue
        }

        return rawValue
    }
}
