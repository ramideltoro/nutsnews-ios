//
//  HelpFAQView.swift
//  NutsNews
//

import SwiftUI

struct HelpFAQView: View {
    let onClose: () -> Void
    let onOpenTodayPicks: () -> Void
    let onOpenGoodMood: () -> Void
    let onOpenReadingStats: () -> Void
    let onOpenSavedStories: () -> Void
    let onOpenSearch: () -> Void
    let onOpenPersonalization: () -> Void
    let onOpenStoryFeatures: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .overlay(NutsNewsTheme.backgroundOverlay)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                        heroCard
                        startHereCard
                        storyToolsCard
                        dailyHabitCard
                        iosFeaturesCard
                        faqCard
                    }
                    .padding(NutsNewsTheme.spacingM)
                    .padding(.bottom, NutsNewsTheme.spacingXL)
                }
            }
            .navigationTitle("Help & F.A.Q.")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
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
                    .accessibilityLabel("Close help")
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
            HStack(alignment: .top, spacing: NutsNewsTheme.spacingM) {
                ZStack {
                    Circle()
                        .fill(NutsNewsTheme.badgeBackground)
                        .frame(width: 58, height: 58)

                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(NutsNewsTheme.amber)
                }

                VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXS) {
                    Text("How to use NutsNews")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(NutsNewsTheme.primaryText)

                    Text("A simple guide to the native tools that make NutsNews feel calm, personal, and easy to return to.")
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
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
        .shadow(color: NutsNewsTheme.amberGlow.opacity(0.42), radius: 22, x: 0, y: 0)
    }

    private var startHereCard: some View {
        HelpFeatureSection(
            iconName: "sparkles.rectangle.stack.fill",
            title: "Start here",
            subtitle: "Use these features first to shape your daily feed. You can find these options later in the menu."
        ) {
            VStack(spacing: NutsNewsTheme.spacingS) {
                HelpActionButton(title: "Personalize NutsNews", systemImage: "slider.horizontal.3", action: onOpenPersonalization)
                HelpActionButton(title: "Today’s Picks", systemImage: "newspaper.fill", action: onOpenTodayPicks)
                HelpActionButton(title: "Good Mood", systemImage: "sparkles", action: onOpenGoodMood)
            }
        }
    }

    private var storyToolsCard: some View {
        HelpFeatureSection(
            iconName: "book.pages.fill",
            title: "Story tools",
            subtitle: "Open a story to use the native reading tools."
        ) {
            VStack(spacing: NutsNewsTheme.spacingS) {
                HelpChecklistRow(title: "NutsNews Brief", subtitle: "A quick feel-good summary and takeaway.")
                HelpChecklistRow(title: "Listen Mode", subtitle: "Have iOS read the brief aloud using on-device speech.")
                HelpChecklistRow(title: "Daily Reflection", subtitle: "Save a private reaction like “Made me smile” or “Gave me hope.”")
                HelpChecklistRow(title: "Good News Share Card", subtitle: "Create a branded image card to share through the iOS share sheet.")

                HelpActionButton(
                    title: "Open a story",
                    systemImage: "doc.text.magnifyingglass",
                    action: onOpenStoryFeatures
                )
            }
        }
    }

    private var dailyHabitCard: some View {
        HelpFeatureSection(
            iconName: "heart.text.square.fill",
            title: "Build a small habit",
            subtitle: "Use NutsNews like a daily positive reset."
        ) {
            VStack(spacing: NutsNewsTheme.spacingS) {
                HelpActionButton(title: "Reading Stats", systemImage: "chart.bar.xaxis", action: onOpenReadingStats)
                HelpActionButton(title: "Saved Stories", systemImage: "bookmark.fill", action: onOpenSavedStories)
                HelpActionButton(title: "Archive Search", systemImage: "magnifyingglass", action: onOpenSearch)
            }
        }
    }

    private var iosFeaturesCard: some View {
        HelpFeatureSection(
            iconName: "iphone.gen3.radiowaves.left.and.right",
            title: "iOS features",
            subtitle: "NutsNews also works outside the main feed."
        ) {
            VStack(spacing: NutsNewsTheme.spacingS) {
                HelpChecklistRow(title: "Home Screen Widget", subtitle: "Add NutsNews Daily from the iOS widget gallery for a quick positive headline.")
                HelpChecklistRow(title: "Local reminders", subtitle: "Use onboarding or personalization to set a gentle good-news reminder.")
                HelpChecklistRow(title: "Native sharing", subtitle: "Share positive story cards through the built-in iOS share sheet.")
                HelpChecklistRow(title: "Private on-device choices", subtitle: "Your saved stories, reflections, stats, theme, and preferences stay on your device.")
            }
        }
    }

    private var faqCard: some View {
        HelpFeatureSection(
            iconName: "questionmark.bubble.fill",
            title: "FAQ",
            subtitle: "Common questions about NutsNews."
        ) {
            VStack(spacing: NutsNewsTheme.spacingS) {
                HelpFAQRow(
                    question: "What is NutsNews for?",
                    answer: "NutsNews is for quick, calm breaks with positive stories and simple tools that help you save, reflect, and return to good news."
                )

                HelpFAQRow(
                    question: "How do I change what I see?",
                    answer: "Open Personalize to adjust topics, mood, reading goal, and reminder preferences."
                )

                HelpFAQRow(
                    question: "How do I save something for later?",
                    answer: "Open any story and use Save, or use Daily Reflection to mark why a story mattered to you."
                )

                HelpFAQRow(
                    question: "How do I add the widget?",
                    answer: "Long press the iPhone Home Screen, tap Edit or +, search NutsNews, then add NutsNews Daily."
                )

                HelpFAQRow(
                    question: "Can I listen instead of read?",
                    answer: "Yes. Open a story and use Listen Mode to hear the NutsNews Brief aloud."
                )
            }
        }
    }
}

private struct HelpFeatureSection<Content: View>: View {
    let iconName: String
    let title: String
    let subtitle: String
    private let content: Content

    init(
        iconName: String,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) {
        self.iconName = iconName
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
            HStack(alignment: .top, spacing: NutsNewsTheme.spacingM) {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(NutsNewsTheme.amberHighlight)
                    .frame(width: 38, height: 38)
                    .background(NutsNewsTheme.badgeBackground)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(NutsNewsTheme.primaryText)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(NutsNewsTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            content
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

private struct HelpChecklistRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: NutsNewsTheme.spacingS) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amber)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.primaryText)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct HelpFAQRow: View {
    let question: String
    let answer: String

    var body: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
            Text(question)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(NutsNewsTheme.primaryText)

            Text(answer)
                .font(.caption)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(NutsNewsTheme.spacingS)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutsNewsTheme.badgeBackground)
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
    }
}

private struct HelpActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: NutsNewsTheme.spacingS) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .bold))

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .foregroundStyle(NutsNewsTheme.buttonText)
            .padding(.horizontal, NutsNewsTheme.spacingM)
            .padding(.vertical, NutsNewsTheme.spacingS)
            .background(NutsNewsTheme.buttonGradient)
            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusM, style: .continuous))
            .shadow(color: NutsNewsTheme.amberGlow.opacity(0.36), radius: 14, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HelpFAQView(
        onClose: {},
        onOpenTodayPicks: {},
        onOpenGoodMood: {},
        onOpenReadingStats: {},
        onOpenSavedStories: {},
        onOpenSearch: {},
        onOpenPersonalization: {},
        onOpenStoryFeatures: {}
    )
}
