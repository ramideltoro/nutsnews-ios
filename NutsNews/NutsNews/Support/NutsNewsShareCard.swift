//
//  NutsNewsShareCard.swift
//  NutsNews
//

import SwiftUI
import UIKit

struct NutsNewsActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

@MainActor
enum NutsNewsShareCardRenderer {
    static func render(
        article: Article,
        whyGood: String,
        takeaway: String,
        moodLabel: String
    ) -> UIImage? {
        let card = NutsNewsShareCardView(
            article: article,
            whyGood: whyGood,
            takeaway: takeaway,
            moodLabel: moodLabel
        )
        .frame(width: 1080, height: 1350)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 1
        renderer.proposedSize = ProposedViewSize(width: 1080, height: 1350)
        return renderer.uiImage
    }

    static func shareText(article: Article, takeaway: String) -> String {
        var lines = [
            "A good-news moment from NutsNews:",
            article.title,
            "Takeaway: \(takeaway)",
            "Source: \(article.source)"
        ]

        if let originalURL = article.originalURL?.absoluteString {
            lines.append(originalURL)
        }

        return lines.joined(separator: "\n")
    }
}

struct NutsNewsShareCardMiniPreview: View {
    let article: Article
    let takeaway: String
    let moodLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: NutsNewsTheme.spacingS) {
            HStack(spacing: NutsNewsTheme.spacingXS) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .bold))
                Text("NutsNews share card")
                    .font(.caption)
                    .fontWeight(.bold)
                    .textCase(.uppercase)
            }
            .foregroundStyle(NutsNewsTheme.amber)

            Text(article.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(NutsNewsTheme.primaryText)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Text(takeaway)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(NutsNewsTheme.secondaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: NutsNewsTheme.spacingXS) {
                Label(moodLabel, systemImage: "heart.text.square.fill")
                Spacer(minLength: NutsNewsTheme.spacingXS)
                Text(article.source)
                    .lineLimit(1)
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(NutsNewsTheme.mutedText)
        }
        .padding(NutsNewsTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    NutsNewsTheme.cardBackgroundStrong,
                    NutsNewsTheme.badgeBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous)
                .stroke(NutsNewsTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: NutsNewsTheme.cardCornerRadius, style: .continuous))
    }
}

struct NutsNewsShareCardView: View {
    let article: Article
    let whyGood: String
    let takeaway: String
    let moodLabel: String

    private let darkBackground = Color(red: 0.055, green: 0.043, blue: 0.025)
    private let cardSurface = Color(red: 0.12, green: 0.09, blue: 0.04)
    private let warmAmber = Color(red: 1.0, green: 0.72, blue: 0.16)
    private let softAmber = Color(red: 1.0, green: 0.87, blue: 0.49)
    private let primaryText = Color(red: 1.0, green: 0.96, blue: 0.86)
    private let secondaryText = Color(red: 0.88, green: 0.78, blue: 0.62)

    var body: some View {
        ZStack {
            background

            VStack(alignment: .leading, spacing: 34) {
                header
                titleBlock
                whyGoodBlock
                takeawayBlock
                Spacer(minLength: 0)
                footer
            }
            .padding(76)
        }
        .frame(width: 1080, height: 1350)
        .clipped()
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [darkBackground, Color(red: 0.11, green: 0.075, blue: 0.025), darkBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(warmAmber.opacity(0.24))
                .frame(width: 520, height: 520)
                .blur(radius: 80)
                .offset(x: 390, y: -520)

            Circle()
                .fill(softAmber.opacity(0.14))
                .frame(width: 460, height: 460)
                .blur(radius: 70)
                .offset(x: -420, y: 500)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 24) {
            ZStack {
                Circle()
                    .fill(warmAmber)
                    .frame(width: 78, height: 78)
                    .shadow(color: warmAmber.opacity(0.42), radius: 24, x: 0, y: 0)

                Text("N")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(darkBackground)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("NutsNews")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(primaryText)

                Text("Positive news, simplified")
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                    .foregroundStyle(secondaryText)
            }

            Spacer(minLength: 0)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 14) {
                Label(moodLabel, systemImage: "heart.text.square.fill")
                Label(estimatedReadTime, systemImage: "clock.fill")
            }
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(softAmber)

            Text(article.title)
                .font(.system(size: 62, weight: .black, design: .rounded))
                .foregroundStyle(primaryText)
                .lineSpacing(4)
                .minimumScaleFactor(0.70)
                .lineLimit(7)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var whyGoodBlock: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Why it’s good news")
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundStyle(warmAmber)
                .textCase(.uppercase)

            Text(whyGood)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundStyle(secondaryText)
                .lineSpacing(5)
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(34)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardSurface.opacity(0.88))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(warmAmber.opacity(0.28), lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }

    private var takeawayBlock: some View {
        HStack(alignment: .top, spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 42, weight: .black))
                .foregroundStyle(warmAmber)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 12) {
                Text("Feel-good takeaway")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(warmAmber)
                    .textCase(.uppercase)

                Text(takeaway)
                    .font(.system(size: 43, weight: .black, design: .rounded))
                    .foregroundStyle(primaryText)
                    .lineSpacing(4)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 16) {
            Rectangle()
                .fill(warmAmber.opacity(0.28))
                .frame(height: 2)

            HStack(alignment: .center, spacing: 16) {
                Text(article.source)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryText)
                    .lineLimit(1)

                Circle()
                    .fill(warmAmber)
                    .frame(width: 8, height: 8)

                Text(article.displayDate)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(secondaryText)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text("nutsnews.com")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(warmAmber)
            }
        }
    }

    private var estimatedReadTime: String {
        let wordCount = "\(article.title) \(article.summary)"
            .split { $0.isWhitespace || $0.isNewline }
            .count
        let minutes = max(1, Int(ceil(Double(wordCount) / 180.0)))
        return "\(minutes) min"
    }
}
