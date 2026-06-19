//
//  ArticleCardView.swift
//  NutsNews
//

import SwiftUI

struct ArticleCardView: View {
    let article: Article
    let onReadFullStory: (Article) -> Void

    init(
        article: Article,
        onReadFullStory: @escaping (Article) -> Void = { _ in }
    ) {
        self.article = article
        self.onReadFullStory = onReadFullStory
    }

    var body: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingM) {
            articleImage
            categoryRow
            titleText
            summaryText
            footerRow
        }
        .padding(NutsNewsTheme.cardPadding)
        .background(NutsNewsTheme.cardBackgroundStrong)
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1.25)
        )
        .shadow(color: NutsNewsTheme.amberGlow, radius: NutsNewsTheme.spacingM, x: 0, y: NutsNewsTheme.spacingXS)
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
        .onTapGesture {
            onReadFullStory(article)
        }
    }

    private var titleText: some View {
        Text(article.title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(NutsNewsTheme.primaryText)
            .lineSpacing(NutsNewsTheme.spacingXXS)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var summaryText: some View {
        if !article.summary.isEmpty {
            Text(article.summary)
                .font(.body)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .lineSpacing(NutsNewsTheme.spacingXXS)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var footerRow: some View {
        HStack(alignment: .center, spacing: NutsNewsTheme.spacingM) {
            VStack(alignment: .leading, spacing: NutsNewsTheme.spacingXXS) {
                Text(article.displayDate)
                    .font(.caption)
                    .foregroundStyle(NutsNewsTheme.mutedText)

                Text(article.source)
                    .font(.caption)
                    .foregroundStyle(NutsNewsTheme.amberSoft)
            }

            Spacer()

            Button {
                onReadFullStory(article)
            } label: {
                Text("Read story")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.buttonText)
                    .padding(.horizontal, NutsNewsTheme.chipHorizontalPadding)
                    .padding(.vertical, NutsNewsTheme.chipVerticalPadding)
                    .background(NutsNewsTheme.buttonGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
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
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: NutsNewsTheme.feedImageHeight)
                        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.imageCornerRadius, style: .continuous))
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
            RoundedRectangle(cornerRadius: NutsNewsTheme.imageCornerRadius, style: .continuous)
                .fill(NutsNewsTheme.badgeBackground)

            VStack(spacing: NutsNewsTheme.spacingXS) {
                Image(systemName: "newspaper")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(NutsNewsTheme.amber)

                Text("NutsNews")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
            }
        }
        .frame(height: NutsNewsTheme.feedImageHeight)
    }

    @ViewBuilder
    private var categoryRow: some View {
        if !article.categories.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: NutsNewsTheme.spacingXS) {
                    ForEach(article.categories.prefix(6), id: \.self) { category in
                        CategoryBadge(title: category)
                    }
                }
            }
        }
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
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.secondaryText)
        }
        .padding(.horizontal, NutsNewsTheme.spacingS)
        .padding(.vertical, NutsNewsTheme.spacingXS)
        .background(NutsNewsTheme.badgeBackground)
        .overlay(
            Capsule()
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 0.75)
        )
        .clipShape(Capsule())
    }
}

#Preview {
    ArticleCardView(
        article: Article(
            id: "preview",
            title: "Europe removed a record number of river barriers last year",
            summary: "A remarkable environmental milestone is helping restore natural waterways and support healthier ecosystems.",
            originalURL: URL(string: "https://www.nutsnews.com"),
            source: "The Optimist Daily",
            publishedAt: nil,
            createdAt: nil,
            thumbnailURL: nil,
            categories: ["Nature", "Uplifting"]
        )
    )
    .padding()
    .background(NutsNewsTheme.background)
}
