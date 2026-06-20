//
//  NutsNewsArticlesCache.swift
//  NutsNews
//

import Foundation

actor NutsNewsArticlesCache {
    static let shared = NutsNewsArticlesCache()

    private struct CacheEnvelope: Codable {
        let cachedAt: Date
        let data: Data
    }

    private let cacheDirectory: URL

    private init() {
        let baseDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory

        cacheDirectory = baseDirectory.appendingPathComponent(
            "NutsNewsArticleResponses",
            isDirectory: true
        )
    }

    func cachedData(for key: String, maxAge: TimeInterval?) -> Data? {
        let cacheURL = cacheFileURL(for: key)

        guard let envelopeData = try? Data(contentsOf: cacheURL) else {
            return nil
        }

        guard let envelope = try? JSONDecoder().decode(CacheEnvelope.self, from: envelopeData) else {
            try? FileManager.default.removeItem(at: cacheURL)
            return nil
        }

        if let maxAge,
           Date().timeIntervalSince(envelope.cachedAt) > maxAge {
            return nil
        }

        return envelope.data
    }

    func store(_ data: Data, for key: String) {
        do {
            try FileManager.default.createDirectory(
                at: cacheDirectory,
                withIntermediateDirectories: true
            )

            let envelope = CacheEnvelope(cachedAt: Date(), data: data)
            let envelopeData = try JSONEncoder().encode(envelope)

            try envelopeData.write(to: cacheFileURL(for: key), options: [.atomic])
        } catch {
            // Cache failures should never block users from reading the feed.
        }
    }

    func removeCachedData(for key: String) {
        try? FileManager.default.removeItem(at: cacheFileURL(for: key))
    }

    private func cacheFileURL(for key: String) -> URL {
        cacheDirectory.appendingPathComponent("\(safeFileName(for: key)).json")
    }

    private func safeFileName(for key: String) -> String {
        Data(key.utf8)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
