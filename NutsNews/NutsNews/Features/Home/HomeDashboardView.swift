//
//  HomeDashboardView.swift
//  NutsNews
//

import SwiftUI

struct HomeDashboardView: View {
    let articles: [Article]
    let isLoading: Bool
    let onTodayPicks: () -> Void
    let onGoodMood: () -> Void
    let onReadingStats: () -> Void
    let onSavedStories: () -> Void
    let onArchiveSearch: () -> Void
    let onPersonalize: () -> Void
    let onOpenArticle: (Article) -> Void

    @AppStorage(NutsNewsUserPreferences.selectedTopicsKey) private var selectedTopicsRawValue = NutsNewsUserPreferences.rawValue(forTopicIDs: NutsNewsUserPreferences.defaultTopicIDs)
    @AppStorage(NutsNewsUserPreferences.selectedMoodKey) private var selectedMoodID = NutsNewsUserPreferences.defaultMoodID
    @AppStorage(NutsNewsUserPreferences.dailyGoalKey) private var dailyGoal = NutsNewsUserPreferences.defaultDailyGoal
    @AppStorage(NutsNewsUserPreferences.reminderEnabledKey) private var reminderEnabled = false
    @AppStorage(NutsNewsUserPreferences.reminderHourKey) private var reminderHour = NutsNewsUserPreferences.defaultReminderHour
    @AppStorage(ReadingStatsStore.storageKey) private var readingStatsRawValue = ReadingStatsStore.emptyRawValue
    @AppStorage(SavedStoryStore.storageKey) private var savedStoriesRawValue = SavedStoryStore.emptyRawValue
    @AppStorage(StoryNoteStore.storageKey) private var storyNotesRawValue = StoryNoteStore.emptyRawValue

    private var todayCount: Int {
        ReadingStatsStore.openedTodayCount(from: readingStatsRawValue)
    }

    private var goalCount: Int {
        NutsNewsUserPreferences.dailyGoal(from: dailyGoal)
    }

    private var progressValue: Double {
        guard goalCount > 0 else { return 0 }
        return min(Double(todayCount) / Double(goalCount), 1)
    }

    private var personalizedArticles: [Article] {
        NutsNewsUserPreferences.topPersonalizedArticles(
            from: articles,
            topicsRawValue: selectedTopicsRawValue,
            moodRawValue: selectedMoodID,
            limit: 3
        )
    }

    private var selectedMood: NutsNewsMoodPreference {
        NutsNewsUserPreferences.mood(for: selectedMoodID)
    }

    private var selectedTopicText: String {
        NutsNewsUserPreferences.topicTitles(from: selectedTopicsRawValue)
            .prefix(3)
            .joined(separator: ", ")
    }

    private var savedCount: Int {
        SavedStoryStore.stories(from: savedStoriesRawValue).count
    }

    private var notesCount: Int {
        StoryNoteStore.noteCount(from: storyNotesRawValue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
            dashboardHero
            quickActionGrid
            forYouSection
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dashboardHero: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
            HStack(alignment: .top, spacing: NutsNewsTheme.spacingM) {
                VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXS) {
                    Text("Today’s good-news reset")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(NutsNewsTheme.amber)
                        .textCase(.uppercase)

                    Text(todayCount >= goalCount ? "Goal complete ✨" : "\(todayCount) of \(goalCount) stories today")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundStyle(NutsNewsTheme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Your home is now a native good-news dashboard, not just a list of links.")
                        .font(.subheadline)
                        .foregroundStyle(NutsNewsTheme.secondaryText)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: NutsNewsTheme.spacingS)

                ZStack {
                    Circle()
                        .stroke(NutsNewsTheme.cardBorder, lineWidth: 8)

                    Circle()
                        .trim(from: 0, to: progressValue)
                        .stroke(NutsNewsTheme.amberHighlight, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(progressValue * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(NutsNewsTheme.primaryText)
                }
                .frame(width: 66, height: 66)
            }

            HStack(spacing: NutsNewsTheme.spacingS) {
                DashboardPill(iconName: selectedMood.iconName, text: selectedMood.title)
                DashboardPill(iconName: "bookmark.fill", text: "\(savedCount) saved")
                DashboardPill(iconName: "note.text", text: "\(notesCount) notes")
            }
        }
        .padding(NutsNewsTheme.spacingM)
        .background(NutsNewsTheme.cardBackgroundStrong)
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1.2)
        )
        .shadow(color: NutsNewsTheme.amberGlow, radius: NutsNewsTheme.spacingS, x: 0, y: NutsNewsTheme.spacingXS)
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
    }

    private var quickActionGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: NutsNewsTheme.spacingS) {
            DashboardActionCard(
                iconName: "newspaper.fill",
                title: "Today’s Picks",
                subtitle: "Native daily digest",
                action: onTodayPicks
            )

            DashboardActionCard(
                iconName: "sparkles",
                title: "Good Mood",
                subtitle: "Pick how you feel",
                action: onGoodMood
            )

            DashboardActionCard(
                iconName: "chart.bar.xaxis",
                title: "Goal + Streak",
                subtitle: "Track your habit",
                action: onReadingStats
            )

            DashboardActionCard(
                iconName: "bookmark.fill",
                title: "Saved Library",
                subtitle: "Your feel-good archive",
                action: onSavedStories
            )

            DashboardActionCard(
                iconName: "magnifyingglass",
                title: "Search Archive",
                subtitle: "Find old good news",
                action: onArchiveSearch
            )

            DashboardActionCard(
                iconName: reminderEnabled ? "bell.badge.fill" : "slider.horizontal.3",
                title: reminderEnabled ? "Reminder On" : "Personalize",
                subtitle: reminderEnabled ? "Daily at \(NutsNewsUserPreferences.reminderTime(for: reminderHour).displayTime)" : selectedTopicText,
                action: onPersonalize
            )
        }
    }

    @ViewBuilder
    private var forYouSection: some View {
        if !personalizedArticles.isEmpty || isLoading {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                        Text("For You")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(NutsNewsTheme.primaryText)

                        Text(NutsNewsUserPreferences.personalizationSummary(topicsRawValue: selectedTopicsRawValue, moodRawValue: selectedMoodID))
                            .font(.caption)
                            .foregroundStyle(NutsNewsTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Button("Edit") {
                        onPersonalize()
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.amber)
                }

                if personalizedArticles.isEmpty {
                    ProgressView()
                        .tint(NutsNewsTheme.amber)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, NutsNewsTheme.spacingM)
                } else {
                    VStack(spacing: NutsNewsTheme.spacingS) {
                        ForEach(personalizedArticles.prefix(3)) { article in
                            ForYouStoryRow(article: article) {
                                onOpenArticle(article)
                            }
                        }
                    }
                }
            }
            .padding(NutsNewsTheme.spacingM)
            .background(NutsNewsTheme.cardBackgroundStrong.opacity(0.72))
            .overlay(
                RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                    .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
        }
    }
}

private struct DashboardPill: View {
    let iconName: String
    let text: String

    var body: some View {
        HStack(spacing: NutsNewsTheme.spacingXXS) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .bold))
            Text(text)
                .font(.caption2)
                .fontWeight(.bold)
                .lineLimit(1)
        }
        .foregroundStyle(NutsNewsTheme.secondaryText)
        .padding(.horizontal, NutsNewsTheme.spacingS)
        .padding(.vertical, NutsNewsTheme.spacingXS)
        .background(NutsNewsTheme.badgeBackground)
        .clipShape(Capsule())
    }
}

private struct DashboardActionCard: View {
    let iconName: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                Image(systemName: iconName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(NutsNewsTheme.amberHighlight)
                    .frame(width: 34, height: 34)
                    .background(NutsNewsTheme.badgeBackground)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(NutsNewsTheme.primaryText)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(NutsNewsTheme.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(NutsNewsTheme.spacingM)
            .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
            .background(NutsNewsTheme.cardBackgroundStrong)
            .overlay(
                RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                    .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct ForYouStoryRow: View {
    let article: Article
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: NutsNewsTheme.spacingS) {
                AsyncImage(url: article.thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        ZStack {
                            NutsNewsTheme.badgeBackground
                            Image(systemName: "newspaper")
                                .foregroundStyle(NutsNewsTheme.amber)
                        }
                    }
                }
                .frame(width: 74, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusS, style: .continuous))

                VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                    Text(article.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(NutsNewsTheme.primaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(article.source)
                        .font(.caption)
                        .foregroundStyle(NutsNewsTheme.mutedText)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.mutedText)
                    .padding(.top, 4)
            }
            .padding(NutsNewsTheme.spacingS)
            .background(NutsNewsTheme.badgeBackground)
            .overlay(
                RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                    .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeDashboardView(
        articles: [],
        isLoading: false,
        onTodayPicks: {},
        onGoodMood: {},
        onReadingStats: {},
        onSavedStories: {},
        onArchiveSearch: {},
        onPersonalize: {},
        onOpenArticle: { _ in }
    )
}
