//
//  ArticleCardView.swift
//  NutsNews
//

import SwiftUI

struct ArticleCardView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            articleImage

            categoryRow

            Text(article.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(NutsNewsTheme.primaryText)
                .lineSpacing(2)

            if !article.summary.isEmpty {
                Text(article.summary)
                    .font(.body)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .lineSpacing(3)
            }

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.displayDate)
                        .font(.caption)
                        .foregroundStyle(NutsNewsTheme.mutedText)

                    Text(article.source)
                        .font(.caption)
                        .foregroundStyle(NutsNewsTheme.amberSoft)
                }

                Spacer()

                if let originalURL = article.originalURL {
                    Link(destination: originalURL) {
                        Text("Read full story")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(NutsNewsTheme.amber)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(NutsNewsTheme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
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
                        .frame(height: 190)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
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
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.08))

            VStack(spacing: 8) {
                Image(systemName: "newspaper")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(NutsNewsTheme.amber)

                Text("NutsNews")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
            }
        }
        .frame(height: 190)
    }

    @ViewBuilder
    private var categoryRow: some View {
        if !article.categories.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(article.categories.prefix(6), id: \.self) { category in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(NutsNewsTheme.amber)
                                .frame(width: 6, height: 6)

                            Text(category)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(NutsNewsTheme.secondaryText)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                    }
                }
            }
        }
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
