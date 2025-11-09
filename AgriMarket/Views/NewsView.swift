//
//  NewsView.swift
//  AgriMarket
//
//  News and market insights
//

import SwiftUI

struct NewsView: View {
    @State private var news: [NewsArticle] = []
    @State private var selectedCategory: NewsCategory?
    @State private var searchText = ""
    @State private var isLoading = false

    var filteredNews: [NewsArticle] {
        var result = news

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.summary.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar

                // Category Filter
                categoryFilter

                // News List
                if isLoading && news.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if filteredNews.isEmpty {
                    emptyState
                } else {
                    newsList
                }
            }
            .navigationTitle("News & Insights")
            .task {
                await loadNews()
            }
            .refreshable {
                await loadNews()
            }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search news...", text: $searchText)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding()
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterButton(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(NewsCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    // MARK: - News List
    private var newsList: some View {
        List(filteredNews) { article in
            NavigationLink(destination: NewsDetailView(article: article)) {
                NewsListItemView(article: article)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No news found")
                .font(.headline)
            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    // MARK: - Load News
    private func loadNews() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        news = NewsArticle.sampleData
        isLoading = false
    }
}

// MARK: - News List Item View
struct NewsListItemView: View {
    let article: NewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with category and sentiment
            HStack {
                Label(article.category.rawValue, systemImage: article.category.icon)
                    .font(.caption)
                    .foregroundColor(.green)

                Spacer()

                Image(systemName: article.sentiment.icon)
                    .font(.caption)
                    .foregroundColor(Color(article.sentiment.color))
            }

            // Title
            Text(article.title)
                .font(.headline)
                .lineLimit(2)

            // Summary
            Text(article.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)

            // Footer with source and date
            HStack {
                Text(article.source)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("•")
                    .foregroundColor(.secondary)
                Text(article.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Related commodities tags
            if !article.relatedCommodities.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(article.relatedCommodities, id: \.self) { commodity in
                            Text(commodity)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NewsView()
}
