//
//  NewsDetailView.swift
//  AgriMarket
//
//  Detailed news article view
//

import SwiftUI

struct NewsDetailView: View {
    let article: NewsArticle
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    // Category and Sentiment
                    HStack {
                        Label(article.category.rawValue, systemImage: article.category.icon)
                            .font(.subheadline)
                            .foregroundColor(.green)

                        Spacer()

                        HStack(spacing: 6) {
                            Image(systemName: article.sentiment.icon)
                            Text(article.sentiment.rawValue)
                        }
                        .font(.subheadline)
                        .foregroundColor(Color(article.sentiment.color))
                    }

                    // Title
                    Text(article.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    // Metadata
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(article.source)
                                .fontWeight(.medium)
                            if let author = article.author {
                                Text("•")
                                Text(author)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                        Text(article.publishedAt.formatted(date: .long, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                // Summary
                Text(article.summary)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                // Content
                Text(article.content)
                    .font(.body)
                    .lineSpacing(6)

                // Related Commodities
                if !article.relatedCommodities.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Related Commodities")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(article.relatedCommodities, id: \.self) { commodityId in
                                    NavigationLink(destination: CommodityDetailView(commodityId: commodityId)) {
                                        CommodityTagView(commodityId: commodityId)
                                    }
                                }
                            }
                        }
                    }
                }

                // Tags
                if !article.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.headline)

                        FlowLayout(spacing: 8) {
                            ForEach(article.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

// MARK: - Commodity Tag View
struct CommodityTagView: View {
    let commodityId: String

    var body: some View {
        HStack {
            Image(systemName: "leaf.fill")
                .foregroundColor(.green)
            Text(commodityId)
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    NavigationView {
        NewsDetailView(article: NewsArticle.sampleData[0])
    }
}
