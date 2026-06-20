//
//  ArticleCardView.swift
//  NutsNews
//

import Foundation
import SwiftUI
import UIKit

struct ArticleCardView: View {
    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue
    @AppStorage(NutsNewsSettings.hapticsEnabledKey) private var hapticsEnabled = NutsNewsSettings.hapticsDefaultEnabled
    @State private var isLiked = false
    @State private var isLikeGlowActive = false
    @State private var hasCompletedLikeGlow = false
    @State private var activeBurstID: UUID?
    @State private var activeLikeAnimationID: UUID?
    @State private var shouldUseThreeTwoThumbnailCrop = false

    let article: Article
    let onReadFullStory: (Article) -> Void
    let onRenderingRejected: (Article) -> Void

    private let imageHeight: CGFloat = 174
    private let cardCornerRadius: CGFloat = 26
    private let imageCornerRadius: CGFloat = 16
    private let wideThumbnailCropAspectRatio: CGFloat = 3.0 / 2.0

    init(
        article: Article,
        onReadFullStory: @escaping (Article) -> Void = { _ in },
        onRenderingRejected: @escaping (Article) -> Void = { _ in }
    ) {
        self.article = article
        self.onReadFullStory = onReadFullStory
        self.onRenderingRejected = onRenderingRejected
    }

    var body: some View {
        visibleCard
            .task(id: article.thumbnailURL) {
                await inspectThumbnailAspectRatio()
            }
    }

    private var visibleCard: some View {
        ZStack(alignment: .bottomTrailing) {
            cardContent

            if let activeBurstID {
                CelebrationBurstView(id: activeBurstID)
                    .padding(.trailing, 22)
                    .padding(.bottom, 26)
                    .zIndex(100)
                    .allowsHitTesting(false)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(NutsNewsTheme.cardBackgroundStrong)
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(activeCardBorderColor, lineWidth: activeCardBorderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .shadow(
            color: activeCardShadowColor,
            radius: activeCardShadowRadius,
            x: 0,
            y: activeCardShadowYOffset
        )
        .contentShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .animation(.easeInOut(duration: 0.25), value: themeRawValue)
        .animation(.easeInOut(duration: 0.28), value: isLikeGlowActive)
        .animation(.easeInOut(duration: 0.35), value: hasCompletedLikeGlow)
    }

    private var activeCardBorderColor: Color {
        hasCompletedLikeGlow ? NutsNewsTheme.likedCardBorder : NutsNewsTheme.cardBorder
    }

    private var activeCardBorderWidth: CGFloat {
        hasCompletedLikeGlow ? 1.7 : 1.25
    }

    private var activeCardShadowColor: Color {
        isLikeGlowActive ? NutsNewsTheme.likedCardGlow : NutsNewsTheme.amberGlow
    }

    private var activeCardShadowRadius: CGFloat {
        isLikeGlowActive ? 34 : 16
    }

    private var activeCardShadowYOffset: CGFloat {
        isLikeGlowActive ? 0 : 8
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            articleImage
            categoryRow
            titleText
            summaryText
            footerRow
        }
    }

    private var titleText: some View {
        Text(article.title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(NutsNewsTheme.primaryText)
            .lineSpacing(2)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var summaryText: some View {
        if !article.summary.isEmpty {
            Text(article.summary)
                .font(.body)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .lineSpacing(3)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var footerRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                HStack {
                    Spacer()
                    readStoryButton
                    Spacer()
                }

                HStack {
                    Spacer()
                    likeButton
                }
            }

            HStack(alignment: .center, spacing: 12) {
                Text(article.displayDate)
                    .font(.caption)
                    .foregroundStyle(NutsNewsTheme.mutedText)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(article.source)
                    .font(.caption)
                    .foregroundStyle(NutsNewsTheme.amberSoft)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.top, 2)
        }
    }

    private var readStoryButton: some View {
        Button {
            onReadFullStory(article)
        } label: {
            Text("Read Story")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.buttonText)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(NutsNewsTheme.buttonGradient)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var likeButton: some View {
        Button {
            triggerLikeAnimation()
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(isLiked ? NutsNewsTheme.likedCardAccent : NutsNewsTheme.amberHighlight)
                .frame(width: 38, height: 38)
                .background(NutsNewsTheme.badgeBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isLiked ? NutsNewsTheme.likedCardBorder : NutsNewsTheme.cardBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isLiked ? "Liked" : "Like story")
    }

    private func triggerLikeAnimation() {
        let animationID = UUID()

        isLiked = true
        hasCompletedLikeGlow = false
        activeLikeAnimationID = animationID
        activeBurstID = animationID
        playLikeHaptic()

        withAnimation(.easeOut(duration: 0.18)) {
            isLikeGlowActive = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard activeLikeAnimationID == animationID else { return }

            withAnimation(.easeInOut(duration: 0.35)) {
                isLikeGlowActive = false
                hasCompletedLikeGlow = true
            }

            activeLikeAnimationID = nil
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.15) {
            guard activeBurstID == animationID else { return }
            activeBurstID = nil
        }
    }

    private func playLikeHaptic() {
        guard hapticsEnabled else { return }

        let impactGenerator = UIImpactFeedbackGenerator(style: .soft)
        impactGenerator.prepare()
        impactGenerator.impactOccurred(intensity: 0.85)
    }

    private func inspectThumbnailAspectRatio() async {
        await MainActor.run {
            shouldUseThreeTwoThumbnailCrop = false
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
                shouldUseThreeTwoThumbnailCrop = shouldCropWideThumbnail
            }
        } catch {
            // Do not block the card on a metadata check failure. AsyncImage can still render it.
        }
    }

    @ViewBuilder
    private var articleImage: some View {
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
                    renderedArticleImage(image)
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
    private func renderedArticleImage(_ image: Image) -> some View {
        if shouldUseThreeTwoThumbnailCrop {
            Color.clear
                .frame(maxWidth: .infinity)
                .aspectRatio(wideThumbnailCropAspectRatio, contentMode: .fit)
                .overlay {
                    image
                        .resizable()
                        .scaledToFill()
                }
                .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous))
                .clipped()
        } else {
            image
                .resizable()
                .scaledToFill()
                .frame(height: imageHeight)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous))
                .clipped()
        }
    }

    @ViewBuilder
    private var imagePlaceholder: some View {
        if shouldUseThreeTwoThumbnailCrop {
            baseImagePlaceholder
                .frame(maxWidth: .infinity)
                .aspectRatio(wideThumbnailCropAspectRatio, contentMode: .fit)
        } else {
            baseImagePlaceholder
                .frame(height: imageHeight)
                .frame(maxWidth: .infinity)
        }
    }

    private var baseImagePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous)
                .fill(NutsNewsTheme.badgeBackground)

            VStack(spacing: 6) {
                Image(systemName: "newspaper")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(NutsNewsTheme.amber)

                Text("NutsNews")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
            }
        }
    }

    @ViewBuilder
    private var categoryRow: some View {
        if !article.categories.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(article.categories.prefix(6).enumerated()), id: \.element) { index, category in
                        CategoryBadge(title: category, dotIndex: index)
                    }
                }
            }
            .frame(height: 30)
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
        }
    }
}


private struct CelebrationBurstView: View {
    let id: UUID
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(CelebrationParticle.defaultParticles) { particle in
                Text(particle.emoji)
                    .font(.system(size: particle.size))
                    .scaleEffect(animate ? particle.endScale : 0.55)
                    .rotationEffect(.degrees(animate ? particle.rotation : 0))
                    .offset(
                        x: animate ? particle.xOffset : 0,
                        y: animate ? particle.yOffset : 0
                    )
                    .opacity(animate ? 0 : 1)
            }
        }
        .frame(width: 1, height: 1)
        .id(id)
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 2.0)) {
                    animate = true
                }
            }
        }
    }
}

private struct CelebrationParticle: Identifiable {
    let id: Int
    let emoji: String
    let xOffset: CGFloat
    let yOffset: CGFloat
    let rotation: Double
    let size: CGFloat
    let endScale: CGFloat

    static let defaultParticles: [CelebrationParticle] = [
        CelebrationParticle(id: 0, emoji: "❤️", xOffset: -38, yOffset: -54, rotation: -16, size: 28, endScale: 1.20),
        CelebrationParticle(id: 1, emoji: "✨", xOffset: -88, yOffset: -76, rotation: 22, size: 28, endScale: 1.35),
        CelebrationParticle(id: 2, emoji: "🎉", xOffset: -136, yOffset: -48, rotation: -28, size: 30, endScale: 1.18),
        CelebrationParticle(id: 3, emoji: "❤️", xOffset: -184, yOffset: -104, rotation: 18, size: 26, endScale: 1.25),
        CelebrationParticle(id: 4, emoji: "✨", xOffset: -232, yOffset: -138, rotation: -12, size: 27, endScale: 1.35),
        CelebrationParticle(id: 5, emoji: "🎉", xOffset: -282, yOffset: -84, rotation: 30, size: 29, endScale: 1.16),
        CelebrationParticle(id: 6, emoji: "❤️", xOffset: -68, yOffset: -152, rotation: 12, size: 25, endScale: 1.18),
        CelebrationParticle(id: 7, emoji: "✨", xOffset: -126, yOffset: -194, rotation: -22, size: 28, endScale: 1.32),
        CelebrationParticle(id: 8, emoji: "🎉", xOffset: -196, yOffset: -226, rotation: 24, size: 30, endScale: 1.18),
        CelebrationParticle(id: 9, emoji: "❤️", xOffset: -254, yOffset: -176, rotation: -18, size: 25, endScale: 1.25),
        CelebrationParticle(id: 10, emoji: "✨", xOffset: -326, yOffset: -142, rotation: 18, size: 28, endScale: 1.35),
        CelebrationParticle(id: 11, emoji: "🎉", xOffset: -362, yOffset: -232, rotation: -32, size: 30, endScale: 1.15),
        CelebrationParticle(id: 12, emoji: "❤️", xOffset: -96, yOffset: -270, rotation: 20, size: 25, endScale: 1.22),
        CelebrationParticle(id: 13, emoji: "✨", xOffset: -168, yOffset: -316, rotation: -18, size: 27, endScale: 1.36),
        CelebrationParticle(id: 14, emoji: "🎉", xOffset: -256, yOffset: -304, rotation: 28, size: 29, endScale: 1.16),
        CelebrationParticle(id: 15, emoji: "❤️", xOffset: -342, yOffset: -342, rotation: -20, size: 25, endScale: 1.24),
        CelebrationParticle(id: 16, emoji: "✨", xOffset: -36, yOffset: -236, rotation: 20, size: 26, endScale: 1.33),
        CelebrationParticle(id: 17, emoji: "🎉", xOffset: -304, yOffset: -32, rotation: -24, size: 28, endScale: 1.18)
    ]
}

private struct CategoryBadge: View {
    let title: String
    let dotIndex: Int

    @AppStorage(NutsNewsTheme.storageKey) private var themeRawValue = NutsNewsTheme.defaultTheme.rawValue

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(NutsNewsTheme.categoryDotColor(index: dotIndex, isSelected: false))
                .frame(width: 6, height: 6)

            Text(title)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(NutsNewsTheme.badgeBackground)
        .overlay(
            Capsule()
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 0.75)
        )
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.25), value: themeRawValue)
    }
}

#Preview {
    ArticleCardView(
        article: Article(
            id: "preview",
            title: "Europe removed a record number of river barriers last year",
            summary: "A remarkable environmental milestone is helping restore natural waterways and support healthier ecosystems. This longer preview text is intentionally shown in full so the card grows naturally instead of clipping the summary.",
            originalURL: URL(string: "https://www.nutsnews.com"),
            source: "The Optimist Daily",
            publishedAt: nil,
            createdAt: nil,
            thumbnailURL: URL(string: "https://www.nutsnews.com/icon.png"),
            categories: ["Nature", "Uplifting"]
        )
    )
    .padding()
    .background(NutsNewsTheme.background)
}
