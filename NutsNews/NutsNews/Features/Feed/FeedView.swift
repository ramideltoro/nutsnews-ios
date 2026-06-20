//
//  FeedView.swift
//  NutsNews
//

import Foundation
import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = ArticleFeedViewModel()
    @State private var selectedArticle: Article?
    @State private var selectedCategory: String?
    @State private var isShowingSettings = false
    @State private var rejectedThumbnailArticleIDs = Set<String>()
    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue

    private var selectedTheme: NutsNewsAppTheme {
        NutsNewsAppTheme(rawValue: themeRawValue) ?? NutsNewsTheme.defaultTheme
    }

    private let themeOptions: [NutsNewsAppTheme] = [.amber, .darkPink, .lilac, .plain, .dark]

    var body: some View {
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
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
                    .preferredColorScheme(selectedTheme.preferredColorScheme)
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView {
                    isShowingSettings = false
                }
                .preferredColorScheme(selectedTheme.preferredColorScheme)
            }
        }
        .task {
            await viewModel.loadInitialArticles()
        }
    }

    private var staticHeader: some View {
        VStack(spacing: NutsNewsTheme.spacingS) {
            ZStack {
                HStack(spacing: NutsNewsTheme.spacingM) {
                    settingsButton

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

    private var settingsButton: some View {
        Button {
            isShowingSettings = true
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
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open settings")
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
        ScrollView {
            LazyVStack(alignment: .center, spacing: NutsNewsTheme.spacingM) {
                ForEach(renderableArticles) { article in
                    ArticleCardView(
                        article: article,
                        onReadFullStory: { selectedArticle in
                            self.selectedArticle = selectedArticle
                        },
                        onRenderingRejected: { rejectedArticle in
                            rejectedThumbnailArticleIDs.insert(rejectedArticle.id)
                        }
                    )
                    .frame(maxWidth: .infinity, alignment: .topLeading)
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, NutsNewsTheme.spacingM)
            .padding(.top, NutsNewsTheme.spacingL)
            .padding(.bottom, NutsNewsTheme.spacingL)
        }
        .refreshable {
            await viewModel.refresh(category: selectedCategory, forceReload: true)
        }
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

    private let themeOptions: [NutsNewsAppTheme] = [.amber, .darkPink, .lilac, .plain, .dark]

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

    private var selectedTheme: NutsNewsAppTheme {
        NutsNewsAppTheme(rawValue: themeRawValue) ?? NutsNewsTheme.defaultTheme
    }

    private let themeOptions: [NutsNewsAppTheme] = [.amber, .darkPink, .lilac, .plain, .dark]

    var body: some View {
        ZStack {
            NutsNewsTheme.background
                .overlay(NutsNewsTheme.backgroundOverlay)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                    ForEach(themeOptions) { theme in
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                themeRawValue = theme.rawValue
                            }
                        } label: {
                            ThemeOptionRow(
                                theme: theme,
                                isSelected: selectedTheme == theme
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(NutsNewsTheme.spacingM)
            }
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HomeToolbarButton(action: onGoHome)
            }
        }
    }
}

private struct HomeToolbarButton: View {
    let action: () -> Void

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
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Go home")
    }
}

private struct ThemeOptionRow: View {
    let theme: NutsNewsAppTheme
    let isSelected: Bool

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

    static func palette(for theme: NutsNewsAppTheme) -> ThemePreviewPalette {
        switch theme {
        case .plain:
            return ThemePreviewPalette(
                background: Color.white,
                card: Color(red: 0.96, green: 0.96, blue: 0.94),
                border: Color.black.opacity(0.16),
                primaryText: Color.black,
                secondaryText: Color.black.opacity(0.62),
                accent: Color(red: 0.12, green: 0.12, blue: 0.13)
            )
        case .dark:
            return ThemePreviewPalette(
                background: Color.black,
                card: Color(red: 0.10, green: 0.10, blue: 0.11),
                border: Color.white.opacity(0.22),
                primaryText: Color.white,
                secondaryText: Color.white.opacity(0.68),
                accent: Color.white
            )
        case .darkPink:
            return ThemePreviewPalette(
                background: Color(red: 0.07, green: 0.09, blue: 0.15),
                card: Color(red: 0.10, green: 0.13, blue: 0.20),
                border: Color(red: 1.0, green: 0.00, blue: 0.50).opacity(0.42),
                primaryText: Color(red: 0.95, green: 0.96, blue: 0.96),
                secondaryText: Color(red: 0.00, green: 0.94, blue: 1.0),
                accent: Color(red: 1.0, green: 0.00, blue: 0.50)
            )
        case .lilac:
            return ThemePreviewPalette(
                background: Color(red: 0.07, green: 0.07, blue: 0.08),
                card: Color(red: 0.16, green: 0.14, blue: 0.22),
                border: Color(red: 0.58, green: 0.46, blue: 0.80).opacity(0.58),
                primaryText: Color(red: 0.95, green: 0.93, blue: 0.99),
                secondaryText: Color(red: 0.82, green: 0.77, blue: 0.91),
                accent: Color(red: 0.00, green: 0.90, blue: 1.00)
            )
        case .amber:
            return ThemePreviewPalette(
                background: Color(red: 0.07, green: 0.07, blue: 0.07),
                card: Color(red: 0.12, green: 0.12, blue: 0.12),
                border: Color(red: 1.0, green: 0.76, blue: 0.03).opacity(0.42),
                primaryText: Color.white,
                secondaryText: Color.white.opacity(0.68),
                accent: Color(red: 1.0, green: 0.76, blue: 0.03)
            )
        }
    }
}

#Preview {
    FeedView()
}
