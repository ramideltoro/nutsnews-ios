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
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        heroImage
                        categoryRow
                        titleSection
                        summarySection
                        sourceSection
                        actionButtons
                    }
                    .padding(16)
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
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
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
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.08))

            VStack(spacing: 10) {
                Image(systemName: "newspaper")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(NutsNewsTheme.amber)

                Text("NutsNews")
                    .font(.headline)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
            }
        }
        .frame(height: 250)
    }

    @ViewBuilder
    private var categoryRow: some View {
        if !article.categories.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(article.categories.prefix(8), id: \.self) { category in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(NutsNewsTheme.amber)
                                .frame(width: 6, height: 6)

                            Text(category)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(NutsNewsTheme.secondaryText)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var titleSection: some View {
        Text(article.title)
            .font(.system(size: 26, weight: .bold, design: .default))
            .foregroundStyle(NutsNewsTheme.primaryText)
            .lineSpacing(3)
            .lineLimit(nil)
            .minimumScaleFactor(0.82)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private var summarySection: some View {
        if !article.summary.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Summary")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.amber)
                    .textCase(.uppercase)

                Text(article.summary)
                    .font(.body)
                    .foregroundStyle(NutsNewsTheme.secondaryText)
                    .lineSpacing(4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(NutsNewsTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Source")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.amber)
                .textCase(.uppercase)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.source)
                        .font(.headline)
                        .foregroundStyle(NutsNewsTheme.primaryText)

                    Text(article.displayDate)
                        .font(.subheadline)
                        .foregroundStyle(NutsNewsTheme.mutedText)
                }

                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutsNewsTheme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                isShowingOriginalStory = true
            } label: {
                HStack {
                    Image(systemName: "safari")
                    Text("Open original story")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(NutsNewsTheme.amber)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(article.originalURL == nil)
            .opacity(article.originalURL == nil ? 0.55 : 1.0)

            if let originalURL = article.originalURL {
                ShareLink(item: originalURL) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share story")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(NutsNewsTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
}

#Preview {
    ArticleDetailView(
        article: Article(
            id: "preview",
            title: "A very long positive news headline that should remain fully visible on the native article detail screen without clipping or getting cut off",
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
