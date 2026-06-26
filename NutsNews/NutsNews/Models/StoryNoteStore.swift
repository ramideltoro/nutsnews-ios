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
        let currentNotes = notes(from: rawValue)

        if let note = currentNotes[noteKey(for: article)] {
            return note.text
        }

        // Backward compatibility: earlier builds saved notes by article.id.
        // Some app screens use the database id, while saved/search/native cards may use
        // the original URL as the stable id. This fallback keeps already-written notes.
        if let legacyNote = currentNotes[legacyArticleIDKey(for: article)] {
            return legacyNote.text
        }

        return ""
    }

    static func hasNote(for article: Article, rawValue: String) -> Bool {
        !noteText(for: article, rawValue: rawValue)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    static func noteCount(from rawValue: String) -> Int {
        notes(from: rawValue).values.filter {
            !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }.count
    }

    static func rawValue(
        settingNoteText noteText: String,
        article: Article,
        currentRawValue: String
    ) -> String {
        var currentNotes = notes(from: currentRawValue)
        let cleanedText = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        let stableKey = noteKey(for: article)
        let legacyKey = legacyArticleIDKey(for: article)

        // Remove the old per-screen key so one article cannot have different notes
        // depending on whether it was opened from Home, Search, Saved, Mood, or Digest.
        if legacyKey != stableKey {
            currentNotes.removeValue(forKey: legacyKey)
        }

        if cleanedText.isEmpty {
            currentNotes.removeValue(forKey: stableKey)
        } else {
            currentNotes[stableKey] = StoryNote(
                articleID: stableKey,
                articleTitle: article.title,
                text: cleanedText,
                updatedAt: Date()
            )
        }

        return encodedRawValue(from: currentNotes)
    }

    private static func noteKey(for article: Article) -> String {
        LikedStoryStore.stableID(for: article)
    }

    private static func legacyArticleIDKey(for article: Article) -> String {
        article.id.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func encodedRawValue(from notes: [String: StoryNote]) -> String {
        guard let data = try? JSONEncoder().encode(notes),
              let rawValue = String(data: data, encoding: .utf8) else {
            return emptyRawValue
        }

        return rawValue
    }
}
