//
//  DashboardViewModel.swift
//  AgriMarket
//
//  ViewModel for Dashboard
//

import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var topCommodities: [Commodity] = []
    @Published var marketInsights: [MarketInsight] = []
    @Published var recentNews: [NewsArticle] = []
    @Published var weatherAlerts: [WeatherAlert] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let commodityService = CommodityService.shared
    private let newsService = NewsService.shared
    private let weatherService = WeatherService.shared

    func loadDashboardData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let commodities = commodityService.fetchCommodities()
            async let insights = newsService.fetchMarketInsights(priority: .high)
            async let news = newsService.fetchNews(limit: 5)
            async let alerts = weatherService.fetchWeatherAlerts()

            let (loadedCommodities, loadedInsights, loadedNews, loadedAlerts) = try await (commodities, insights, news, alerts)

            topCommodities = Array(loadedCommodities.prefix(6))
            marketInsights = loadedInsights
            recentNews = loadedNews
            weatherAlerts = loadedAlerts
        } catch {
            errorMessage = "Failed to load dashboard data: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func refreshData() async {
        await loadDashboardData()
    }
}
