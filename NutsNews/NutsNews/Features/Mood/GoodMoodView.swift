//
//  GoodMoodView.swift
//  NutsNews
//

import SwiftUI
import UIKit

struct GoodMoodView: View {
    let articles: [Article]
    let onClose: () -> Void

    @State private var selectedMood: GoodMood = .hopeful
    @State private var selectedArticle: Article?
    @AppStorage(SavedStoryStore.storageKey) private var savedStoriesRawValue = SavedStoryStore.emptyRawValue
    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue
    @AppStorage(NutsNewsSettings.hapticsEnabledKey) private var hapticsEnabled = NutsNewsSettings.hapticsDefaultEnabled

    private var selectedTheme: NutsNewsAppTheme {
        NutsNewsAppTheme(rawValue: themeRawValue) ?? NutsNewsTheme.defaultTheme
    }

    private var rankedArticles: [Article] {
        let safeArticles = articles.filter { article in
            !article.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && article.thumbnailURL != nil
        }

        let scoredArticles = safeArticles
            .map { article in
                (article: article, score: selectedMood.score(for: article))
            }
            .filter { $0.score > 0 }
            .sorted { left, right in
                if left.score == right.score {
                    return left.article.displayDate > right.article.displayDate
                }

                return left.score > right.score
            }
            .map(\.article)

        if scoredArticles.isEmpty {
            return Array(safeArticles.prefix(12))
        }

        return Array(scoredArticles.prefix(16))
    }

    private var featuredArticle: Article? {
        rankedArticles.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .overlay(NutsNewsTheme.backgroundOverlay)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                        header
                        moodPicker
                        featuredSection
                        recommendedSection
                    }
                    .padding(NutsNewsTheme.spacingM)
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
                Text("Good Mood")
                    .font(.system(size: 30, weight: .light, design: .serif))
                    .tracking(1.3)
                    .foregroundStyle(NutsNewsTheme.amberHighlight)

                Text("Pick the feeling you want and NutsNews will match a calm story for you.")
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
            .accessibilityLabel("Close Good Mood")
        }
    }

    private var moodPicker: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 142), spacing: NutsNewsTheme.spacingS)],
            alignment: .leading,
            spacing: NutsNewsTheme.spacingS
        ) {
            ForEach(GoodMood.allCases) { mood in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.84)) {
                        selectedMood = mood
                    }
                } label: {
                    VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXS) {
                        HStack(spacing: NutsNewsTheme.spacingXS) {
                            Image(systemName: mood.iconName)
                                .font(.system(size: 16, weight: .bold))

                            Text(mood.title)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .lineLimit(1)
                        }

                        Text(mood.subtitle)
                            .font(.caption)
                            .foregroundStyle(isSelected(mood) ? NutsNewsTheme.buttonText.opacity(0.82) : NutsNewsTheme.secondaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .foregroundStyle(isSelected(mood) ? NutsNewsTheme.buttonText : NutsNewsTheme.primaryText)
                    .frame(maxWidth: .infinity, minHeight: 86, alignment: .topLeading)
                    .padding(NutsNewsTheme.spacingS)
                    .background(moodBackground(isSelected: isSelected(mood)))
                    .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous)
                            .stroke(isSelected(mood) ? Color.clear : NutsNewsTheme.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: isSelected(mood) ? NutsNewsTheme.amberGlow.opacity(0.55) : .clear, radius: 18, x: 0, y: 10)
                    .scaleEffect(isSelected(mood) ? 1.02 : 1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Choose \(mood.title) mood")
            }
        }
    }

    @ViewBuilder
    private func moodBackground(isSelected: Bool) -> some View {
        if isSelected {
            NutsNewsTheme.buttonGradient
        } else {
            NutsNewsTheme.cardBackgroundStrong
        }
    }

    private func isSelected(_ mood: GoodMood) -> Bool {
        selectedMood == mood
    }

    @ViewBuilder
    private var featuredSection: some View {
        if let featuredArticle {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                sectionTitle("Best match")

                GoodMoodFeaturedCard(
                    article: featuredArticle,
                    selectedMood: selectedMood,
                    isSaved: SavedStoryStore.isSaved(featuredArticle, rawValue: savedStoriesRawValue),
                    onOpen: { selectedArticle = featuredArticle },
                    onSaveToggle: { toggleSaved(featuredArticle) }
                )
            }
        } else {
            emptyState
        }
    }

    @ViewBuilder
    private var recommendedSection: some View {
        if !rankedArticles.dropFirst().isEmpty {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                sectionTitle("More \(selectedMood.title.lowercased()) stories")

                ForEach(Array(rankedArticles.dropFirst())) { article in
                    GoodMoodResultRow(
                        article: article,
                        isSaved: SavedStoryStore.isSaved(article, rawValue: savedStoriesRawValue),
                        onOpen: { selectedArticle = article },
                        onSaveToggle: { toggleSaved(article) }
                    )
                }
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(NutsNewsTheme.primaryText)
            .padding(.top, NutsNewsTheme.spacingXS)
    }

    private var emptyState: some View {
        VStack(spacing: NutsNewsTheme.spacingM) {
            Image(systemName: "sparkles")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amber)

            Text("No mood matches yet")
                .font(.headline)
                .foregroundStyle(NutsNewsTheme.primaryText)

            Text("Load a few stories on the home screen, then come back for a personalized pick.")
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, NutsNewsTheme.spacingXL)
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

private enum GoodMood: String, CaseIterable, Identifiable {
    case calm
    case hopeful
    case inspired
    case curious

    var id: String { rawValue }

    var title: String {
        switch self {
        case .calm: "Calm"
        case .hopeful: "Hopeful"
        case .inspired: "Inspired"
        case .curious: "Curious"
        }
    }

    var subtitle: String {
        switch self {
        case .calm: "gentle, peaceful stories"
        case .hopeful: "kindness and recovery"
        case .inspired: "people doing big things"
        case .curious: "science, animals, culture"
        }
    }

    var iconName: String {
        switch self {
        case .calm: "leaf.fill"
        case .hopeful: "heart.fill"
        case .inspired: "star.fill"
        case .curious: "sparkle.magnifyingglass"
        }
    }

    private var keywords: [String] {
        switch self {
        case .calm:
            ["calm", "peace", "quiet", "mindful", "garden", "nature", "wellness", "healing", "gentle", "sleep", "walk"]
        case .hopeful:
            ["hope", "kind", "rescue", "recover", "community", "help", "volunteer", "support", "reunited", "donate", "neighbors"]
        case .inspired:
            ["inspire", "achievement", "award", "record", "student", "teacher", "artist", "athlete", "first", "dream", "success"]
        case .curious:
            ["science", "animal", "space", "discovery", "research", "museum", "culture", "history", "nature", "ocean", "rare"]
        }
    }

    private var categoryKeywords: [String] {
        switch self {
        case .calm:
            ["wellness", "lifestyle", "nature", "travel"]
        case .hopeful:
            ["community", "uplifting", "animals", "human-interest"]
        case .inspired:
            ["achievement", "inspiring", "culture", "education"]
        case .curious:
            ["science", "animals", "culture", "travel"]
        }
    }

    func score(for article: Article) -> Int {
        let title = article.title.lowercased()
        let summary = article.summary.lowercased()
        let source = article.source.lowercased()
        let categories = article.categories.map { $0.lowercased() }

        var score = 0

        for category in categories {
            if categoryKeywords.contains(where: { category.contains($0) }) {
                score += 5
            }
        }

        for keyword in keywords {
            if title.contains(keyword) { score += 4 }
            if summary.contains(keyword) { score += 2 }
            if source.contains(keyword) { score += 1 }
        }

        return score
    }
}

private struct GoodMoodFeaturedCard: View {
    let article: Article
    let selectedMood: GoodMood
    let isSaved: Bool
    let onOpen: () -> Void
    let onSaveToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            thumbnail

            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                HStack(spacing: NutsNewsTheme.spacingXS) {
                    Image(systemName: selectedMood.iconName)
                        .font(.system(size: 13, weight: .bold))

                    Text("\(selectedMood.title) pick")
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
                        Image(systemName: "sparkles")
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

private struct GoodMoodResultRow: View {
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
