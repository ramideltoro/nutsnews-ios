//
//  ArticleDetailView.swift
//  NutsNews
//

import Foundation
import SwiftUI
import UIKit

struct ArticleDetailView: View {
    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue
    let article: Article

    @Environment(\.dismiss) private var dismiss
    @State private var isShowingOriginalStory = false
    @State private var shouldUseThreeTwoHeroCrop = false
    @AppStorage(LikedStoryStore.storageKey) private var likedStoryIDsRawValue = LikedStoryStore.emptyRawValue
    @AppStorage(SavedStoryStore.storageKey) private var savedStoriesRawValue = SavedStoryStore.emptyRawValue
    @AppStorage(StoryNoteStore.storageKey) private var storyNotesRawValue = StoryNoteStore.emptyRawValue
    @AppStorage(NutsNewsReflectionStore.storageKey) private var storyReflectionsRawValue = NutsNewsReflectionStore.emptyRawValue
    @AppStorage(ReadingStatsStore.storageKey) private var readingStatsRawValue = ReadingStatsStore.emptyRawValue
    @State private var noteDraft = ""
    @State private var noteStatusMessage = ""
    @State private var reflectionStatusMessage = ""
    @State private var pageGlowOpacity = 0.0
    @State private var pageGlowRadius: CGFloat = 0
    @State private var openOriginalButtonGlowOpacity = 0.0
    @State private var openOriginalButtonGlowRadius: CGFloat = 0
    @State private var shareButtonGlowOpacity = 0.0
    @State private var shareButtonGlowRadius: CGFloat = 0
    @State private var likeButtonGlowOpacity = 0.0
    @State private var likeButtonGlowRadius: CGFloat = 0
    @State private var listenButtonGlowOpacity = 0.0
    @State private var listenButtonGlowRadius: CGFloat = 0
    @State private var isShowingListenModeSheet = false
    @StateObject private var listenController = NutsNewsListenController()
    @State private var isShowingShareCardSheet = false
    @State private var shareCardItems: [Any] = []
    @State private var isCreatingShareCard = false


    private let wideThumbnailCropAspectRatio: CGFloat = 3.0 / 2.0

    private var isLiked: Bool {
        LikedStoryStore.isLiked(article, rawValue: likedStoryIDsRawValue)
    }

    var body: some View {
        originalStoryPresentationContainer
    }

    @ViewBuilder
    private var originalStoryPresentationContainer: some View {
        if shouldUseFullScreenOriginalStoryPresentation {
            storyNavigationStack
                .fullScreenCover(isPresented: $isShowingOriginalStory) {
                    originalStoryBrowser
                }
        } else {
            storyNavigationStack
                .sheet(isPresented: $isShowingOriginalStory) {
                    originalStoryBrowser
                }
        }
    }

    private var shouldUseFullScreenOriginalStoryPresentation: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    private var storyNavigationStack: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    NutsNewsTheme.background
                        .overlay(NutsNewsTheme.backgroundOverlay)
                        .ignoresSafeArea()

                    if isIPadLandscapeStoryLayout(size: geometry.size) {
                        compactLandscapeStoryContent(size: geometry.size)
                    } else {
                        regularScrollableStoryContent
                    }
                }
            }
            .navigationTitle("Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    closeButton
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    storyListenButton
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    storyLikeButton
                }
            }
            .animation(.easeInOut(duration: 0.25), value: themeRawValue)
            .task(id: article.thumbnailURL) {
                await inspectHeroThumbnailAspectRatio()
            }
            .onAppear {
                loadStoryNoteDraft()
                recordStoryOpen()
            }
            .onDisappear {
                listenController.stop()
            }
            .sheet(isPresented: $isShowingShareCardSheet) {
                NutsNewsActivityView(activityItems: shareCardItems)
            }
            .sheet(isPresented: $isShowingListenModeSheet) {
                listenModeSheet
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var regularScrollableStoryContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                heroImage
                categoryRow
                titleSection
                nutsNewsBriefSection
                dailyReflectionSection
                summarySection
                storyNoteSection
                shareCardSection
                actionButtons
            }
            .padding(NutsNewsTheme.spacingM)
            .frame(maxWidth: .infinity, alignment: .leading)
            .shadow(color: NutsNewsTheme.amberHighlight.opacity(pageGlowOpacity * 0.58), radius: pageGlowRadius, x: 0, y: 0)
            .shadow(color: NutsNewsTheme.amberGlow.opacity(pageGlowOpacity * 0.45), radius: pageGlowRadius * 1.5, x: 0, y: 0)
        }
    }

    private func isIPadLandscapeStoryLayout(size: CGSize) -> Bool {
        UIDevice.current.userInterfaceIdiom == .pad && size.width > size.height
    }

    private func compactLandscapeStoryContent(size: CGSize) -> some View {
        let imageColumnWidth = min(size.width * 0.39, 440)

        return HStack(alignment: .top, spacing: NutsNewsTheme.spacingM) {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                heroImage
                categoryRow
            }
            .frame(width: imageColumnWidth, alignment: .topLeading)

            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                compactLandscapeTitleSection
                compactLandscapeBriefSection
                compactLandscapeReflectionSection
                compactLandscapeSummarySection
                compactLandscapeStoryNoteSection
                compactLandscapeShareCardSection
                Spacer(minLength: 0)
                compactLandscapeActionButtons
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(.horizontal, NutsNewsTheme.spacingM)
        .padding(.vertical, NutsNewsTheme.spacingS)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .shadow(color: NutsNewsTheme.amberHighlight.opacity(pageGlowOpacity * 0.58), radius: pageGlowRadius, x: 0, y: 0)
        .shadow(color: NutsNewsTheme.amberGlow.opacity(pageGlowOpacity * 0.45), radius: pageGlowRadius * 1.5, x: 0, y: 0)
    }

    @ViewBuilder
    private var originalStoryBrowser: some View {
        if let originalURL = article.originalURL {
            SafariView(
                url: originalURL,
                forceFullScreen: shouldUseFullScreenOriginalStoryPresentation
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var heroImage: some View {
        if let thumbnailURL = article.thumbnailURL {
            AsyncImage(url: thumbnailURL) { phase in
                switch phase {
                case .empty:
                    imagePlaceholder
                        .overlay {
                            ProgressView()
                                .tint(NutsNewsTheme.amber)
                        }
                case .success(let image):
                    renderedHeroImage(image)
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

    @ViewBuilder
    private func renderedHeroImage(_ image: Image) -> some View {
        if shouldUseThreeTwoHeroCrop {
            heroThumbnailFrame
                .overlay {
                    image
                        .resizable()
                        .scaledToFill()
                }
                .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
                .clipped()
        } else {
            image
                .resizable()
                .scaledToFill()
                .frame(height: NutsNewsTheme.detailHeroHeight)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
                .clipped()
        }
    }

    @ViewBuilder
    private var imagePlaceholder: some View {
        if shouldUseThreeTwoHeroCrop {
            heroThumbnailFrame
                .overlay {
                    heroPlaceholderContent
                }
                .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
        } else {
            defaultHeroThumbnailFrame
                .overlay {
                    heroPlaceholderContent
                }
                .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
        }
    }

    private var heroThumbnailFrame: some View {
        RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
            .fill(NutsNewsTheme.badgeBackground)
            .frame(maxWidth: .infinity)
            .aspectRatio(wideThumbnailCropAspectRatio, contentMode: .fit)
    }

    private var defaultHeroThumbnailFrame: some View {
        RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
            .fill(NutsNewsTheme.badgeBackground)
            .frame(height: NutsNewsTheme.detailHeroHeight)
            .frame(maxWidth: .infinity)
    }

    private var heroPlaceholderContent: some View {
        VStack(spacing: NutsNewsTheme.spacingS) {
            Image(systemName: "newspaper")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(NutsNewsTheme.amber)

            Text("NutsNews")
                .font(.headline)
                .foregroundStyle(NutsNewsTheme.secondaryText)
        }
    }

    private func inspectHeroThumbnailAspectRatio() async {
        await MainActor.run {
            shouldUseThreeTwoHeroCrop = false
        }

        guard let thumbnailURL = article.thumbnailURL else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: thumbnailURL)

            guard let image = UIImage(data: data) else {
                return
            }

            let pixelWidth = CGFloat((image.size.width * image.scale).rounded())
            let pixelHeight = CGFloat((image.size.height * image.scale).rounded())

            guard pixelWidth > 0, pixelHeight > 0 else {
                return
            }

            let imageAspectRatio = pixelWidth / pixelHeight
            let shouldCropWideThumbnail = imageAspectRatio > wideThumbnailCropAspectRatio

            await MainActor.run {
                shouldUseThreeTwoHeroCrop = shouldCropWideThumbnail
            }
        } catch {
            // Keep the default hero layout if metadata inspection fails.
        }
    }

    @ViewBuilder
    private var categoryRow: some View {
        if !article.categories.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: NutsNewsTheme.spacingXS) {
                    ForEach(article.categories.prefix(8), id: \.self) { category in
                        CategoryBadge(title: category)
                    }
                }
            }
        }
    }

    private var titleSection: some View {
        Text(article.title)
            .font(.system(size: 21, weight: .bold, design: .rounded))
            .foregroundStyle(NutsNewsTheme.primaryText)
            .multilineTextAlignment(.leading)
            .lineSpacing(NutsNewsTheme.spacingXXS)
            .lineLimit(nil)
            .minimumScaleFactor(0.75)
            .allowsTightening(true)
            .fixedSize(horizontal: false, vertical: true)
            .layoutPriority(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }

    private var nutsNewsBriefSection: some View {
        DetailInfoCard(label: "NutsNews Brief") {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                HStack(spacing: NutsNewsTheme.spacingS) {
                    NutsNewsBriefMetric(iconName: "clock.fill", text: estimatedReadTime)
                    NutsNewsBriefMetric(iconName: "heart.text.square.fill", text: primaryMoodLabel)
                }

                NutsNewsBriefBullet(
                    title: "What happened",
                    text: briefWhatHappened
                )

                NutsNewsBriefBullet(
                    title: "Why it’s good news",
                    text: briefWhyGood
                )

                NutsNewsBriefBullet(
                    title: "Feel-good takeaway",
                    text: briefTakeaway
                )
            }
        }
    }

    private var dailyReflectionSection: some View {
        DetailInfoCard(label: "Daily Reflection") {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                HStack(alignment: .top, spacing: NutsNewsTheme.spacingS) {
                    Image(systemName: selectedReflectionIconName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(NutsNewsTheme.amberHighlight)
                        .frame(width: 34, height: 34)
                        .background(NutsNewsTheme.badgeBackground)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                        Text(selectedReflectionTitle)
                            .font(.headline)
                            .foregroundStyle(NutsNewsTheme.primaryText)

                        Text(selectedReflectionSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(NutsNewsTheme.secondaryText)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LazyVGrid(columns: reflectionGridColumns, spacing: NutsNewsTheme.spacingS) {
                    ForEach(NutsNewsReflectionReaction.allCases) { reaction in
                        Button {
                            saveReflection(reaction)
                        } label: {
                            VStack(spacing: NutsNewsTheme.spacingXXS) {
                                Image(systemName: reaction.iconName)
                                    .font(.system(size: 17, weight: .bold))

                                Text(reaction.title)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.82)
                            }
                            .foregroundStyle(isSelectedReflection(reaction) ? NutsNewsTheme.buttonText : NutsNewsTheme.primaryText)
                            .frame(maxWidth: .infinity, minHeight: 74)
                            .padding(.horizontal, NutsNewsTheme.spacingXS)
                            .background(isSelectedReflection(reaction) ? NutsNewsTheme.buttonGradient : LinearGradient(colors: [NutsNewsTheme.badgeBackground, NutsNewsTheme.badgeBackground], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .overlay(
                                RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                                    .stroke(isSelectedReflection(reaction) ? NutsNewsTheme.amberHighlight.opacity(0.85) : NutsNewsTheme.cardBorder, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text(reflectionStatusText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.mutedText)
            }
        }
    }

    private var shareCardSection: some View {
        DetailInfoCard(label: "") {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                NutsNewsShareCardMiniPreview(
                    article: article,
                    takeaway: briefTakeaway,
                    moodLabel: primaryMoodLabel
                )
                Button {
                    createAndSharePositiveCard()
                } label: {
                    HStack(spacing: NutsNewsTheme.spacingXS) {
                        if isCreatingShareCard {
                            ProgressView()
                                .tint(NutsNewsTheme.buttonText)
                                .controlSize(.small)
                        } else {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }

                        Text(isCreatingShareCard ? "Creating card" : "Share card with someone special")
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(NutsNewsTheme.buttonGradient)
                    .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                            .stroke(NutsNewsTheme.amberHighlight.opacity(shareButtonGlowOpacity * 0.86), lineWidth: 2)
                            .blur(radius: shareButtonGlowRadius * 0.16)
                    )
                    .shadow(color: NutsNewsTheme.amberHighlight.opacity(shareButtonGlowOpacity * 0.72), radius: shareButtonGlowRadius, x: 0, y: 0)
                    .shadow(color: NutsNewsTheme.amberGlow.opacity(shareButtonGlowOpacity * 0.55), radius: shareButtonGlowRadius * 1.45, x: 0, y: 0)
                    .scaleEffect(1 + (shareButtonGlowOpacity * 0.03))
                }
                .buttonStyle(.plain)
                .disabled(isCreatingShareCard)
                .opacity(isCreatingShareCard ? 0.75 : 1)
            }
        }
    }

    @ViewBuilder
    private var summarySection: some View {
        if !article.summary.isEmpty {
            DetailInfoCard(label: "Summary") {
                Text(article.summary)
                    .font(.body)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .lineSpacing(NutsNewsTheme.spacingXXS)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var sourceSection: some View {
        DetailInfoCard(label: "Source") {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                Text(article.source)
                    .font(.headline)
                    .foregroundStyle(NutsNewsTheme.primaryText)

                Text(article.displayDate)
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.mutedText)
            }
        }
    }

    private var storyNoteSection: some View {
        DetailInfoCard(label: "My Note") {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                Text("Save a private thought, reminder, or reason this story made you smile.")
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.mutedText)

                TextEditor(text: $noteDraft)
                    .font(.body)
                    .foregroundStyle(NutsNewsTheme.primaryText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 96)
                    .padding(NutsNewsTheme.spacingS)
                    .background(NutsNewsTheme.badgeBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                            .stroke(Color.clear, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))

                HStack(spacing: NutsNewsTheme.spacingS) {
                    Button {
                        saveStoryNote()
                    } label: {
                        Label("Save note", systemImage: "square.and.arrow.down")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(NutsNewsTheme.buttonText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(NutsNewsTheme.buttonGradient)
                            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        removeStoryNote()
                    } label: {
                        Label("Clear", systemImage: "trash")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(NutsNewsTheme.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(NutsNewsTheme.badgeBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                                    .stroke(Color.clear, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(noteDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !StoryNoteStore.hasNote(for: article, rawValue: storyNotesRawValue))
                    .opacity(noteDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !StoryNoteStore.hasNote(for: article, rawValue: storyNotesRawValue) ? 0.55 : 1.0)
                }

                if !noteStatusMessage.isEmpty {
                    Text(noteStatusMessage)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(NutsNewsTheme.amber)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private var compactLandscapeTitleSection: some View {
        Text(article.title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(NutsNewsTheme.primaryText)
            .multilineTextAlignment(.leading)
            .lineSpacing(2)
            .lineLimit(3)
            .minimumScaleFactor(0.78)
            .allowsTightening(true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }

    private var compactLandscapeBriefSection: some View {
        CompactDetailInfoCard(label: "NutsNews Brief") {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXS) {
                Text(briefWhyGood)
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .lineSpacing(2)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Takeaway: \(briefTakeaway)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.amber)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var compactLandscapeReflectionSection: some View {
        CompactDetailInfoCard(label: "Reflection") {
            HStack(spacing: NutsNewsTheme.spacingS) {
                ForEach(NutsNewsReflectionReaction.allCases.prefix(3)) { reaction in
                    Button {
                        saveReflection(reaction)
                    } label: {
                        HStack(spacing: NutsNewsTheme.spacingXXS) {
                            Image(systemName: reaction.iconName)
                            Text(reaction.shortTitle)
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(isSelectedReflection(reaction) ? NutsNewsTheme.buttonText : NutsNewsTheme.primaryText)
                        .padding(.horizontal, NutsNewsTheme.spacingS)
                        .padding(.vertical, 8)
                        .background(isSelectedReflection(reaction) ? NutsNewsTheme.buttonGradient : LinearGradient(colors: [NutsNewsTheme.badgeBackground, NutsNewsTheme.badgeBackground], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 0)
            }
        }
    }


    private var compactLandscapeStoryNoteSection: some View {
        CompactDetailInfoCard(label: "My Note") {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXS) {
                TextEditor(text: $noteDraft)
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.primaryText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 58, maxHeight: 74)
                    .padding(NutsNewsTheme.spacingXS)
                    .background(NutsNewsTheme.badgeBackground)
                    .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))

                HStack(spacing: NutsNewsTheme.spacingXS) {
                    Button {
                        saveStoryNote()
                    } label: {
                        Label("Save", systemImage: "square.and.arrow.down")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(NutsNewsTheme.buttonText)
                            .padding(.vertical, 7)
                            .padding(.horizontal, NutsNewsTheme.spacingS)
                            .background(NutsNewsTheme.buttonGradient)
                            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        removeStoryNote()
                    } label: {
                        Label("Clear", systemImage: "trash")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(NutsNewsTheme.primaryText)
                            .padding(.vertical, 7)
                            .padding(.horizontal, NutsNewsTheme.spacingS)
                            .background(NutsNewsTheme.badgeBackground)
                            .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(noteDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !StoryNoteStore.hasNote(for: article, rawValue: storyNotesRawValue))
                    .opacity(noteDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !StoryNoteStore.hasNote(for: article, rawValue: storyNotesRawValue) ? 0.55 : 1.0)

                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var compactLandscapeShareCardSection: some View {
        CompactDetailInfoCard(label: "") {
            Button {
                createAndSharePositiveCard()
            } label: {
                HStack(spacing: NutsNewsTheme.spacingXS) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text(isCreatingShareCard ? "Creating card" : "Share card with someone special")
                    Spacer(minLength: NutsNewsTheme.spacingXS)
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.buttonText)
                .padding(.vertical, 10)
                .padding(.horizontal, NutsNewsTheme.spacingS)
                .background(NutsNewsTheme.buttonGradient)
                .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isCreatingShareCard)
        }
    }

    @ViewBuilder
    private var compactLandscapeSummarySection: some View {
        if !article.summary.isEmpty {
            CompactDetailInfoCard(label: "Summary") {
                Text(article.summary)
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .lineSpacing(2)
                    .lineLimit(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var compactLandscapeSourceSection: some View {
        CompactDetailInfoCard(label: "Source") {
            HStack(alignment: .center, spacing: NutsNewsTheme.spacingS) {
                Text(article.source)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.primaryText)
                    .lineLimit(1)

                Spacer(minLength: NutsNewsTheme.spacingS)

                Text(article.displayDate)
                    .font(.caption)
                    .foregroundStyle(NutsNewsTheme.mutedText)
                    .lineLimit(1)
            }
        }
    }

    private var sourceButtonTitle: String {
        let cleanSource = article.source.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanSource.isEmpty ? "Source" : "Source - \(cleanSource)"
    }

    private var compactLandscapeActionButtons: some View {
        HStack(spacing: NutsNewsTheme.spacingS) {
            Button {
                openOriginalStoryWithGlow()
            } label: {
                HStack(spacing: NutsNewsTheme.spacingXS) {
                    Image(systemName: "safari")
                    Text(sourceButtonTitle)
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(NutsNewsTheme.badgeBackground)
                .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                        .stroke(NutsNewsTheme.amberHighlight.opacity(openOriginalButtonGlowOpacity * 0.86), lineWidth: 2)
                        .blur(radius: openOriginalButtonGlowRadius * 0.16)
                )
                .shadow(color: NutsNewsTheme.amberHighlight.opacity(openOriginalButtonGlowOpacity * 0.72), radius: openOriginalButtonGlowRadius, x: 0, y: 0)
                .shadow(color: NutsNewsTheme.amberGlow.opacity(openOriginalButtonGlowOpacity * 0.55), radius: openOriginalButtonGlowRadius * 1.45, x: 0, y: 0)
                .scaleEffect(1 + (openOriginalButtonGlowOpacity * 0.03))
            }
            .buttonStyle(.plain)
            .disabled(article.originalURL == nil)
            .opacity(article.originalURL == nil ? 0.55 : 1.0)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: NutsNewsTheme.spacingS) {
            Button {
                openOriginalStoryWithGlow()
            } label: {
                HStack(spacing: NutsNewsTheme.spacingXS) {
                    Image(systemName: "safari")
                    Text(sourceButtonTitle)
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(NutsNewsTheme.badgeBackground)
                .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                        .stroke(NutsNewsTheme.amberHighlight.opacity(openOriginalButtonGlowOpacity * 0.86), lineWidth: 2)
                        .blur(radius: openOriginalButtonGlowRadius * 0.16)
                )
                .shadow(color: NutsNewsTheme.amberHighlight.opacity(openOriginalButtonGlowOpacity * 0.72), radius: openOriginalButtonGlowRadius, x: 0, y: 0)
                .shadow(color: NutsNewsTheme.amberGlow.opacity(openOriginalButtonGlowOpacity * 0.55), radius: openOriginalButtonGlowRadius * 1.45, x: 0, y: 0)
                .scaleEffect(1 + (openOriginalButtonGlowOpacity * 0.03))
            }
            .buttonStyle(.plain)
            .disabled(article.originalURL == nil)
            .opacity(article.originalURL == nil ? 0.55 : 1.0)
        }
    }

    private var closeButton: some View {
        Button("Close") {
            listenController.stop()
            dismiss()
        }
        .foregroundStyle(NutsNewsTheme.amber)
        .shadow(color: NutsNewsTheme.amberHighlight.opacity(pageGlowOpacity * 0.64), radius: pageGlowRadius, x: 0, y: 0)
    }

    private var toolbarIconButtonSize: CGFloat { 38 }

    private var storyListenButton: some View {
        Button {
            openListenModePopup()
        } label: {
            Image(systemName: listenToolbarIconName)
                .font(.system(size: 16, weight: .bold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(listenController.isActive ? NutsNewsTheme.amber : NutsNewsTheme.amberHighlight)
                .frame(width: toolbarIconButtonSize, height: toolbarIconButtonSize)
                .background(
                    Circle()
                        .fill(NutsNewsTheme.badgeBackground)
                )
                .overlay(
                    Circle()
                        .stroke(Color.clear, lineWidth: 1)
                )
                .contentShape(Circle())
                .shadow(color: NutsNewsTheme.amberHighlight.opacity(listenButtonGlowOpacity * 0.72), radius: listenButtonGlowRadius, x: 0, y: 0)
                .shadow(color: NutsNewsTheme.amberGlow.opacity(listenButtonGlowOpacity * 0.55), radius: listenButtonGlowRadius * 1.45, x: 0, y: 0)
                .scaleEffect(1 + (listenButtonGlowOpacity * 0.035))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(listenController.isActive ? "Open Listen Mode" : "Listen to story brief")
    }

    private var listenModeSheet: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .overlay(NutsNewsTheme.backgroundOverlay)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                        listenModeHero
                        listenModeWaveCard
                        listenModeControls
                        listenModeBriefPreview
                    }
                    .padding(NutsNewsTheme.spacingM)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("Listen Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        closeListenModePopup()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.amber)
                }
            }
            .onDisappear {
                listenController.stop()
            }
        }
    }

    private var listenModeHero: some View {
        DetailInfoCard(label: "Audio Brief") {
            HStack(alignment: .top, spacing: NutsNewsTheme.spacingM) {
                Image(systemName: listenController.iconName)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(NutsNewsTheme.buttonText)
                    .frame(width: 58, height: 58)
                    .background(NutsNewsTheme.buttonGradient)
                    .clipShape(Circle())
                    .shadow(color: NutsNewsTheme.amberHighlight.opacity(isListenModeReading ? 0.45 : 0.22), radius: isListenModeReading ? 18 : 8, x: 0, y: 0)

                VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                    Text(listenModeTitle)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(NutsNewsTheme.primaryText)

                    Text("A calm spoken version of the NutsNews Brief, read with on-device iOS speech and natural pauses.")
                        .font(.subheadline)
                        .foregroundStyle(NutsNewsTheme.secondaryText)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(listenController.statusMessage)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(NutsNewsTheme.amber)
                        .padding(.top, NutsNewsTheme.spacingXXS)
                }
            }
        }
    }

    private var listenModeWaveCard: some View {
        DetailInfoCard(label: "Now Playing") {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                Button {
                    toggleListenMode()
                } label: {
                    NutsNewsAudioWaveView(
                        isAnimating: isListenModeReading,
                        isPaused: isListenModePaused,
                        speechLevel: listenController.speechWaveLevel,
                        speechFrequency: listenController.speechWaveFrequency,
                        speechSeed: listenController.speechWaveSeed
                    )
                    .frame(height: 96)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, NutsNewsTheme.spacingXS)
                    .background(NutsNewsTheme.badgeBackground)
                    .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                            .stroke(Color.clear, lineWidth: 1)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isListenModeReading ? "Pause audio brief" : "Resume audio brief")

                HStack(spacing: NutsNewsTheme.spacingXS) {
                    Image(systemName: isListenModeReading ? "waveform" : (isListenModePaused ? "pause.fill" : "speaker.wave.2"))
                    Text(isListenModeReading ? "Tap waves to pause" : (isListenModePaused ? "Paused — tap waves to resume" : listenController.shortStatusMessage))
                    Spacer(minLength: 0)
                    Text(estimatedReadTime)
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.mutedText)
            }
        }
    }

    private var listenModeControls: some View {
        HStack(spacing: NutsNewsTheme.spacingS) {
            Button {
                toggleListenMode()
            } label: {
                Label(listenController.primaryButtonTitle, systemImage: listenController.primaryButtonIconName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(NutsNewsTheme.buttonGradient)
                    .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
            }
            .buttonStyle(.plain)

            if listenController.isActive {
                Button {
                    listenController.stop()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(NutsNewsTheme.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(NutsNewsTheme.badgeBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                                .stroke(Color.clear, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var listenModeBriefPreview: some View {
        DetailInfoCard(label: "What you’ll hear") {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
                NutsNewsBriefBullet(title: "Story", text: article.title)
                NutsNewsBriefBullet(title: "Why it’s good news", text: briefWhyGood)
                NutsNewsBriefBullet(title: "Takeaway", text: briefTakeaway)
            }
        }
    }

    private var storyLikeButton: some View {
        Button {
            triggerStoryLikeGlow()
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .bold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(isLiked ? NutsNewsTheme.likedCardAccent : NutsNewsTheme.amberHighlight)
                .frame(width: toolbarIconButtonSize, height: toolbarIconButtonSize)
                .background(
                    Circle()
                        .fill(NutsNewsTheme.badgeBackground)
                )
                .overlay(
                    Circle()
                        .stroke(Color.clear, lineWidth: 1)
                )
                .contentShape(Circle())
                .shadow(color: NutsNewsTheme.amberHighlight.opacity(likeButtonGlowOpacity * 0.72), radius: likeButtonGlowRadius, x: 0, y: 0)
                .shadow(color: NutsNewsTheme.amberGlow.opacity(likeButtonGlowOpacity * 0.55), radius: likeButtonGlowRadius * 1.45, x: 0, y: 0)
                .scaleEffect(1 + (likeButtonGlowOpacity * 0.035))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isLiked ? "Liked" : "Like story")
    }

    private var listenToolbarIconName: String {
        if listenController.isActive {
            return "waveform"
        }

        return "play.fill"
    }

    private var isListenModeReading: Bool {
        listenController.shortStatusMessage == "Reading"
    }

    private var isListenModePaused: Bool {
        listenController.shortStatusMessage == "Paused"
    }

    private var listenModeTitle: String {
        switch listenController.shortStatusMessage {
        case "Reading":
            return "Playing your audio brief"
        case "Paused":
            return "Audio brief paused"
        default:
            return "Listen to this story"
        }
    }

    private var selectedReflectionRecord: NutsNewsStoryReflection? {
        NutsNewsReflectionStore.reflection(for: article, rawValue: storyReflectionsRawValue)
    }

    private var selectedReflectionReaction: NutsNewsReflectionReaction? {
        guard let selectedReflectionRecord else {
            return nil
        }

        return NutsNewsReflectionReaction(rawValue: selectedReflectionRecord.reactionID)
    }

    private var selectedReflectionTitle: String {
        selectedReflectionReaction?.savedTitle ?? "How did this story land?"
    }

    private var selectedReflectionSubtitle: String {
        if let selectedReflectionRecord,
           let reaction = selectedReflectionReaction {
            return "You marked this story as \(reaction.title.lowercased()) on \(selectedReflectionRecord.formattedDate)."
        }

        return "Tap a quick reaction to make this story part of your private good-news habit. Saved only on this device."
    }

    private var selectedReflectionIconName: String {
        selectedReflectionReaction?.iconName ?? "sparkles"
    }

    private var reflectionStatusText: String {
        if !reflectionStatusMessage.isEmpty {
            return reflectionStatusMessage
        }

        if selectedReflectionReaction != nil {
            return "Reflection saved privately on this device"
        }

        return "No account needed — this stays on your iPhone"
    }

    private var reflectionGridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: NutsNewsTheme.spacingS),
            GridItem(.flexible(), spacing: NutsNewsTheme.spacingS),
            GridItem(.flexible(), spacing: NutsNewsTheme.spacingS)
        ]
    }

    private var estimatedReadTime: String {
        let combinedText = "\(article.title) \(article.summary)"
        let wordCount = combinedText
            .split { $0.isWhitespace || $0.isNewline }
            .count
        let minutes = max(1, Int(ceil(Double(wordCount) / 180.0)))
        return "\(minutes) min native brief"
    }

    private var primaryMoodLabel: String {
        if categoryTextContains(anyOf: ["science", "research", "space", "technology"]) {
            return "Curious"
        }

        if categoryTextContains(anyOf: ["achievement", "record", "award", "success"]) {
            return "Inspired"
        }

        if categoryTextContains(anyOf: ["community", "kindness", "volunteer", "family"]) {
            return "Hopeful"
        }

        return "Calm"
    }

    private var briefWhatHappened: String {
        let cleanedSummary = article.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanedSummary.isEmpty {
            return cleanedSummary
        }

        return article.title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var briefWhyGood: String {
        if categoryTextContains(anyOf: ["animal", "wildlife", "rescue", "pet"]) {
            return "It gives readers a wholesome moment centered on care, protection, and the bond people share with animals."
        }

        if categoryTextContains(anyOf: ["science", "research", "space", "technology", "discovery"]) {
            return "It highlights progress and curiosity, showing how discovery can make the world feel more hopeful."
        }

        if categoryTextContains(anyOf: ["community", "volunteer", "school", "family", "kindness"]) {
            return "It shows people helping each other in a practical way, which is exactly the kind of local goodness NutsNews is built to surface."
        }

        if categoryTextContains(anyOf: ["wellness", "health", "garden", "nature", "healing"]) {
            return "It offers a calmer kind of news moment, focused on wellbeing, restoration, and small positive changes."
        }

        if categoryTextContains(anyOf: ["achievement", "record", "award", "first", "milestone"]) {
            return "It celebrates effort, persistence, and a meaningful win that can leave readers feeling encouraged."
        }

        return "It gives readers a positive, low-stress story with a clear reason to feel a little better about the day."
    }

    private var briefTakeaway: String {
        if categoryTextContains(anyOf: ["community", "volunteer", "kindness"]) {
            return "Good news often starts close to home."
        }

        if categoryTextContains(anyOf: ["science", "research", "discovery"]) {
            return "Progress is still happening, one discovery at a time."
        }

        if categoryTextContains(anyOf: ["animal", "wildlife", "rescue"]) {
            return "Care and compassion can travel farther than expected."
        }

        if categoryTextContains(anyOf: ["achievement", "record", "milestone"]) {
            return "Small steps can turn into a story worth celebrating."
        }

        return "A quick reminder that the world still has soft spots."
    }

    private var listenScript: String {
        [
            "Here’s your NutsNews brief.",
            article.title,
            "What happened: \(briefWhatHappened)",
            "Why it’s good news: \(briefWhyGood)",
            "The feel-good takeaway: \(briefTakeaway)",
            "Source: \(article.source)."
        ]
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: "\n")
    }

    private func openListenModePopup() {
        isShowingListenModeSheet = true
        triggerListenButtonGlow()

        if !listenController.isActive {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                listenController.toggle(script: listenScript)
            }
        }
    }

    private func closeListenModePopup() {
        listenController.stop()
        isShowingListenModeSheet = false
    }

    private func toggleListenMode() {
        listenController.toggle(script: listenScript)
    }

    private func categoryTextContains(anyOf keywords: [String]) -> Bool {
        let searchableText = ([article.title, article.summary, article.source] + article.categories)
            .joined(separator: " ")
            .lowercased()

        return keywords.contains { searchableText.contains($0) }
    }

    private func isSelectedReflection(_ reaction: NutsNewsReflectionReaction) -> Bool {
        selectedReflectionReaction == reaction
    }

    private func saveReflection(_ reaction: NutsNewsReflectionReaction) {
        storyReflectionsRawValue = NutsNewsReflectionStore.rawValue(
            settingReaction: reaction,
            article: article,
            currentRawValue: storyReflectionsRawValue
        )

        withAnimation(.easeInOut(duration: 0.2)) {
            reflectionStatusMessage = "Saved: \(reaction.title)"
            pageGlowOpacity = 1
            pageGlowRadius = 18
        }

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.9)) {
                pageGlowOpacity = 0
                pageGlowRadius = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.25)) {
                reflectionStatusMessage = ""
            }
        }
    }

    private func loadStoryNoteDraft() {
        noteDraft = StoryNoteStore.noteText(for: article, rawValue: storyNotesRawValue)
    }

    private func recordStoryOpen() {
        readingStatsRawValue = ReadingStatsStore.rawValue(
            recordingView: article,
            currentRawValue: readingStatsRawValue
        )
    }

    private func saveStoryNote() {
        storyNotesRawValue = StoryNoteStore.rawValue(
            settingNoteText: noteDraft,
            article: article,
            currentRawValue: storyNotesRawValue
        )
        noteDraft = StoryNoteStore.noteText(for: article, rawValue: storyNotesRawValue)
        showNoteStatusMessage(noteDraft.isEmpty ? "Note cleared" : "Note saved on this device")
    }

    private func removeStoryNote() {
        noteDraft = ""
        storyNotesRawValue = StoryNoteStore.rawValue(
            settingNoteText: "",
            article: article,
            currentRawValue: storyNotesRawValue
        )
        showNoteStatusMessage("Note cleared")
    }

    private func showNoteStatusMessage(_ message: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            noteStatusMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.25)) {
                noteStatusMessage = ""
            }
        }
    }

    private func triggerStoryLikeGlow() {
        let nextSavedState = !isLiked
        likedStoryIDsRawValue = LikedStoryStore.rawValue(
            settingLiked: nextSavedState,
            article: article,
            currentRawValue: likedStoryIDsRawValue
        )
        savedStoriesRawValue = SavedStoryStore.rawValue(
            settingSaved: nextSavedState,
            article: article,
            currentRawValue: savedStoriesRawValue
        )
        likeButtonGlowOpacity = 1
        likeButtonGlowRadius = 22
        pageGlowOpacity = 1
        pageGlowRadius = 22

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 1.0)) {
                likeButtonGlowOpacity = 0
                likeButtonGlowRadius = 0
                pageGlowOpacity = 0
                pageGlowRadius = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            likeButtonGlowOpacity = 0
            likeButtonGlowRadius = 0
            pageGlowOpacity = 0
            pageGlowRadius = 0
        }
    }

    private func openOriginalStoryWithGlow() {
        guard article.originalURL != nil else { return }

        readingStatsRawValue = ReadingStatsStore.rawValue(
            recordingOriginalStoryOpen: readingStatsRawValue
        )

        openOriginalButtonGlowOpacity = 1
        openOriginalButtonGlowRadius = 22

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 1.0)) {
                openOriginalButtonGlowOpacity = 0
                openOriginalButtonGlowRadius = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            isShowingOriginalStory = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            openOriginalButtonGlowOpacity = 0
            openOriginalButtonGlowRadius = 0
        }
    }

    @MainActor
    private func createAndSharePositiveCard() {
        guard !isCreatingShareCard else { return }

        isCreatingShareCard = true
        triggerShareButtonGlow()

        let shareText = NutsNewsShareCardRenderer.shareText(article: article, takeaway: briefTakeaway)

        if let image = NutsNewsShareCardRenderer.render(
            article: article,
            whyGood: briefWhyGood,
            takeaway: briefTakeaway,
            moodLabel: primaryMoodLabel
        ) {
            var items: [Any] = [image, shareText]
            if let originalURL = article.originalURL {
                items.append(originalURL)
            }

            shareCardItems = items
            isShowingShareCardSheet = true
        } else {
            shareCardItems = [shareText]
            isShowingShareCardSheet = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isCreatingShareCard = false
        }
    }

    private func triggerListenButtonGlow() {
        listenButtonGlowOpacity = 1
        listenButtonGlowRadius = 22

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 1.0)) {
                listenButtonGlowOpacity = 0
                listenButtonGlowRadius = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            listenButtonGlowOpacity = 0
            listenButtonGlowRadius = 0
        }
    }

    private func triggerShareButtonGlow() {
        shareButtonGlowOpacity = 1
        shareButtonGlowRadius = 22

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 1.0)) {
                shareButtonGlowOpacity = 0
                shareButtonGlowRadius = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            shareButtonGlowOpacity = 0
            shareButtonGlowRadius = 0
        }
    }
}

private struct NutsNewsAudioWaveView: View {
    let isAnimating: Bool
    let isPaused: Bool
    let speechLevel: CGFloat
    let speechFrequency: CGFloat
    let speechSeed: Double

    private let bars: [CGFloat] = [
        0.28, 0.56, 0.38, 0.74, 0.46, 0.92, 0.52, 0.82,
        0.34, 0.68, 0.42, 0.88, 0.60, 0.76, 0.32, 0.70,
        0.50, 0.96, 0.44, 0.78, 0.36, 0.64, 0.58, 0.84,
        0.40, 0.72, 0.48, 0.90
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                HStack(alignment: .center, spacing: 4) {
                    ForEach(bars.indices, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(NutsNewsTheme.buttonGradient)
                            .frame(width: 5, height: barHeight(for: index, time: time))
                            .opacity(isPaused ? 0.46 : 1.0)
                            .shadow(color: NutsNewsTheme.amberHighlight.opacity(isAnimating ? 0.42 : 0.12), radius: isAnimating ? 8 : 3, x: 0, y: 0)
                            .animation(.easeInOut(duration: 0.16), value: isAnimating)
                            .animation(.easeInOut(duration: 0.18), value: isPaused)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if isPaused {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(NutsNewsTheme.buttonText)
                        .frame(width: 58, height: 58)
                        .background(NutsNewsTheme.buttonGradient.opacity(0.94))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: NutsNewsTheme.amberHighlight.opacity(0.42), radius: 16, x: 0, y: 0)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.18), value: isPaused)
            .accessibilityHidden(true)
        }
    }

    private func barHeight(for index: Int, time: TimeInterval) -> CGFloat {
        let baseHeight: CGFloat = 12
        let maxHeight: CGFloat = 84
        let restingHeight = baseHeight + (bars[index] * 14)

        guard isAnimating else {
            return restingHeight
        }

        let liveLevel = max(0.16, min(1.0, speechLevel))
        let liveFrequency = max(0.7, min(2.2, speechFrequency))
        let wordAccent = (sin((speechSeed * 1.37 + Double(index)) * 0.91) + 1) / 2
        let syllablePulse = (sin((speechSeed + Double(index) * 0.31) * 1.84) + 1) / 2
        let phase = time * (4.2 + Double(liveFrequency) * 5.8) + Double(index) * 0.52 + speechSeed * 0.21
        let secondaryPhase = time * (7.4 + Double(liveFrequency) * 3.2) + Double(index) * 0.94
        let wave = (sin(phase) + 1) / 2
        let fastWave = (sin(secondaryPhase) + 1) / 2
        let pulsed = (bars[index] * 0.18)
            + (CGFloat(wave) * 0.42)
            + (CGFloat(fastWave) * 0.18)
            + (CGFloat(wordAccent) * liveLevel * 0.16)
            + (CGFloat(syllablePulse) * liveFrequency * 0.06)
        let clampedPulse = max(0.10, min(1.0, pulsed * (0.72 + liveLevel * 0.56)))
        return baseHeight + (maxHeight - baseHeight) * clampedPulse
    }
}

private struct NutsNewsBriefMetric: View {
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

private struct NutsNewsBriefBullet: View {
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: NutsNewsTheme.spacingS) {
            Circle()
                .fill(NutsNewsTheme.amberHighlight)
                .frame(width: NutsNewsTheme.spacingXS, height: NutsNewsTheme.spacingXS)
                .padding(.top, 7)

            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(NutsNewsTheme.primaryText)

                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct DetailInfoCard<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: label.isEmpty ? 0 : NutsNewsTheme.spacingS) {
            if !label.isEmpty {
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.amber)
                    .textCase(.uppercase)
            }

            content
        }
        .padding(NutsNewsTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutsNewsTheme.cardBackgroundStrong)
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1.25)
        )
        .shadow(color: NutsNewsTheme.amberGlow, radius: NutsNewsTheme.spacingS, x: 0, y: NutsNewsTheme.spacingXS)
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
    }
}

private struct CompactDetailInfoCard<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: label.isEmpty ? 0 : NutsNewsTheme.spacingXS) {
            if !label.isEmpty {
                Text(label)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.amber)
                    .textCase(.uppercase)
            }

            content
        }
        .padding(NutsNewsTheme.spacingS)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutsNewsTheme.cardBackgroundStrong)
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                .stroke(Color.clear, lineWidth: 1)
        )
        .shadow(color: NutsNewsTheme.amberGlow, radius: NutsNewsTheme.spacingXS, x: 0, y: NutsNewsTheme.spacingXXS)
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
    }
}

private struct CategoryBadge: View {
    let title: String

    var body: some View {
        HStack(spacing: NutsNewsTheme.spacingXS) {
            Circle()
                .fill(NutsNewsTheme.amber)
                .frame(width: NutsNewsTheme.spacingXS, height: NutsNewsTheme.spacingXS)

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.secondaryText)
        }
        .padding(.horizontal, NutsNewsTheme.spacingS)
        .padding(.vertical, NutsNewsTheme.chipVerticalPadding)
        .background(NutsNewsTheme.badgeBackground)
        .overlay(
            Capsule()
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 0.75)
        )
        .clipShape(Capsule())
    }
}

#Preview {
    ArticleDetailView(
        article: Article(
            id: "preview",
            title: "A very long positive news headline that should remain fully visible on the native article detail screen without clipping or getting cut off even on smaller iPhone screens",
            summary: "A remarkable environmental milestone is helping restore natural waterways and support healthier ecosystems.",
            originalURL: URL(string: "https://www.nutsnews.com"),
            source: "The Optimist Daily",
            publishedAt: nil,
            createdAt: nil,
            thumbnailURL: nil,
            categories: ["Nature", "Uplifting"]
        )
    )
}
