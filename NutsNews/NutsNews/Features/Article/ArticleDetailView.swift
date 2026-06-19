//
//  ArticleDetailView.swift
//  NutsNews
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article

    @Environment(\.dismiss) private var dismiss
    @State private var isShowingOriginalStory = false

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
                }
            }
            .navigationTitle("Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(NutsNewsTheme.amber)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if let originalURL = article.originalURL {
                        ShareLink(item: originalURL) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(NutsNewsTheme.amber)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingOriginalStory) {
                if let originalURL = article.originalURL {
                    SafariView(url: originalURL)
                        .ignoresSafeArea()
                }
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
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: NutsNewsTheme.detailHeroHeight)
                        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
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
        ZStack {
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .fill(NutsNewsTheme.badgeBackground)

            VStack(spacing: NutsNewsTheme.spacingS) {
                Image(systemName: "newspaper")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(NutsNewsTheme.amber)

                Text("NutsNews")
                    .font(.headline)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
            }
        }
        .frame(height: NutsNewsTheme.detailHeroHeight)
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
                isShowingOriginalStory = true
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
            }
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
                    .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.controlCornerRadius, style: .continuous))
                }
            }
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
