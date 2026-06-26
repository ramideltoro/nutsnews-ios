//
//  DailyDigestView.swift
//  NutsNews
//

import SwiftUI
import UIKit

struct DailyDigestView: View {
    let articles: [Article]
    let onClose: () -> Void

    @State private var selectedArticle: Article?
    @AppStorage(SavedStoryStore.storageKey) private var savedStoriesRawValue = SavedStoryStore.emptyRawValue
    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue
    @AppStorage(NutsNewsSettings.hapticsEnabledKey) private var hapticsEnabled = NutsNewsSettings.hapticsDefaultEnabled

    private var selectedTheme: NutsNewsAppTheme {
        NutsNewsAppTheme(rawValue: themeRawValue) ?? NutsNewsTheme.defaultTheme
    }

    private var digestArticles: [Article] {
        Array(
            articles
                .filter { article in
                    !article.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && article.thumbnailURL != nil
                }
                .prefix(24)
        )
    }

    private var featuredArticle: Article? {
        rankedDigestArticles.first
    }

    private var quickReadArticle: Article? {
        rankedDigestArticles.first { article in
            article.summary.count <= 260 && article.id != featuredArticle?.id
        } ?? rankedDigestArticles.dropFirst().first
    }

    private var savedCandidateArticle: Article? {
        rankedDigestArticles.first { article in
            !SavedStoryStore.isSaved(article, rawValue: savedStoriesRawValue) && article.id != featuredArticle?.id
        } ?? rankedDigestArticles.dropFirst().first
    }

    private var rankedDigestArticles: [Article] {
        digestArticles.sorted { left, right in
            let leftScore = digestScore(for: left)
            let rightScore = digestScore(for: right)

            if leftScore == rightScore {
                return left.displayDate > right.displayDate
            }

            return leftScore > rightScore
        }
    }

    private var categoryCounts: [(label: String, count: Int)] {
        let counts = digestArticles
            .flatMap(\.categories)
            .reduce(into: [String: Int]()) { partialResult, category in
                let cleaned = category.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !cleaned.isEmpty else { return }
                partialResult[cleaned, default: 0] += 1
            }

        return counts
            .map { (label: $0.key, count: $0.value) }
            .sorted { left, right in
                if left.count == right.count {
                    return left.label.localizedCaseInsensitiveCompare(right.label) == .orderedAscending
                }

                return left.count > right.count
            }
            .prefix(8)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .overlay(NutsNewsTheme.backgroundOverlay)
                    .ignoresSafeArea()

                if digestArticles.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                            header
                            summaryStrip
                            categoryPulseCard
                            featuredSection
                            quickActionsGrid
                            moreStoriesSection
                        }
                        .padding(NutsNewsTheme.spacingM)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
                    .preferredColorScheme(selectedTheme.preferredColorScheme)
            }
        }
        .preferredColorScheme(selectedTheme.preferredColorScheme)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: NutsNewsTheme.spacingM) {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXS) {
                Text("Today’s Picks")
                    .font(.system(size: 30, weight: .light, design: .serif))
                    .tracking(1.3)
                    .foregroundStyle(NutsNewsTheme.amberHighlight)

                Text("A calm native digest from the positive stories currently ready for you.")
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(NutsNewsTheme.amberHighlight)
                    .frame(width: 36, height: 36)
                    .background(NutsNewsTheme.badgeBackground)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close Today’s Picks")
        }
    }

    private var summaryStrip: some View {
        HStack(spacing: NutsNewsTheme.spacingS) {
            DigestMetricTile(title: "Stories", value: "\(digestArticles.count)", systemImage: "newspaper.fill")
            DigestMetricTile(title: "Sources", value: "\(uniqueSourceCount)", systemImage: "building.2.fill")
            DigestMetricTile(title: "Saved", value: "\(savedStoryCount)", systemImage: "bookmark.fill")
        }
    }

    private var categoryPulseCard: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
            HStack(spacing: NutsNewsTheme.spacingXS) {
                Image(systemName: "circle.grid.2x2.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(NutsNewsTheme.amberHighlight)

                Text("Today’s positive mix")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.primaryText)
            }

            if categoryCounts.isEmpty {
                Text("A simple uplifting feed is ready for you.")
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 108), spacing: NutsNewsTheme.spacingXS)], spacing: NutsNewsTheme.spacingXS) {
                    ForEach(categoryCounts, id: \.label) { category in
                        HStack(spacing: NutsNewsTheme.spacingXS) {
                            Text(category.label)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)

                            Text("\(category.count)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(NutsNewsTheme.amber)
                        }
                        .foregroundStyle(NutsNewsTheme.secondaryText)
                        .padding(.horizontal, NutsNewsTheme.spacingS)
                        .padding(.vertical, NutsNewsTheme.spacingXS)
                        .frame(maxWidth: .infinity)
                        .background(NutsNewsTheme.badgeBackground)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(NutsNewsTheme.spacingM)
        .background(NutsNewsTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var featuredSection: some View {
        if let featuredArticle {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                sectionTitle("Start here")

                DigestFeaturedCard(
                    article: featuredArticle,
                    isSaved: SavedStoryStore.isSaved(featuredArticle, rawValue: savedStoriesRawValue),
                    onOpen: { selectedArticle = featuredArticle },
                    onSaveToggle: { toggleSaved(featuredArticle) }
                )
            }
        }
    }

    private var quickActionsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: NutsNewsTheme.spacingS) {
            if let quickReadArticle {
                DigestActionCard(
                    title: "Quick read",
                    subtitle: quickReadArticle.title,
                    systemImage: "timer",
                    onTap: { selectedArticle = quickReadArticle }
                )
            }

            if let savedCandidateArticle {
                DigestActionCard(
                    title: "Worth saving",
                    subtitle: savedCandidateArticle.title,
                    systemImage: "bookmark.fill",
                    onTap: { toggleSaved(savedCandidateArticle) }
                )
            }
        }
    }

    @ViewBuilder
    private var moreStoriesSection: some View {
        let remaining = rankedDigestArticles.filter { article in
            article.id != featuredArticle?.id && article.id != quickReadArticle?.id
        }

        if !remaining.isEmpty {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                sectionTitle("More from today")

                ForEach(Array(remaining.prefix(10))) { article in
                    DigestStoryRow(
                        article: article,
                        isSaved: SavedStoryStore.isSaved(article, rawValue: savedStoriesRawValue),
                        onOpen: { selectedArticle = article },
                        onSaveToggle: { toggleSaved(article) }
                    )
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: NutsNewsTheme.spacingM) {
            Image(systemName: "newspaper")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amber)

            Text("No picks ready yet")
                .font(.headline)
                .foregroundStyle(NutsNewsTheme.primaryText)

            Text("Load stories on the home screen, then come back for a calm daily digest.")
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, NutsNewsTheme.spacingL)

            Button(action: onClose) {
                Text("Back to home")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.buttonText)
                    .padding(.horizontal, NutsNewsTheme.spacingM)
                    .padding(.vertical, NutsNewsTheme.spacingS)
                    .background(NutsNewsTheme.buttonGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(NutsNewsTheme.spacingM)
    }

    private var uniqueSourceCount: Int {
        Set(digestArticles.map { $0.source.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }).count
    }

    private var savedStoryCount: Int {
        SavedStoryStore.stories(from: savedStoriesRawValue).count
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(NutsNewsTheme.primaryText)
            .padding(.top, NutsNewsTheme.spacingXS)
    }

    private func digestScore(for article: Article) -> Int {
        let title = article.title.lowercased()
        let summary = article.summary.lowercased()
        let categories = article.categories.map { $0.lowercased() }
        let keywords = [
            "good", "kind", "hope", "uplifting", "community", "rescue", "inspire", "student", "teacher",
            "science", "animal", "nature", "garden", "healing", "achievement", "volunteer", "reunited"
        ]

        var score = 0

        for category in categories {
            if ["uplifting", "community", "wellness", "achievement", "animals", "science"].contains(where: { category.contains($0) }) {
                score += 5
            }
        }

        for keyword in keywords {
            if title.contains(keyword) { score += 4 }
            if summary.contains(keyword) { score += 2 }
        }

        if article.thumbnailURL != nil { score += 2 }
        if !article.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { score += 1 }

        return score
    }

    private func toggleSaved(_ article: Article) {
        let currentlySaved = SavedStoryStore.isSaved(article, rawValue: savedStoriesRawValue)
        savedStoriesRawValue = SavedStoryStore.rawValue(
            settingSaved: !currentlySaved,
            article: article,
            currentRawValue: savedStoriesRawValue
        )

        if hapticsEnabled {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

private struct DigestMetricTile: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXS) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(NutsNewsTheme.amberHighlight)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(NutsNewsTheme.primaryText)

            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(NutsNewsTheme.mutedText)
        }
        .padding(NutsNewsTheme.spacingS)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutsNewsTheme.cardBackgroundStrong)
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
    }
}

private struct DigestFeaturedCard: View {
    let article: Article
    let isSaved: Bool
    let onOpen: () -> Void
    let onSaveToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            thumbnail

            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                HStack(spacing: NutsNewsTheme.spacingXS) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .bold))

                    Text("Daily pick")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .foregroundStyle(NutsNewsTheme.amberHighlight)

                Text(article.title)
                    .font(.headline)
                    .foregroundStyle(NutsNewsTheme.primaryText)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)

                if !article.summary.isEmpty {
                    Text(article.summary)
                        .font(.subheadline)
                        .foregroundStyle(NutsNewsTheme.secondaryText)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                }

                HStack(spacing: NutsNewsTheme.spacingS) {
                    Button(action: onOpen) {
                        Text("Open story")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(NutsNewsTheme.buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(NutsNewsTheme.buttonGradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button(action: onSaveToggle) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(NutsNewsTheme.amberHighlight)
                            .frame(width: 42, height: 42)
                            .background(NutsNewsTheme.badgeBackground)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isSaved ? "Remove saved story" : "Save story")
                }
            }
            .padding(NutsNewsTheme.spacingM)
        }
        .background(NutsNewsTheme.cardBackgroundStrong)
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
    }

    private var thumbnail: some View {
        ZStack {
            NutsNewsTheme.badgeBackground

            if let thumbnailURL = article.thumbnailURL {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "newspaper")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(NutsNewsTheme.amber)
                    case .empty:
                        ProgressView()
                            .tint(NutsNewsTheme.amber)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .frame(height: 190)
        .frame(maxWidth: .infinity)
        .clipped()
    }
}

private struct DigestActionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXS) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(NutsNewsTheme.amberHighlight)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.primaryText)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(NutsNewsTheme.spacingS)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
            .background(NutsNewsTheme.cardBackgroundStrong)
            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous)
                    .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct DigestStoryRow: View {
    let article: Article
    let isSaved: Bool
    let onOpen: () -> Void
    let onSaveToggle: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(alignment: .top, spacing: NutsNewsTheme.spacingS) {
                thumbnail

                VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXS) {
                    Text(article.source)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(NutsNewsTheme.amberSoft)
                        .lineLimit(1)

                    Text(article.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(NutsNewsTheme.primaryText)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: NutsNewsTheme.spacingS) {
                        Text(article.displayDate)
                            .font(.caption2)
                            .foregroundStyle(NutsNewsTheme.mutedText)
                            .lineLimit(1)

                        Spacer(minLength: NutsNewsTheme.spacingXS)

                        Button(action: onSaveToggle) {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(NutsNewsTheme.amberHighlight)
                                .frame(width: 30, height: 30)
                                .background(NutsNewsTheme.badgeBackground)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isSaved ? "Remove saved story" : "Save story")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(NutsNewsTheme.spacingS)
            .background(NutsNewsTheme.cardBackgroundStrong)
            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous)
                    .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var thumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: NutsNewsTheme.radiusS, style: .continuous)
                .fill(NutsNewsTheme.badgeBackground)

            if let thumbnailURL = article.thumbnailURL {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "newspaper")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(NutsNewsTheme.amber)
                    case .empty:
                        ProgressView()
                            .tint(NutsNewsTheme.amber)
                            .scaleEffect(0.7)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .frame(width: 96, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusS, style: .continuous))
        .clipped()
    }
}
