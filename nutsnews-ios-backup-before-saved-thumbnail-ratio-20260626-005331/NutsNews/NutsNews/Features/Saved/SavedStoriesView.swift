//
//  SavedStoriesView.swift
//  NutsNews
//

import SwiftUI

struct SavedStoriesView: View {
    let onClose: () -> Void

    @AppStorage(SavedStoryStore.storageKey) private var savedStoriesRawValue = SavedStoryStore.emptyRawValue
    @AppStorage(LikedStoryStore.storageKey) private var likedStoryIDsRawValue = LikedStoryStore.emptyRawValue
    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue
    @State private var searchText = ""
    @State private var selectedStory: SavedStory?

    private var selectedTheme: NutsNewsAppTheme {
        NutsNewsAppTheme(rawValue: themeRawValue) ?? NutsNewsTheme.defaultTheme
    }

    private var savedStories: [SavedStory] {
        SavedStoryStore.stories(from: savedStoriesRawValue)
    }

    private var filteredStories: [SavedStory] {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSearchText.isEmpty else {
            return savedStories
        }

        return savedStories.filter { story in
            story.matches(searchText: trimmedSearchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .overlay(NutsNewsTheme.backgroundOverlay)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("Saved Stories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", action: onClose)
                        .fontWeight(.semibold)
                        .foregroundStyle(NutsNewsTheme.amber)
                }
            }
            .searchable(text: $searchText, prompt: "Search saved stories")
            .preferredColorScheme(selectedTheme.preferredColorScheme)
            .sheet(item: $selectedStory) { story in
                ArticleDetailView(article: story.article)
                    .preferredColorScheme(selectedTheme.preferredColorScheme)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if savedStories.isEmpty {
            emptySavedStoriesView
        } else if filteredStories.isEmpty {
            emptySearchView
        } else {
            savedStoriesList
        }
    }

    private var savedStoriesList: some View {
        ScrollView {
            LazyVStack(spacing: NutsNewsTheme.spacingM) {
                savedStatsCard

                ForEach(filteredStories) { story in
                    SavedStoryRow(
                        story: story,
                        openAction: {
                            selectedStory = story
                        },
                        removeAction: {
                            remove(story)
                        }
                    )
                }
            }
            .padding(NutsNewsTheme.spacingM)
        }
    }

    private var savedStatsCard: some View {
        HStack(spacing: NutsNewsTheme.spacingM) {
            Image(systemName: "bookmark.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(NutsNewsTheme.amberHighlight)
                .frame(width: 42, height: 42)
                .background(NutsNewsTheme.badgeBackground)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                Text("Your good-news library")
                    .font(.headline)
                    .foregroundStyle(NutsNewsTheme.primaryText)

                Text(savedStories.count == 1 ? "1 story saved on this device" : "\(savedStories.count) stories saved on this device")
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(NutsNewsTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutsNewsTheme.cardBackgroundStrong)
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
    }

    private var emptySavedStoriesView: some View {
        VStack(spacing: NutsNewsTheme.spacingM) {
            Image(systemName: "bookmark")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amber)

            Text("No saved stories yet")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(NutsNewsTheme.primaryText)

            Text("Tap the heart on any story to build your own calm, positive reading list.")
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, NutsNewsTheme.spacingL)
        }
        .padding(NutsNewsTheme.spacingM)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptySearchView: some View {
        VStack(spacing: NutsNewsTheme.spacingM) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amber)

            Text("No saved stories found")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(NutsNewsTheme.primaryText)

            Text("Try searching by title, summary, source, or category.")
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(NutsNewsTheme.spacingM)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func remove(_ story: SavedStory) {
        withAnimation(.easeInOut(duration: 0.25)) {
            savedStoriesRawValue = SavedStoryStore.rawValue(
                removing: story,
                currentRawValue: savedStoriesRawValue
            )
            likedStoryIDsRawValue = LikedStoryStore.rawValue(
                settingLiked: false,
                article: story.article,
                currentRawValue: likedStoryIDsRawValue
            )
        }
    }
}

private struct SavedStoryRow: View {
    let story: SavedStory
    let openAction: () -> Void
    let removeAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
            heroImage
            categoryRow
            titleText
            summaryText
            footerRow
        }
        .padding(NutsNewsTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutsNewsTheme.cardBackgroundStrong)
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
        .shadow(color: NutsNewsTheme.amberGlow, radius: 14, x: 0, y: 8)
    }

    @ViewBuilder
    private var heroImage: some View {
        if let thumbnailURLString = story.thumbnailURLString,
           let thumbnailURL = URL(string: thumbnailURLString) {
            AsyncImage(url: thumbnailURL) { phase in
                switch phase {
                case .empty:
                    imagePlaceholder
                        .overlay {
                            ProgressView()
                                .tint(NutsNewsTheme.amber)
                        }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(3.0 / 2.0, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.imageCornerRadius, style: .continuous))
                        .clipped()
                case .failure:
                    imagePlaceholder
                @unknown default:
                    imagePlaceholder
                }
            }
        } else {
            imagePlaceholder
        }
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: NutsNewsTheme.imageCornerRadius, style: .continuous)
            .fill(NutsNewsTheme.badgeBackground)
            .aspectRatio(3.0 / 2.0, contentMode: .fit)
            .overlay {
                Image(systemName: "newspaper")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(NutsNewsTheme.amber)
            }
    }

    @ViewBuilder
    private var categoryRow: some View {
        if !story.categories.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: NutsNewsTheme.spacingXS) {
                    ForEach(Array(story.categories.prefix(5).enumerated()), id: \.element) { index, category in
                        Text(category)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(NutsNewsTheme.amberHighlight)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(NutsNewsTheme.badgeBackground)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
                            )
                    }
                }
            }
            .frame(height: 30)
        }
    }

    private var titleText: some View {
        Text(story.title)
            .font(.system(size: 19, weight: .bold, design: .rounded))
            .foregroundStyle(NutsNewsTheme.primaryText)
            .lineSpacing(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var summaryText: some View {
        if !story.summary.isEmpty {
            Text(story.summary)
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .lineSpacing(3)
                .lineLimit(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var footerRow: some View {
        HStack(alignment: .center, spacing: NutsNewsTheme.spacingS) {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                Text("Saved \(story.savedAtDisplayText)")
                    .font(.caption)
                    .foregroundStyle(NutsNewsTheme.mutedText)

                Text(story.source)
                    .font(.caption)
                    .foregroundStyle(NutsNewsTheme.amberSoft)
                    .lineLimit(1)
            }

            Spacer(minLength: NutsNewsTheme.spacingS)

            Button(action: openAction) {
                Text("Open")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.buttonText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(NutsNewsTheme.buttonGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open saved story")

            Button(action: removeAction) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NutsNewsTheme.amberHighlight)
                    .frame(width: 34, height: 34)
                    .background(NutsNewsTheme.badgeBackground)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove saved story")
        }
    }
}

private extension SavedStory {
    func matches(searchText: String) -> Bool {
        let searchTerms = searchText
            .lowercased()
            .split(separator: " ")
            .map(String.init)

        guard !searchTerms.isEmpty else { return true }

        let searchableText = ([title, summary, source] + categories)
            .joined(separator: " ")
            .lowercased()

        return searchTerms.allSatisfy { searchableText.contains($0) }
    }
}
