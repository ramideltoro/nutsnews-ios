//
//  OnboardingView.swift
//  NutsNews
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    var showsCloseButton = false

    @Environment(\.dismiss) private var dismiss
    @AppStorage(NutsNewsUserPreferences.hasCompletedOnboardingKey) private var hasCompletedOnboarding = false
    @AppStorage(NutsNewsUserPreferences.selectedTopicsKey) private var selectedTopicsRawValue = NutsNewsUserPreferences.rawValue(forTopicIDs: NutsNewsUserPreferences.defaultTopicIDs)
    @AppStorage(NutsNewsUserPreferences.selectedMoodKey) private var selectedMoodID = NutsNewsUserPreferences.defaultMoodID
    @AppStorage(NutsNewsUserPreferences.dailyGoalKey) private var dailyGoal = NutsNewsUserPreferences.defaultDailyGoal
    @AppStorage(NutsNewsUserPreferences.reminderEnabledKey) private var reminderEnabled = false
    @AppStorage(NutsNewsUserPreferences.reminderHourKey) private var reminderHour = NutsNewsUserPreferences.defaultReminderHour
    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue

    @State private var selectedTopicIDs = NutsNewsUserPreferences.defaultTopicIDs
    @State private var selectedReminderTime = NutsNewsReminderTime.morning
    @State private var reminderStatusText = ""

    private var selectedTheme: NutsNewsAppTheme {
        NutsNewsAppTheme(rawValue: themeRawValue) ?? NutsNewsTheme.defaultTheme
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .overlay(NutsNewsTheme.backgroundOverlay)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: NutsNewsTheme.spacingL) {
                        heroSection
                        topicsSection
                        moodSection
                        dailyGoalSection
                        reminderSection
                        finishButton
                    }
                    .padding(NutsNewsTheme.spacingM)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle(showsCloseButton ? "Personalize" : "Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showsCloseButton {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                        .foregroundStyle(NutsNewsTheme.amber)
                    }
                }
            }
        }
        .preferredColorScheme(selectedTheme.preferredColorScheme)
        .onAppear {
            selectedTopicIDs = NutsNewsUserPreferences.selectedTopicIDs(from: selectedTopicsRawValue)
            selectedReminderTime = NutsNewsUserPreferences.reminderTime(for: reminderHour)
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
            HStack(spacing: NutsNewsTheme.spacingS) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(NutsNewsTheme.amberHighlight)
                    .frame(width: 42, height: 42)
                    .background(NutsNewsTheme.badgeBackground)
                    .clipShape(Circle())

                Text("NutsNews")
                    .font(.system(size: 31, weight: .light, design: .serif))
                    .tracking(1.6)
                    .foregroundStyle(NutsNewsTheme.amberHighlight)
            }

            Text("Build your good-news habit")
                .font(.system(size: 29, weight: .bold, design: .rounded))
                .foregroundStyle(NutsNewsTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            Text("Choose what feels uplifting to you. NutsNews will use this to shape your For You picks, daily goal, and good-news reset.")
                .font(.body)
                .lineSpacing(3)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(NutsNewsTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutsNewsTheme.cardBackgroundStrong)
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1.2)
        )
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
    }

    private var topicsSection: some View {
        OnboardingSection(number: "1", title: "Pick your favorite good news") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: NutsNewsTheme.spacingS)], spacing: NutsNewsTheme.spacingS) {
                ForEach(NutsNewsUserPreferences.topics) { topic in
                    OnboardingChoiceButton(
                        title: topic.title,
                        iconName: topic.iconName,
                        isSelected: selectedTopicIDs.contains(topic.id)
                    ) {
                        toggleTopic(topic.id)
                    }
                }
            }
        }
    }

    private var moodSection: some View {
        OnboardingSection(number: "2", title: "Choose your default mood") {
            VStack(spacing: NutsNewsTheme.spacingS) {
                ForEach(NutsNewsUserPreferences.moods) { mood in
                    Button {
                        selectedMoodID = mood.id
                    } label: {
                        HStack(spacing: NutsNewsTheme.spacingM) {
                            Image(systemName: mood.iconName)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(selectedMoodID == mood.id ? NutsNewsTheme.buttonText : NutsNewsTheme.amberHighlight)
                                .frame(width: 34, height: 34)
                                .background {
                                    if selectedMoodID == mood.id {
                                        NutsNewsTheme.buttonGradient
                                    } else {
                                        NutsNewsTheme.badgeBackground
                                    }
                                }
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                                Text(mood.title)
                                    .font(.headline)
                                    .foregroundStyle(NutsNewsTheme.primaryText)

                                Text(mood.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(NutsNewsTheme.secondaryText)
                            }

                            Spacer()

                            Image(systemName: selectedMoodID == mood.id ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedMoodID == mood.id ? NutsNewsTheme.amberHighlight : NutsNewsTheme.mutedText)
                        }
                        .padding(NutsNewsTheme.spacingM)
                        .background(selectedMoodID == mood.id ? NutsNewsTheme.badgeBackground : NutsNewsTheme.cardBackgroundStrong)
                        .overlay(
                            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                                .stroke(selectedMoodID == mood.id ? NutsNewsTheme.amberHighlight.opacity(0.72) : NutsNewsTheme.cardBorder, lineWidth: 1.1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var dailyGoalSection: some View {
        OnboardingSection(number: "3", title: "Set a daily good-news goal") {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                Text("\(NutsNewsUserPreferences.dailyGoal(from: dailyGoal)) stories per day")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.primaryText)

                Stepper(
                    value: $dailyGoal,
                    in: 1...5,
                    step: 1
                ) {
                    Text("Small enough to feel easy. Consistent enough to become a habit.")
                        .font(.subheadline)
                        .foregroundStyle(NutsNewsTheme.secondaryText)
                }
                .tint(NutsNewsTheme.amber)
            }
        }
    }

    private var reminderSection: some View {
        OnboardingSection(number: "4", title: "Optional daily reminder") {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                Toggle(isOn: $reminderEnabled) {
                    VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                        Text("Daily good-news reset")
                            .font(.headline)
                            .foregroundStyle(NutsNewsTheme.primaryText)

                        Text("A local iOS notification brings you back to Today’s Picks.")
                            .font(.subheadline)
                            .foregroundStyle(NutsNewsTheme.secondaryText)
                    }
                }
                .tint(NutsNewsTheme.amber)

                if reminderEnabled {
                    Picker("Reminder time", selection: $selectedReminderTime) {
                        ForEach(NutsNewsReminderTime.allCases) { time in
                            Text("\(time.title) · \(time.displayTime)").tag(time)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(NutsNewsTheme.amber)
                }

                if !reminderStatusText.isEmpty {
                    Text(reminderStatusText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(NutsNewsTheme.amber)
                }
            }
        }
    }

    private var finishButton: some View {
        Button {
            savePreferencesAndFinish()
        } label: {
            HStack(spacing: NutsNewsTheme.spacingS) {
                Image(systemName: "checkmark.seal.fill")
                Text(showsCloseButton ? "Save personalization" : "Start my good-news reset")
            }
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(NutsNewsTheme.buttonText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(NutsNewsTheme.buttonGradient)
            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
            .shadow(color: NutsNewsTheme.amberGlow, radius: NutsNewsTheme.spacingS, x: 0, y: NutsNewsTheme.spacingXXS)
        }
        .buttonStyle(.plain)
        .disabled(selectedTopicIDs.isEmpty)
        .opacity(selectedTopicIDs.isEmpty ? 0.55 : 1.0)
    }

    private func toggleTopic(_ topicID: String) {
        if selectedTopicIDs.contains(topicID) {
            if selectedTopicIDs.count > 1 {
                selectedTopicIDs.remove(topicID)
            }
        } else {
            selectedTopicIDs.insert(topicID)
        }
    }

    private func savePreferencesAndFinish() {
        selectedTopicsRawValue = NutsNewsUserPreferences.rawValue(forTopicIDs: selectedTopicIDs)
        dailyGoal = NutsNewsUserPreferences.dailyGoal(from: dailyGoal)
        reminderHour = selectedReminderTime.rawValue
        hasCompletedOnboarding = true

        if reminderEnabled {
            reminderStatusText = "Scheduling reminder…"
            Task {
                await NutsNewsReminderCenter.scheduleDailyReminder(hour: selectedReminderTime.rawValue)
                await MainActor.run {
                    reminderStatusText = "Reminder saved for \(selectedReminderTime.displayTime)."
                    onFinish()
                    if showsCloseButton {
                        dismiss()
                    }
                }
            }
        } else {
            Task {
                await NutsNewsReminderCenter.removeDailyReminder()
                await MainActor.run {
                    reminderStatusText = "Reminder off."
                    onFinish()
                    if showsCloseButton {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct OnboardingSection<Content: View>: View {
    let number: String
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
            HStack(spacing: NutsNewsTheme.spacingS) {
                Text(number)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.buttonText)
                    .frame(width: 26, height: 26)
                    .background(NutsNewsTheme.buttonGradient)
                    .clipShape(Circle())

                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.primaryText)
            }

            content
        }
    }
}

private struct OnboardingChoiceButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: NutsNewsTheme.spacingS) {
                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .bold))

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .foregroundStyle(isSelected ? NutsNewsTheme.buttonText : NutsNewsTheme.secondaryText)
            .padding(.horizontal, NutsNewsTheme.spacingM)
            .padding(.vertical, 13)
            .background {
                if isSelected {
                    NutsNewsTheme.buttonGradient
                } else {
                    NutsNewsTheme.badgeBackground
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                    .stroke(isSelected ? Color.clear : NutsNewsTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
