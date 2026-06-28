//
//  ReadingStatsView.swift
//  NutsNews
//

import SwiftUI

struct ReadingStatsView: View {
    let onClose: () -> Void

    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue
    @AppStorage(ReadingStatsStore.storageKey) private var readingStatsRawValue = ReadingStatsStore.emptyRawValue
    @AppStorage(SavedStoryStore.storageKey) private var savedStoriesRawValue = SavedStoryStore.emptyRawValue
    @AppStorage(StoryNoteStore.storageKey) private var storyNotesRawValue = StoryNoteStore.emptyRawValue
    @AppStorage(NutsNewsUserPreferences.dailyGoalKey) private var dailyGoal = NutsNewsUserPreferences.defaultDailyGoal

    private var selectedTheme: NutsNewsAppTheme {
        NutsNewsAppTheme(rawValue: themeRawValue) ?? NutsNewsTheme.defaultTheme
    }

    private var todayCount: Int {
        ReadingStatsStore.openedTodayCount(from: readingStatsRawValue)
    }

    private var goalCount: Int {
        NutsNewsUserPreferences.dailyGoal(from: dailyGoal)
    }

    private var currentStreak: Int {
        ReadingStatsStore.currentStreak(from: readingStatsRawValue)
    }

    private var totalStoryCount: Int {
        ReadingStatsStore.totalUniqueStoryCount(from: readingStatsRawValue)
    }

    private var savedStoryCount: Int {
        SavedStoryStore.stories(from: savedStoriesRawValue).count
    }

    private var noteCount: Int {
        StoryNoteStore.noteCount(from: storyNotesRawValue)
    }

    private var originalOpensToday: Int {
        ReadingStatsStore.originalOpensTodayCount(from: readingStatsRawValue)
    }

    private var recentDays: [ReadingStatsDay] {
        ReadingStatsStore.recentDays(from: readingStatsRawValue)
    }

    private var maxRecentDayCount: Int {
        max(recentDays.map(\.storyCount).max() ?? 1, 1)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .overlay(NutsNewsTheme.backgroundOverlay)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                        headerCard
                        todayProgressCard
                        weeklyChartCard
                        totalsGrid
                    }
                    .padding(NutsNewsTheme.spacingM)
                }
            }
            .navigationTitle("Reading Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        onClose()
                    }
                    .foregroundStyle(NutsNewsTheme.amber)
                }
            }
            .preferredColorScheme(selectedTheme.preferredColorScheme)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
            HStack(alignment: .center, spacing: NutsNewsTheme.spacingS) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(NutsNewsTheme.amberHighlight)
                    .frame(width: 48, height: 48)
                    .background(NutsNewsTheme.badgeBackground)
                    .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))

                VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                    Text("Your positive-news rhythm")
                        .font(.headline)
                        .foregroundStyle(NutsNewsTheme.primaryText)

                    Text("Private on-device stats from the stories you open, save, and note.")
                        .font(.subheadline)
                        .foregroundStyle(NutsNewsTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(NutsNewsTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutsNewsTheme.cardBackgroundStrong)
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1.25)
        )
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
    }

    private var todayProgressCard: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
            HStack(alignment: .firstTextBaseline) {
                Text("Today")
                    .font(.headline)
                    .foregroundStyle(NutsNewsTheme.primaryText)

                Spacer()

                Text("\(todayCount)/\(goalCount) stories")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.amber)
            }

            ProgressView(value: min(Double(todayCount), Double(goalCount)), total: Double(goalCount))
                .tint(NutsNewsTheme.amber)

            Text(todayMessage)
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(NutsNewsTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutsNewsTheme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
    }

    private var todayMessage: String {
        if todayCount <= 0 {
            return "Open one uplifting story to start today’s positive streak."
        }

        if todayCount < goalCount {
            let remainingCount = goalCount - todayCount
            return "Nice start. Open \(remainingCount) more positive \(remainingCount == 1 ? "story" : "stories") to complete today’s goal."
        }

        return "Today’s good-news goal is complete. Beautiful."
    }

    private var weeklyChartCard: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
            Text("Last 7 days")
                .font(.headline)
                .foregroundStyle(NutsNewsTheme.primaryText)

            HStack(alignment: .bottom, spacing: NutsNewsTheme.spacingS) {
                ForEach(recentDays) { day in
                    VStack(spacing: NutsNewsTheme.spacingXS) {
                        Text("\(day.storyCount)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(day.storyCount > 0 ? NutsNewsTheme.amber : NutsNewsTheme.mutedText)

                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(day.storyCount > 0 ? NutsNewsTheme.amberHighlight.opacity(0.85) : NutsNewsTheme.badgeBackground)
                            .frame(height: barHeight(for: day.storyCount))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(NutsNewsTheme.cardBorder, lineWidth: 0.75)
                            )

                        Text(day.displayLabel)
                            .font(.caption2)
                            .foregroundStyle(NutsNewsTheme.mutedText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 150, alignment: .bottom)
        }
        .padding(NutsNewsTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutsNewsTheme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
    }

    private func barHeight(for count: Int) -> CGFloat {
        let ratio = CGFloat(count) / CGFloat(maxRecentDayCount)
        return max(12, 82 * ratio)
    }

    private var totalsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: NutsNewsTheme.spacingS) {
            StatTile(title: "Streak", value: "\(currentStreak)", subtitle: currentStreak == 1 ? "day" : "days", systemImage: "flame.fill")
            StatTile(title: "Opened", value: "\(totalStoryCount)", subtitle: "stories", systemImage: "newspaper.fill")
            StatTile(title: "Saved", value: "\(savedStoryCount)", subtitle: "library", systemImage: "bookmark.fill")
            StatTile(title: "Notes", value: "\(noteCount)", subtitle: "private", systemImage: "note.text")
            StatTile(title: "Originals", value: "\(originalOpensToday)", subtitle: "today", systemImage: "safari.fill")
        }
    }
}

private struct StatTile: View {
    let title: String
    let value: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXS) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(NutsNewsTheme.amberHighlight)

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(NutsNewsTheme.primaryText)

            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(NutsNewsTheme.amber)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(NutsNewsTheme.mutedText)
        }
        .padding(NutsNewsTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutsNewsTheme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
    }
}

#Preview {
    ReadingStatsView {}
}
