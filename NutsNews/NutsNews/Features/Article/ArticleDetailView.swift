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
    @State private var pageGlowOpacity = 0.0
    @State private var pageGlowRadius: CGFloat = 0
    @State private var openOriginalButtonGlowOpacity = 0.0
    @State private var openOriginalButtonGlowRadius: CGFloat = 0
    @State private var shareButtonGlowOpacity = 0.0
    @State private var shareButtonGlowRadius: CGFloat = 0
    @State private var likeButtonGlowOpacity = 0.0
    @State private var likeButtonGlowRadius: CGFloat = 0

    private let wideThumbnailCropAspectRatio: CGFloat = 3.0 / 2.0

    private var isLiked: Bool {
        LikedStoryStore.isLiked(article, rawValue: likedStoryIDsRawValue)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NutsNewsTheme.background
                    .overlay(NutsNewsTheme.backgroundOverlay)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
                        heroImage
                        categoryRow
                        titleSection
                        summarySection
                        sourceSection
                        actionButtons
                    }
                    .padding(NutsNewsTheme.spacingM)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: NutsNewsTheme.amberHighlight.opacity(pageGlowOpacity * 0.58), radius: pageGlowRadius, x: 0, y: 0)
                    .shadow(color: NutsNewsTheme.amberGlow.opacity(pageGlowOpacity * 0.45), radius: pageGlowRadius * 1.5, x: 0, y: 0)
                }
            }
            .navigationTitle("Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    closeButton
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    storyLikeButton
                }
            }
            .animation(.easeInOut(duration: 0.25), value: themeRawValue)
            .sheet(isPresented: $isShowingOriginalStory) {
                if let originalURL = article.originalURL {
                    SafariView(url: originalURL)
                        .ignoresSafeArea()
                }
            }
            .task(id: article.thumbnailURL) {
                await inspectHeroThumbnailAspectRatio()
            }
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

    private var actionButtons: some View {
        VStack(spacing: NutsNewsTheme.spacingS) {
            Button {
                openOriginalStoryWithGlow()
            } label: {
                HStack(spacing: NutsNewsTheme.spacingXS) {
                    Image(systemName: "safari")
                    Text("Open original story")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.buttonText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(NutsNewsTheme.buttonGradient)
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

            if let originalURL = article.originalURL {
                ShareLink(item: originalURL) {
                    HStack(spacing: NutsNewsTheme.spacingXS) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share story")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(NutsNewsTheme.badgeBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                            .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous)
                            .stroke(NutsNewsTheme.amberHighlight.opacity(shareButtonGlowOpacity * 0.86), lineWidth: 2)
                            .blur(radius: shareButtonGlowRadius * 0.16)
                    )
                    .shadow(color: NutsNewsTheme.amberHighlight.opacity(shareButtonGlowOpacity * 0.72), radius: shareButtonGlowRadius, x: 0, y: 0)
                    .shadow(color: NutsNewsTheme.amberGlow.opacity(shareButtonGlowOpacity * 0.55), radius: shareButtonGlowRadius * 1.45, x: 0, y: 0)
                    .scaleEffect(1 + (shareButtonGlowOpacity * 0.03))
                    .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                }
                .simultaneousGesture(TapGesture().onEnded {
                    triggerShareButtonGlow()
                })
            }
        }
    }

    private var closeButton: some View {
        Button("Close") {
            dismiss()
        }
        .foregroundStyle(NutsNewsTheme.amber)
        .shadow(color: NutsNewsTheme.amberHighlight.opacity(pageGlowOpacity * 0.64), radius: pageGlowRadius, x: 0, y: 0)
    }

    private var storyLikeButton: some View {
        Button {
            triggerStoryLikeGlow()
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(isLiked ? NutsNewsTheme.likedCardAccent : NutsNewsTheme.amberHighlight)
                .frame(width: 34, height: 34)
                .background(NutsNewsTheme.badgeBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isLiked ? NutsNewsTheme.likedCardBorder : NutsNewsTheme.cardBorder, lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .stroke(NutsNewsTheme.amberHighlight.opacity(likeButtonGlowOpacity * 0.86), lineWidth: 2)
                        .blur(radius: likeButtonGlowRadius * 0.16)
                )
                .shadow(color: NutsNewsTheme.amberHighlight.opacity(likeButtonGlowOpacity * 0.72), radius: likeButtonGlowRadius, x: 0, y: 0)
                .shadow(color: NutsNewsTheme.amberGlow.opacity(likeButtonGlowOpacity * 0.55), radius: likeButtonGlowRadius * 1.45, x: 0, y: 0)
                .scaleEffect(1 + (likeButtonGlowOpacity * 0.035))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isLiked ? "Liked" : "Like story")
    }

    private func triggerStoryLikeGlow() {
        likedStoryIDsRawValue = LikedStoryStore.rawValue(
            settingLiked: !isLiked,
            article: article,
            currentRawValue: likedStoryIDsRawValue
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

private struct DetailInfoCard<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.amber)
                .textCase(.uppercase)

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
