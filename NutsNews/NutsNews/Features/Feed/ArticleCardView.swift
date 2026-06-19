//
//  ArticleCardView.swift
//  NutsNews
//

import SwiftUI

struct ArticleCardView: View {
    let article: Article
    let onReadFullStory: (Article) -> Void

    private let imageHeight: CGFloat = 174
    private let cardCornerRadius: CGFloat = 26
    private let imageCornerRadius: CGFloat = 16

    init(
        article: Article,
        onReadFullStory: @escaping (Article) -> Void = { _ in }
    ) {
        self.article = article
        self.onReadFullStory = onReadFullStory
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            articleImage
            categoryRow
            titleText
            summaryText
            footerRow
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(NutsNewsTheme.cardBackgroundStrong)
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1.25)
        )
        .shadow(color: NutsNewsTheme.amberGlow, radius: 16, x: 0, y: 8)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .onTapGesture {
            onReadFullStory(article)
        }
    }

    private var titleText: some View {
        Text(article.title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(NutsNewsTheme.primaryText)
            .lineSpacing(2)
            .lineLimit(nil)
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
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var footerRow: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(article.displayDate)
                    .font(.caption)
                    .foregroundStyle(NutsNewsTheme.mutedText)
                    .lineLimit(1)

                Text(article.source)
                    .font(.caption)
                    .foregroundStyle(NutsNewsTheme.amberSoft)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                onReadFullStory(article)
            } label: {
                Text("Read story")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.buttonText)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 8)
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
                        .frame(height: imageHeight)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous))
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
        .frame(height: imageHeight)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var categoryRow: some View {
        if !article.categories.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(article.categories.prefix(6), id: \.self) { category in
                        CategoryBadge(title: category)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct CategoryBadge: View {
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(NutsNewsTheme.amber)
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
            thumbnailURL: nil,
            categories: ["Nature", "Uplifting"]
        )
    )
    .padding()
    .background(NutsNewsTheme.background)
}
