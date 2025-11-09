//
//  NewsService.swift
//  AgriMarket
//
//  Service for news and market insights
//

import Foundation

class NewsService {
    static let shared = NewsService()
    private let networkManager = NetworkManager.shared

    private init() {}

    // MARK: - Fetch News
    func fetchNews(
        category: NewsCategory? = nil,
        commodityId: String? = nil,
        limit: Int = 20
    ) async throws -> [NewsArticle] {
        try await Task.sleep(nanoseconds: 400_000_000)

        var news = NewsArticle.sampleData

        if let category = category {
            news = news.filter { $0.category == category }
        }

        if let commodityId = commodityId {
            news = news.filter { $0.relatedCommodities.contains(commodityId) }
        }

        return Array(news.prefix(limit))
    }

    func fetchArticle(id: String) async throws -> NewsArticle {
        try await Task.sleep(nanoseconds: 200_000_000)
        guard let article = NewsArticle.sampleData.first(where: { $0.id == id }) else {
            throw NetworkError.notFound
        }
        return article
    }

    // MARK: - Fetch Market Insights
    func fetchMarketInsights(
        priority: MarketInsight.InsightPriority? = nil,
        commodityId: String? = nil
    ) async throws -> [MarketInsight] {
        try await Task.sleep(nanoseconds: 300_000_000)

        var insights = MarketInsight.sampleData

        if let priority = priority {
            insights = insights.filter { $0.priority == priority }
        }

        if let commodityId = commodityId {
            insights = insights.filter { $0.commodities.contains(commodityId) }
        }

        return insights
    }

    // MARK: - Search News
    func searchNews(query: String) async throws -> [NewsArticle] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return NewsArticle.sampleData.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.summary.localizedCaseInsensitiveContains(query) ||
            $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(query) })
        }
    }

    // MARK: - Trending Topics
    func fetchTrendingTopics() async throws -> [String] {
        try await Task.sleep(nanoseconds: 200_000_000)
        return [
            "Corn Exports",
            "Brazil Weather",
            "China Demand",
            "EU Regulations",
            "Fertilizer Prices",
            "Drought Conditions",
            "Trade Policy"
        ]
    }
}
