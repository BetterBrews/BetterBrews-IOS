//
//  News.swift
//  AgriMarket
//
//  News and market insights
//

import Foundation

struct NewsArticle: Identifiable, Codable {
    let id: String
    let title: String
    let summary: String
    let content: String
    let source: String
    let author: String?
    let publishedAt: Date
    let imageUrl: String?
    let category: NewsCategory
    let relatedCommodities: [String]
    let sentiment: NewsSentiment
    let tags: [String]
    let url: String

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: publishedAt, relativeTo: Date())
    }
}

enum NewsCategory: String, Codable, CaseIterable {
    case marketAnalysis = "Market Analysis"
    case priceMovement = "Price Movement"
    case weather = "Weather"
    case policy = "Policy & Regulation"
    case trade = "Trade & Export"
    case crop = "Crop Reports"
    case technology = "Technology"
    case sustainability = "Sustainability"

    var icon: String {
        switch self {
        case .marketAnalysis: return "chart.line.uptrend.xyaxis"
        case .priceMovement: return "arrow.up.arrow.down"
        case .weather: return "cloud.sun.fill"
        case .policy: return "building.columns.fill"
        case .trade: return "globe.americas.fill"
        case .crop: return "leaf.fill"
        case .technology: return "cpu"
        case .sustainability: return "leaf.circle.fill"
        }
    }
}

enum NewsSentiment: String, Codable {
    case bullish = "Bullish"
    case bearish = "Bearish"
    case neutral = "Neutral"

    var color: String {
        switch self {
        case .bullish: return "green"
        case .bearish: return "red"
        case .neutral: return "gray"
        }
    }

    var icon: String {
        switch self {
        case .bullish: return "arrow.up.circle.fill"
        case .bearish: return "arrow.down.circle.fill"
        case .neutral: return "minus.circle.fill"
        }
    }
}

struct MarketInsight: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: InsightType
    let priority: InsightPriority
    let commodities: [String]
    let createdAt: Date
    let expiresAt: Date?
    let actionable: Bool
    let recommendations: [String]

    enum InsightType: String, Codable {
        case opportunity = "Opportunity"
        case risk = "Risk"
        case trend = "Trend"
        case alert = "Alert"

        var icon: String {
            switch self {
            case .opportunity: return "arrow.up.right.circle.fill"
            case .risk: return "exclamationmark.triangle.fill"
            case .trend: return "chart.line.uptrend.xyaxis"
            case .alert: return "bell.fill"
            }
        }
    }

    enum InsightPriority: String, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"

        var color: String {
            switch self {
            case .low: return "gray"
            case .medium: return "blue"
            case .high: return "orange"
            case .critical: return "red"
            }
        }
    }
}

// MARK: - Sample Data
extension NewsArticle {
    static let sampleData: [NewsArticle] = [
        NewsArticle(
            id: UUID().uuidString,
            title: "Corn Prices Surge on Strong Export Demand",
            summary: "U.S. corn futures jumped 2% as export demand from China continues to outpace expectations.",
            content: "Corn futures at the Chicago Board of Trade rose sharply today, driven by robust export demand from China and concerns about dry weather in key growing regions. Market analysts suggest this trend could continue through Q1 2025...",
            source: "AgriMarket News",
            author: "Sarah Johnson",
            publishedAt: Date().addingTimeInterval(-3600),
            imageUrl: nil,
            category: .priceMovement,
            relatedCommodities: ["CORN"],
            sentiment: .bullish,
            tags: ["Corn", "Exports", "China", "Futures"],
            url: "https://example.com/news/1"
        ),
        NewsArticle(
            id: UUID().uuidString,
            title: "Drought Conditions Threaten Brazil's Soybean Crop",
            summary: "Meteorologists warn that continued dry weather in Brazil could reduce this year's soybean harvest by up to 15%.",
            content: "Weather forecasters are sounding alarms over persistent drought conditions in Brazil's key soybean-producing regions. The lack of rainfall during the critical growing period could significantly impact yields...",
            source: "Global Ag Watch",
            author: "Miguel Santos",
            publishedAt: Date().addingTimeInterval(-7200),
            imageUrl: nil,
            category: .weather,
            relatedCommodities: ["SOYBEANS"],
            sentiment: .bearish,
            tags: ["Soybeans", "Brazil", "Weather", "Drought"],
            url: "https://example.com/news/2"
        ),
        NewsArticle(
            id: UUID().uuidString,
            title: "Coffee Markets Rally on Vietnam Supply Concerns",
            summary: "Arabica coffee prices hit 6-month highs as heavy rains in Vietnam disrupt robusta production.",
            content: "Coffee traders are closely watching weather patterns in Vietnam, the world's largest robusta producer. Unseasonable heavy rains have damaged crops and complicated harvesting operations...",
            source: "Commodity Pulse",
            author: "Emily Chen",
            publishedAt: Date().addingTimeInterval(-10800),
            imageUrl: nil,
            category: .priceMovement,
            relatedCommodities: ["COFFEE"],
            sentiment: .bullish,
            tags: ["Coffee", "Vietnam", "Supply", "Weather"],
            url: "https://example.com/news/3"
        ),
        NewsArticle(
            id: UUID().uuidString,
            title: "New EU Regulations Impact Agricultural Trade",
            summary: "The European Union announces stricter sustainability requirements for imported agricultural commodities.",
            content: "The European Commission has unveiled new regulations requiring detailed sustainability certifications for all agricultural imports. The policy, set to take effect in 2026, aims to reduce deforestation...",
            source: "Trade Policy Monitor",
            author: "Hans Weber",
            publishedAt: Date().addingTimeInterval(-14400),
            imageUrl: nil,
            category: .policy,
            relatedCommodities: ["SOYBEANS", "COFFEE", "COTTON"],
            sentiment: .neutral,
            tags: ["EU", "Policy", "Sustainability", "Trade"],
            url: "https://example.com/news/4"
        )
    ]
}

extension MarketInsight {
    static let sampleData: [MarketInsight] = [
        MarketInsight(
            id: UUID().uuidString,
            title: "Strong Buying Opportunity in Wheat Futures",
            description: "Technical analysis indicates wheat futures are oversold with strong support at $640/bushel.",
            type: .opportunity,
            priority: .high,
            commodities: ["WHEAT"],
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(86400 * 7),
            actionable: true,
            recommendations: [
                "Consider long positions at current levels",
                "Set stop loss at $635",
                "Target price: $670-$680"
            ]
        ),
        MarketInsight(
            id: UUID().uuidString,
            title: "Weather Risk Building in Corn Belt",
            description: "Extended forecast shows potential for frost events in key growing regions next week.",
            type: .risk,
            priority: .critical,
            commodities: ["CORN", "SOYBEANS"],
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(86400 * 3),
            actionable: true,
            recommendations: [
                "Monitor weather forecasts closely",
                "Consider hedging strategies",
                "Review crop insurance coverage"
            ]
        )
    ]
}
