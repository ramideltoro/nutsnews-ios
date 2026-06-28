//
//  FeedView.swift
//  NutsNews
//

import Foundation
import SwiftUI
import UIKit

struct FeedView: View {
    @StateObject private var viewModel = ArticleFeedViewModel()
    @State private var selectedArticle: Article?
    @State private var selectedCategory: String?
    @State private var isShowingSettings = false
    @State private var isShowingSavedStories = false
    @State private var isShowingArchiveSearch = false
    @State private var isShowingGoodMood = false
    @State private var isShowingReadingStats = false
    @State private var isShowingDailyDigest = false
    @State private var isShowingPersonalization = false
    @State private var isShowingHelpFAQ = false
    @State private var shouldReturnToHelpFAQAfterLinkedPage = false
    @State private var settingsButtonGlowOpacity = 0.0
    @State private var settingsButtonGlowRadius: CGFloat = 0
    @State private var settingsButtonGlowSequence = 0
    @State private var rejectedThumbnailArticleIDs = Set<String>()
    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue

    private var selectedTheme: NutsNewsAppTheme {
        NutsNewsAppTheme(rawValue: themeRawValue) ?? NutsNewsTheme.defaultTheme
    }

    private let themeOptions: [NutsNewsAppTheme] = [.amber, .sakura, .modernSaaS, .sanJuan, .creativePremium, .moodyCyberpunk]

    var body: some View {
        storyPresentationContainer
            .task {
                await viewModel.loadInitialArticles()
            }
    }

    @ViewBuilder
    private var storyPresentationContainer: some View {
        if shouldUseFullScreenPresentationOnThisDevice {
            feedNavigationStack
                .fullScreenCover(item: $selectedArticle, onDismiss: returnToHelpFAQIfNeeded) { article in
                    ArticleDetailView(article: article)
                        .preferredColorScheme(selectedTheme.preferredColorScheme)
                }
                .fullScreenCover(isPresented: $isShowingSettings) {
                    settingsScreen
                }
                .fullScreenCover(isPresented: $isShowingSavedStories, onDismiss: returnToHelpFAQIfNeeded) {
                    savedStoriesScreen
                }
                .fullScreenCover(isPresented: $isShowingArchiveSearch, onDismiss: returnToHelpFAQIfNeeded) {
                    archiveSearchScreen
                }
                .fullScreenCover(isPresented: $isShowingGoodMood, onDismiss: returnToHelpFAQIfNeeded) {
                    goodMoodScreen
                }
                .fullScreenCover(isPresented: $isShowingReadingStats, onDismiss: returnToHelpFAQIfNeeded) {
                    readingStatsScreen
                }
                .fullScreenCover(isPresented: $isShowingDailyDigest, onDismiss: returnToHelpFAQIfNeeded) {
                    dailyDigestScreen
                }
                .fullScreenCover(isPresented: $isShowingPersonalization, onDismiss: returnToHelpFAQIfNeeded) {
                    personalizationScreen
                }
                .fullScreenCover(isPresented: $isShowingHelpFAQ) {
                    helpFAQScreen
                }
        } else {
            feedNavigationStack
                .sheet(item: $selectedArticle, onDismiss: returnToHelpFAQIfNeeded) { article in
                    ArticleDetailView(article: article)
                        .preferredColorScheme(selectedTheme.preferredColorScheme)
                }
                .sheet(isPresented: $isShowingSettings) {
                    settingsScreen
                }
                .sheet(isPresented: $isShowingSavedStories, onDismiss: returnToHelpFAQIfNeeded) {
                    savedStoriesScreen
                }
                .sheet(isPresented: $isShowingArchiveSearch, onDismiss: returnToHelpFAQIfNeeded) {
                    archiveSearchScreen
                }
                .sheet(isPresented: $isShowingGoodMood, onDismiss: returnToHelpFAQIfNeeded) {
                    goodMoodScreen
                }
                .sheet(isPresented: $isShowingReadingStats, onDismiss: returnToHelpFAQIfNeeded) {
                    readingStatsScreen
                }
                .sheet(isPresented: $isShowingDailyDigest, onDismiss: returnToHelpFAQIfNeeded) {
                    dailyDigestScreen
                }
                .sheet(isPresented: $isShowingPersonalization, onDismiss: returnToHelpFAQIfNeeded) {
                    personalizationScreen
                }
                .sheet(isPresented: $isShowingHelpFAQ) {
                    helpFAQScreen
                }
        }
    }

    private var shouldUseFullScreenPresentationOnThisDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    private var settingsScreen: some View {
        SettingsView {
            isShowingSettings = false
        }
        .preferredColorScheme(selectedTheme.preferredColorScheme)
    }

    private var savedStoriesScreen: some View {
        SavedStoriesView {
            isShowingSavedStories = false
        }
        .preferredColorScheme(selectedTheme.preferredColorScheme)
    }

    private var archiveSearchScreen: some View {
        ArchiveSearchView {
            isShowingArchiveSearch = false
        }
        .preferredColorScheme(selectedTheme.preferredColorScheme)
    }

    private var goodMoodScreen: some View {
        GoodMoodView(articles: renderableArticles) {
            isShowingGoodMood = false
        }
        .preferredColorScheme(selectedTheme.preferredColorScheme)
    }

    private var readingStatsScreen: some View {
        ReadingStatsView {
            isShowingReadingStats = false
        }
        .preferredColorScheme(selectedTheme.preferredColorScheme)
    }

    private var dailyDigestScreen: some View {
        DailyDigestView(articles: renderableArticles) {
            isShowingDailyDigest = false
        }
        .preferredColorScheme(selectedTheme.preferredColorScheme)
    }

    private var personalizationScreen: some View {
        OnboardingView(
            onFinish: {
                isShowingPersonalization = false
            },
            showsCloseButton: true
        )
        .preferredColorScheme(selectedTheme.preferredColorScheme)
    }


    private var helpFAQScreen: some View {
        HelpFAQView(
            onClose: {
                isShowingHelpFAQ = false
            },
            onOpenTodayPicks: {
                openFromHelpFAQ {
                    isShowingDailyDigest = true
                }
            },
            onOpenGoodMood: {
                openFromHelpFAQ {
                    isShowingGoodMood = true
                }
            },
            onOpenReadingStats: {
                openFromHelpFAQ {
                    isShowingReadingStats = true
                }
            },
            onOpenSavedStories: {
                openFromHelpFAQ {
                    isShowingSavedStories = true
                }
            },
            onOpenSearch: {
                openFromHelpFAQ {
                    isShowingArchiveSearch = true
                }
            },
            onOpenPersonalization: {
                openFromHelpFAQ {
                    isShowingPersonalization = true
                }
            },
            onOpenStoryFeatures: {
                openFromHelpFAQ {
                    if let firstArticle = renderableArticles.first {
                        selectedArticle = firstArticle
                    }
                }
            }
        )
        .preferredColorScheme(selectedTheme.preferredColorScheme)
    }

    private func openFromHelpFAQ(_ action: @escaping () -> Void) {
        shouldReturnToHelpFAQAfterLinkedPage = true
        isShowingHelpFAQ = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            action()
        }
    }

    private func returnToHelpFAQIfNeeded() {
        guard shouldReturnToHelpFAQAfterLinkedPage else { return }
        shouldReturnToHelpFAQAfterLinkedPage = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            isShowingHelpFAQ = true
        }
    }

    private var feedNavigationStack: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .overlay(NutsNewsTheme.backgroundOverlay)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    staticHeader
                    content
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(selectedTheme.preferredColorScheme)
            .animation(.easeInOut(duration: 0.25), value: themeRawValue)
        }
    }

    private var staticHeader: some View {
        VStack(spacing: NutsNewsTheme.spacingS) {
            ZStack {
                HStack {
                    hamburgerMenuButton

                    Spacer()
                }

                Text("NutsNews")
                    .font(.system(size: 31, weight: .light, design: .serif))
                    .tracking(1.8)
                    .foregroundStyle(NutsNewsTheme.amberHighlight)
                    .shadow(color: NutsNewsTheme.amberGlow, radius: NutsNewsTheme.spacingS, x: 0, y: NutsNewsTheme.spacingXXS)
            }
            .padding(.horizontal, NutsNewsTheme.spacingM)
            .padding(.top, NutsNewsTheme.spacingS)

            categoryFilterRow
        }
        .padding(.bottom, NutsNewsTheme.spacingM)
        .background(
            NutsNewsTheme.background
                .overlay(NutsNewsTheme.backgroundOverlay)
                .ignoresSafeArea(edges: .top)
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(NutsNewsTheme.cardBorder)
                .frame(height: 1)
        }
    }

    private var hamburgerMenuButton: some View {
        Menu {
            Button {
                isShowingHelpFAQ = true
            } label: {
                Label("Help & F.A.Q.", systemImage: "questionmark.circle.fill")
            }

            Divider()

            Button {
                isShowingDailyDigest = true
            } label: {
                Label("Today’s Picks", systemImage: "newspaper.fill")
            }

            Button {
                isShowingGoodMood = true
            } label: {
                Label("Good Mood", systemImage: "sparkles")
            }

            Button {
                isShowingReadingStats = true
            } label: {
                Label("Reading Stats", systemImage: "chart.bar.xaxis")
            }

            Button {
                isShowingSavedStories = true
            } label: {
                Label("Saved", systemImage: "bookmark.fill")
            }

            Button {
                isShowingArchiveSearch = true
            } label: {
                Label("Search", systemImage: "magnifyingglass")
            }

            Button {
                isShowingPersonalization = true
            } label: {
                Label("Personalize", systemImage: "slider.horizontal.3")
            }

            Button {
                isShowingSettings = true
            } label: {
                Label("Settings", systemImage: "gearshape.fill")
            }
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(NutsNewsTheme.amberHighlight)
                .frame(width: 38, height: 34)
                .background(NutsNewsTheme.badgeBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open menu")
    }

    private var settingsButton: some View {
        Button {
            openSettingsWithGlow()
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amberHighlight)
                .frame(width: 34, height: 34)
                .background(NutsNewsTheme.badgeBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .stroke(NutsNewsTheme.amberHighlight.opacity(settingsButtonGlowOpacity * 0.86), lineWidth: 2)
                        .blur(radius: settingsButtonGlowRadius * 0.16)
                )
                .shadow(color: NutsNewsTheme.amberHighlight.opacity(settingsButtonGlowOpacity * 0.72), radius: settingsButtonGlowRadius, x: 0, y: 0)
                .shadow(color: NutsNewsTheme.amberGlow.opacity(settingsButtonGlowOpacity * 0.55), radius: settingsButtonGlowRadius * 1.45, x: 0, y: 0)
                .scaleEffect(1 + (settingsButtonGlowOpacity * 0.035))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open settings")
    }


    private var archiveSearchButton: some View {
        Button {
            isShowingArchiveSearch = true
        } label: {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .bold))
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
        .accessibilityLabel("Search all NutsNews")
    }

    private var goodMoodButton: some View {
        Button {
            isShowingGoodMood = true
        } label: {
            Image(systemName: "sparkles")
                .font(.system(size: 15, weight: .bold))
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
        .accessibilityLabel("Open Good Mood picker")
    }

    private var savedStoriesButton: some View {
        Button {
            isShowingSavedStories = true
        } label: {
            HStack(spacing: NutsNewsTheme.spacingXS) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 13, weight: .bold))

                Text("Saved")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .foregroundStyle(NutsNewsTheme.amberHighlight)
            .padding(.horizontal, NutsNewsTheme.spacingS)
            .frame(height: 34)
            .background(NutsNewsTheme.badgeBackground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open saved stories")
    }

    private func openSettingsWithGlow() {
        let sequence = settingsButtonGlowSequence + 1
        settingsButtonGlowSequence = sequence
        settingsButtonGlowOpacity = 1
        settingsButtonGlowRadius = 22

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 1.0)) {
                settingsButtonGlowOpacity = 0
                settingsButtonGlowRadius = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            guard settingsButtonGlowSequence == sequence else { return }
            isShowingSettings = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            guard settingsButtonGlowSequence == sequence else { return }
            settingsButtonGlowOpacity = 0
            settingsButtonGlowRadius = 0
        }
    }

    private var refreshButton: some View {
        Button {
            Task {
                await viewModel.refresh(category: selectedCategory, forceReload: true)
            }
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 16, weight: .semibold))
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
        .disabled(viewModel.isLoading)
        .accessibilityLabel("Refresh stories")
    }

    private var categoryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: NutsNewsTheme.spacingXS) {
                CategoryChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    dotIndex: 0
                ) {
                    selectedCategory = nil
                    Task {
                        await viewModel.applyCategory(nil)
                    }
                }

                ForEach(Array(viewModel.availableCategories.enumerated()), id: \.element) { index, category in
                    CategoryChip(
                        title: category,
                        isSelected: selectedCategory?.caseInsensitiveCompare(category) == .orderedSame,
                        dotIndex: index + 1
                    ) {
                        selectedCategory = category
                        Task {
                            await viewModel.applyCategory(category)
                        }
                    }
                }
            }
            .padding(.horizontal, NutsNewsTheme.spacingM)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.articles.isEmpty && viewModel.isLoading {
            loadingView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.articles.isEmpty {
            emptyView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            articleList
        }
    }

    private var articleList: some View {
        GeometryReader { geometry in
            let useCompactLandscapeCards = isIPadLandscapeFeedLayout(size: geometry.size)
            let cardLayout: ArticleCardLayout = useCompactLandscapeCards ? .iPadLandscapeCompact : .regular
            let cardMaxWidth = articleCardMaxWidth(for: geometry.size)
            let verticalSpacing = useCompactLandscapeCards ? NutsNewsTheme.spacingS : NutsNewsTheme.spacingM
            let topPadding = useCompactLandscapeCards ? NutsNewsTheme.spacingM : NutsNewsTheme.spacingL
            let bottomPadding = useCompactLandscapeCards ? NutsNewsTheme.spacingM : NutsNewsTheme.spacingL

            ScrollView {
                LazyVStack(alignment: .center, spacing: verticalSpacing) {
                    HomeDashboardView(
                        articles: renderableArticles,
                        isLoading: viewModel.isLoading,
                        onTodayPicks: { isShowingDailyDigest = true },
                        onGoodMood: { isShowingGoodMood = true },
                        onReadingStats: { isShowingReadingStats = true },
                        onSavedStories: { isShowingSavedStories = true },
                        onArchiveSearch: { isShowingArchiveSearch = true },
                        onPersonalize: { isShowingPersonalization = true },
                        onRefreshForYou: {
                            Task {
                                await viewModel.refresh(category: selectedCategory, forceReload: true)
                            }
                        },
                        onOpenArticle: { article in selectedArticle = article }
                    )
                    .frame(maxWidth: cardMaxWidth, alignment: .topLeading)

                    Text("Latest stories")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(NutsNewsTheme.primaryText)
                        .frame(maxWidth: cardMaxWidth, alignment: .leading)
                        .padding(.top, NutsNewsTheme.spacingXS)

                    ForEach(renderableArticles) { article in
                        ArticleCardView(
                            article: article,
                            layout: cardLayout,
                            onReadFullStory: { selectedArticle in
                                self.selectedArticle = selectedArticle
                            },
                            onRenderingRejected: { rejectedArticle in
                                rejectedThumbnailArticleIDs.insert(rejectedArticle.id)
                            }
                        )
                        .frame(maxWidth: cardMaxWidth, alignment: .topLeading)
                        .scrollTransition(.animated(.easeInOut(duration: 0.32)), axis: .vertical) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.22)
                                .scaleEffect(phase.isIdentity ? 1 : 0.96)
                                .offset(y: phase.isIdentity ? 0 : 18)
                        }
                        .task {
                            await viewModel.loadMoreIfNeeded(currentArticle: article)
                        }
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(NutsNewsTheme.amber)
                            .padding(.vertical, NutsNewsTheme.spacingM)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        errorBanner(message: errorMessage)
                            .frame(maxWidth: cardMaxWidth, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, NutsNewsTheme.spacingM)
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
            }
            .refreshable {
                await viewModel.refresh(category: selectedCategory, forceReload: true)
            }
        }
    }

    private func isIPadLandscapeFeedLayout(size: CGSize) -> Bool {
        UIDevice.current.userInterfaceIdiom == .pad && size.width > size.height
    }

    private func articleCardMaxWidth(for size: CGSize) -> CGFloat {
        guard isIPadLandscapeFeedLayout(size: size) else {
            return .infinity
        }

        return min(size.width - 96, 860)
    }

    private var renderableArticles: [Article] {
        viewModel.articles.filter(isRenderableArticle)
    }

    private func isRenderableArticle(_ article: Article) -> Bool {
        let title = article.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = article.source.trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = article.summary.trimmingCharacters(in: .whitespacesAndNewlines)

        guard article.thumbnailURL != nil else { return false }
        guard !rejectedThumbnailArticleIDs.contains(article.id) else { return false }
        guard !title.isEmpty else { return false }
        guard !source.isEmpty else { return false }
        guard title.count <= 340 else { return false }
        guard summary.count <= 4_000 else { return false }
        guard !hasUnsafeUnbrokenToken(title) else { return false }
        guard !hasUnsafeUnbrokenToken(summary) else { return false }
        guard !hasUnsafeUnbrokenToken(source) else { return false }

        return true
    }

    private func hasUnsafeUnbrokenToken(_ text: String) -> Bool {
        let separators = CharacterSet.whitespacesAndNewlines
            .union(.punctuationCharacters)
            .union(.symbols)

        return text
            .components(separatedBy: separators)
            .contains { $0.count > 46 }
    }

    private var loadingView: some View {
        VStack(spacing: NutsNewsTheme.spacingS) {
            ProgressView()
                .tint(NutsNewsTheme.amber)

            Text("Loading good news...")
                .font(.subheadline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
        }
    }

    private var emptyView: some View {
        VStack(spacing: NutsNewsTheme.spacingM) {
            Image(systemName: "leaf")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amber)

            Text(selectedCategory == nil ? "No stories loaded yet" : "No \(selectedCategory ?? "category") stories yet")
                .font(.headline)
                .foregroundStyle(NutsNewsTheme.primaryText)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, NutsNewsTheme.spacingL)
            }

            Button {
                Task {
                    if viewModel.canLoadMore {
                        await viewModel.loadMore()
                    } else {
                        await viewModel.refresh(category: selectedCategory, forceReload: true)
                    }
                }
            } label: {
                Text(viewModel.canLoadMore ? "Load more stories" : "Try again")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.buttonText)
                    .padding(.horizontal, NutsNewsTheme.spacingM)
                    .padding(.vertical, NutsNewsTheme.spacingS)
                    .background(NutsNewsTheme.buttonGradient)
                    .clipShape(Capsule())
            }
        }
        .padding(NutsNewsTheme.spacingM)
    }

    private func errorBanner(message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(NutsNewsTheme.secondaryText)
            .padding(NutsNewsTheme.spacingS)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.radiusS, style: .continuous))
    }
}

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let dotIndex: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: NutsNewsTheme.spacingXS) {
                Circle()
                    .fill(NutsNewsTheme.categoryDotColor(index: dotIndex, isSelected: isSelected))
                    .frame(width: NutsNewsTheme.spacingXS, height: NutsNewsTheme.spacingXS)

                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? NutsNewsTheme.buttonText : NutsNewsTheme.secondaryText)
                    .lineLimit(1)
            }
            .padding(.horizontal, NutsNewsTheme.chipHorizontalPadding)
            .padding(.vertical, NutsNewsTheme.chipVerticalPadding)
            .background(chipBackground)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : NutsNewsTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var chipBackground: some View {
        if isSelected {
            NutsNewsTheme.buttonGradient
        } else {
            NutsNewsTheme.badgeBackground
        }
    }
}

private struct SettingsView: View {
    let onGoHome: () -> Void
    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue
    @AppStorage(NutsNewsSettings.hapticsEnabledKey) private var hapticsEnabled = NutsNewsSettings.hapticsDefaultEnabled

    private var selectedTheme: NutsNewsAppTheme {
        NutsNewsAppTheme(rawValue: themeRawValue) ?? NutsNewsTheme.defaultTheme
    }

    private let themeOptions: [NutsNewsAppTheme] = [.amber, .sakura, .modernSaaS, .sanJuan, .creativePremium, .moodyCyberpunk]

    var body: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .overlay(NutsNewsTheme.backgroundOverlay)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                        NavigationLink {
                            ThemeSettingsView(onGoHome: onGoHome)
                        } label: {
                            SettingsRow(
                                iconName: "paintpalette.fill",
                                title: "Theme",
                                subtitle: selectedTheme.title
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            HapticsSettingsView(onGoHome: onGoHome)
                        } label: {
                            SettingsRow(
                                iconName: "iphone.radiowaves.left.and.right",
                                title: "Haptics",
                                subtitle: hapticsEnabled ? "On" : "Off"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(NutsNewsTheme.spacingM)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HomeToolbarButton(action: onGoHome)
                }
            }
        }
    }
}

private struct SettingsRow: View {
    let iconName: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: NutsNewsTheme.spacingM) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amberHighlight)
                .frame(width: 34, height: 34)
                .background(NutsNewsTheme.badgeBackground)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(NutsNewsTheme.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.mutedText)
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
}

private struct HapticsSettingsView: View {
    let onGoHome: () -> Void
    @AppStorage(NutsNewsSettings.hapticsEnabledKey) private var hapticsEnabled = NutsNewsSettings.hapticsDefaultEnabled

    var body: some View {
        ZStack {
            NutsNewsTheme.background
                .overlay(NutsNewsTheme.backgroundOverlay)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                    VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                        Toggle(isOn: $hapticsEnabled) {
                            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                                Text("Like button haptics")
                                    .font(.headline)
                                    .foregroundStyle(NutsNewsTheme.primaryText)

                                Text("Feel a soft tap when liking a story.")
                                    .font(.subheadline)
                                    .foregroundStyle(NutsNewsTheme.secondaryText)
                            }
                        }
                        .toggleStyle(.switch)
                        .tint(NutsNewsTheme.amber)
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
                .padding(NutsNewsTheme.spacingM)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HomeToolbarButton(action: onGoHome)
            }
        }
    }
}

private struct ThemeSettingsView: View {
    let onGoHome: () -> Void
    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue
    @State private var themeGlowColor = Color.clear
    @State private var themeGlowOpacity = 0.0
    @State private var themeGlowRadius: CGFloat = 0
    @State private var themeGlowSequence = 0

    private var selectedTheme: NutsNewsAppTheme {
        NutsNewsAppTheme(rawValue: themeRawValue) ?? NutsNewsTheme.defaultTheme
    }

    private let themeOptions: [NutsNewsAppTheme] = [.amber, .sakura, .modernSaaS, .sanJuan, .creativePremium, .moodyCyberpunk]

    var body: some View {
        ZStack {
            NutsNewsTheme.background
                .overlay(NutsNewsTheme.backgroundOverlay)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                    ForEach(themeOptions) { theme in
                        Button {
                            selectTheme(theme)
                        } label: {
                            ThemeOptionRow(
                                theme: theme,
                                isSelected: selectedTheme == theme,
                                glowColor: themeGlowColor,
                                glowOpacity: themeGlowOpacity,
                                glowRadius: themeGlowRadius
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(NutsNewsTheme.spacingM)
                .shadow(color: themeGlowColor.opacity(themeGlowOpacity * 0.45), radius: themeGlowRadius, x: 0, y: 0)
            }
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HomeToolbarButton(
                    action: onGoHome,
                    glowColor: themeGlowColor,
                    glowOpacity: themeGlowOpacity,
                    glowRadius: themeGlowRadius
                )
            }
        }
    }

    private func selectTheme(_ theme: NutsNewsAppTheme) {
        guard selectedTheme != theme else { return }

        let currentAccent = ThemePreviewPalette.palette(for: selectedTheme).accent
        let nextAccent = ThemePreviewPalette.palette(for: theme).accent
        let sequence = themeGlowSequence + 1
        themeGlowSequence = sequence

        themeGlowColor = currentAccent
        themeGlowOpacity = 1
        themeGlowRadius = 22

        withAnimation(.easeInOut(duration: 0.25)) {
            themeRawValue = theme.rawValue
        }

        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 1.0)) {
                themeGlowColor = nextAccent
                themeGlowOpacity = 0
                themeGlowRadius = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            guard themeGlowSequence == sequence else { return }
            themeGlowColor = .clear
            themeGlowOpacity = 0
            themeGlowRadius = 0
        }
    }
}

private struct HomeToolbarButton: View {
    let action: () -> Void
    var glowColor = Color.clear
    var glowOpacity = 0.0
    var glowRadius: CGFloat = 0

    var body: some View {
        Button(action: action) {
            Image(systemName: "house.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amberHighlight)
                .frame(width: 34, height: 34)
                .background(NutsNewsTheme.badgeBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .stroke(glowColor.opacity(glowOpacity * 0.86), lineWidth: 2)
                        .blur(radius: glowRadius * 0.16)
                )
                .shadow(color: glowColor.opacity(glowOpacity * 0.72), radius: glowRadius, x: 0, y: 0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Go home")
    }
}

private struct ThemeOptionRow: View {
    let theme: NutsNewsAppTheme
    let isSelected: Bool
    let glowColor: Color
    let glowOpacity: Double
    let glowRadius: CGFloat

    private var palette: ThemePreviewPalette {
        ThemePreviewPalette.palette(for: theme)
    }

    var body: some View {
        HStack(spacing: NutsNewsTheme.spacingM) {
            radioButton

            Text(theme.title)
                .font(.headline)
                .foregroundStyle(palette.primaryText)

            Spacer(minLength: NutsNewsTheme.spacingM)

            ThemePreviewSwatch(palette: palette)
        }
        .padding(NutsNewsTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.background)
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(isSelected ? palette.accent : palette.border, lineWidth: isSelected ? 1.7 : 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(glowColor.opacity(glowOpacity * 0.88), lineWidth: 2.2)
                .blur(radius: glowRadius * 0.18)
        )
        .shadow(color: glowColor.opacity(glowOpacity * 0.74), radius: glowRadius, x: 0, y: 0)
        .shadow(color: glowColor.opacity(glowOpacity * 0.28), radius: glowRadius * 1.55, x: 0, y: 0)
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
    }

    private var radioButton: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? palette.accent : palette.border, lineWidth: 2)
                .frame(width: 24, height: 24)

            if isSelected {
                Circle()
                    .fill(palette.accent)
                    .frame(width: 12, height: 12)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct ThemePreviewSwatch: View {
    let palette: ThemePreviewPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(palette.primaryText)
                .frame(width: 58, height: 6)

            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(palette.secondaryText)
                .frame(width: 72, height: 5)

            HStack(spacing: 4) {
                Capsule()
                    .fill(palette.accent)
                    .frame(width: 28, height: 8)

                Capsule()
                    .fill(palette.secondaryText.opacity(0.55))
                    .frame(width: 18, height: 8)
            }
        }
        .padding(10)
        .background(palette.card)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct ThemePreviewPalette {
    let background: Color
    let card: Color
    let border: Color
    let primaryText: Color
    let secondaryText: Color
    let accent: Color

    private static func color(hex: UInt, opacity: Double = 1) -> Color {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue).opacity(opacity)
    }

    static func palette(for theme: NutsNewsAppTheme) -> ThemePreviewPalette {
        switch theme {
        case .amber:
            return ThemePreviewPalette(
                background: color(hex: 0x0A0A0A),
                card: color(hex: 0x171717),
                border: color(hex: 0xFACC15, opacity: 0.24),
                primaryText: color(hex: 0xFFFFFF),
                secondaryText: color(hex: 0xD6D3D1),
                accent: color(hex: 0xFACC15)
            )
        case .sakura:
            return ThemePreviewPalette(
                background: color(hex: 0xFDEFF4),
                card: color(hex: 0xFFF7FB),
                border: color(hex: 0xDB7093, opacity: 0.30),
                primaryText: color(hex: 0x3F2B34),
                secondaryText: color(hex: 0x6F5B62),
                accent: color(hex: 0x7AA95C)
            )
        case .modernSaaS:
            return ThemePreviewPalette(
                background: color(hex: 0x121212),
                card: color(hex: 0x1E1E1E),
                border: color(hex: 0x3B82F6, opacity: 0.30),
                primaryText: color(hex: 0xFFFFFF),
                secondaryText: color(hex: 0xB7BEC8),
                accent: color(hex: 0x3B82F6)
            )
        case .sanJuan:
            return ThemePreviewPalette(
                background: color(hex: 0xFFF2D0),
                card: color(hex: 0xFFF6DF),
                border: color(hex: 0x0077B6, opacity: 0.26),
                primaryText: color(hex: 0x3F2415),
                secondaryText: color(hex: 0x75513D),
                accent: color(hex: 0x0077B6)
            )
        case .creativePremium:
            return ThemePreviewPalette(
                background: color(hex: 0x0F172A),
                card: color(hex: 0x1E293B),
                border: color(hex: 0x7C3AED, opacity: 0.34),
                primaryText: color(hex: 0xF8FAFC),
                secondaryText: color(hex: 0x94A3B8),
                accent: color(hex: 0x7C3AED)
            )
        case .moodyCyberpunk:
            return ThemePreviewPalette(
                background: color(hex: 0x1A211B),
                card: color(hex: 0x2C362F),
                border: color(hex: 0xFACC15, opacity: 0.30),
                primaryText: color(hex: 0xF8FAFC),
                secondaryText: color(hex: 0xCBD5C9),
                accent: color(hex: 0xFACC15)
            )
        }
    }
}

#Preview {
    FeedView()
}
