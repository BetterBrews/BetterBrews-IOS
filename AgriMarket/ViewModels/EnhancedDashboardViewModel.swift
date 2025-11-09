//
//  EnhancedDashboardViewModel.swift
//  AgriMarket
//
//  Enhanced dashboard with real data, loading states, and error handling
//

import Foundation
import Combine

@MainActor
class EnhancedDashboardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var commodities: [Commodity] = []
    @Published var news: [NewsArticle] = []
    @Published var weatherData: [WeatherData] = []
    @Published var marketInsights: [MarketInsight] = []
    @Published var weatherAlerts: [WeatherAlert] = []

    // Loading states
    @Published var isLoadingCommodities = false
    @Published var isLoadingNews = false
    @Published var isLoadingWeather = false
    @Published var isRefreshing = false

    // Error states
    @Published var commoditiesError: String?
    @Published var newsError: String?
    @Published var weatherError: String?

    // Statistics
    @Published var marketStats: DashboardStats?

    // Services
    private let apiManager = APIManager.shared
    private let repository = CommodityRepository.shared
    private let newsRepository = NewsRepository.shared
    private let weatherRepository = WeatherRepository.shared

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        setupObservers()
    }

    private func setupObservers() {
        // Observe API status changes
        apiManager.$isOnline
            .sink { [weak self] isOnline in
                if !isOnline {
                    self?.loadFromCache()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Loading

    func loadDashboard() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadCommodities() }
            group.addTask { await self.loadNews() }
            group.addTask { await self.loadWeather() }
            group.addTask { await self.loadInsights() }
        }

        calculateStats()
    }

    func refreshDashboard() async {
        isRefreshing = true
        await loadDashboard()
        isRefreshing = false
    }

    // MARK: - Commodities

    private func loadCommodities() async {
        isLoadingCommodities = true
        commoditiesError = nil

        do {
            // Try to fetch from API
            if apiManager.isOnline {
                let symbols = ["CORN", "WHEAT", "SOYB", "GC", "SI", "CL"]
                let prices = try await apiManager.fetchCommodityPrices(symbols: symbols)

                // Convert to Commodity models
                commodities = prices.map { price in
                    Commodity(
                        id: price.symbol,
                        name: price.name,
                        symbol: price.symbol,
                        category: determineCommodityCategory(price.symbol),
                        description: "\(price.name) commodity",
                        unit: .metricTon,
                        currentPrice: price.price,
                        previousClose: price.price - price.change,
                        dayChange: price.change,
                        dayChangePercent: price.changePercent,
                        volume: price.volume,
                        marketCap: nil,
                        lastUpdated: price.timestamp,
                        origins: [],
                        destinations: []
                    )
                }

                // Save to repository
                try await repository.saveCommodities(commodities)
            } else {
                // Load from cache
                commodities = try await repository.fetchAllCommodities()
            }

        } catch let error as APIError {
            commoditiesError = error.errorDescription
            // Fallback to cached data
            commodities = (try? await repository.fetchAllCommodities()) ?? []
        } catch {
            commoditiesError = "Failed to load commodities: \(error.localizedDescription)"
            commodities = (try? await repository.fetchAllCommodities()) ?? []
        }

        isLoadingCommodities = false
    }

    // MARK: - News

    private func loadNews() async {
        isLoadingNews = true
        newsError = nil

        do {
            if apiManager.isOnline {
                let newsItems = try await apiManager.fetchNews(query: "agriculture commodities", pageSize: 20)

                // Convert to NewsArticle models
                news = newsItems.map { item in
                    NewsArticle(
                        id: UUID().uuidString,
                        title: item.title,
                        summary: item.description,
                        content: item.description,
                        source: item.source,
                        author: nil,
                        publishedAt: item.publishedAt,
                        imageUrl: item.imageUrl,
                        category: .marketAnalysis,
                        relatedCommodities: [],
                        sentiment: determineSentiment(item.title),
                        tags: extractTags(item.title),
                        url: item.url
                    )
                }

                // Save to repository
                for article in news.prefix(10) {
                    // Save to CoreData through repository
                }
            } else {
                news = (try? await newsRepository.fetchAllNews(limit: 20)) ?? []
            }

        } catch {
            newsError = "Failed to load news: \(error.localizedDescription)"
            news = (try? await newsRepository.fetchAllNews(limit: 20)) ?? []
        }

        isLoadingNews = false
    }

    // MARK: - Weather

    private func loadWeather() async {
        isLoadingWeather = true
        weatherError = nil

        do {
            if apiManager.isOnline {
                let locations = ["Chicago", "Des Moines", "São Paulo", "Buenos Aires", "Paris"]
                let weatherInfos = try await apiManager.fetchWeather(locations: locations)

                // Convert to WeatherData models
                weatherData = weatherInfos.map { info in
                    WeatherData(
                        id: UUID().uuidString,
                        location: Location(latitude: 0, longitude: 0, name: info.location),
                        region: info.location,
                        country: info.country,
                        timestamp: Date(),
                        current: CurrentWeather(
                            temperature: info.temperature,
                            feelsLike: info.feelsLike,
                            humidity: info.humidity,
                            precipitation: info.precipitation,
                            windSpeed: info.windSpeed,
                            windDirection: "N",
                            condition: parseWeatherCondition(info.condition),
                            uvIndex: info.uvIndex,
                            visibility: 10.0,
                            pressure: 1013.0
                        ),
                        forecast: info.forecast.compactMap { day in
                            let formatter = ISO8601DateFormatter()
                            guard let date = formatter.date(from: day.date) else { return nil }

                            return WeatherForecast(
                                id: UUID().uuidString,
                                date: date,
                                highTemp: day.highTemp,
                                lowTemp: day.lowTemp,
                                precipitation: day.precipitation,
                                precipitationProbability: 0,
                                condition: parseWeatherCondition(day.condition),
                                windSpeed: 0
                            )
                        },
                        agriculturalImpact: assessAgriculturalImpact(info)
                    )
                }

                // Generate weather alerts
                weatherAlerts = generateWeatherAlerts(from: weatherData)
            } else {
                weatherData = (try? await weatherRepository.fetchAllWeatherData()) ?? []
                weatherAlerts = (try? await weatherRepository.getActiveWeatherAlerts()) ?? []
            }

        } catch {
            weatherError = "Failed to load weather: \(error.localizedDescription)"
            weatherData = (try? await weatherRepository.fetchAllWeatherData()) ?? []
        }

        isLoadingWeather = false
    }

    // MARK: - Insights

    private func loadInsights() async {
        // Generate market insights based on data
        marketInsights = generateMarketInsights()
    }

    private func generateMarketInsights() -> [MarketInsight] {
        var insights: [MarketInsight] = []

        // Price movement insights
        let gainers = commodities.filter { $0.dayChangePercent > 2.0 }
        if !gainers.isEmpty {
            insights.append(MarketInsight(
                id: UUID().uuidString,
                title: "Strong Upward Movement",
                description: "\(gainers.count) commodities up more than 2% today",
                type: .opportunity,
                priority: .high,
                commodities: gainers.map { $0.symbol },
                createdAt: Date(),
                expiresAt: Date().addingTimeInterval(24 * 3600),
                actionable: true,
                recommendations: [
                    "Monitor for potential entry points",
                    "Check volume to confirm trend"
                ]
            ))
        }

        // Weather-based insights
        if !weatherAlerts.isEmpty {
            insights.append(MarketInsight(
                id: UUID().uuidString,
                title: "Weather Alert Impact",
                description: "\(weatherAlerts.count) active weather alerts affecting agricultural regions",
                type: .risk,
                priority: .high,
                commodities: ["CORN", "WHEAT", "SOYB"],
                createdAt: Date(),
                expiresAt: Date().addingTimeInterval(48 * 3600),
                actionable: true,
                recommendations: [
                    "Monitor affected commodity prices",
                    "Consider hedging strategies"
                ]
            ))
        }

        return insights
    }

    // MARK: - Statistics

    private func calculateStats() {
        let totalCommodities = commodities.count
        let gainers = commodities.filter { $0.dayChange > 0 }.count
        let losers = commodities.filter { $0.dayChange < 0 }.count
        let totalVolume = commodities.reduce(0.0) { $0 + $1.volume }
        let avgChange = commodities.isEmpty ? 0 : commodities.reduce(0.0) { $0 + $1.dayChangePercent } / Double(commodities.count)

        marketStats = DashboardStats(
            totalCommodities: totalCommodities,
            gainers: gainers,
            losers: losers,
            unchanged: totalCommodities - gainers - losers,
            totalVolume: totalVolume,
            averageChange: avgChange,
            marketSentiment: determineMarketSentiment(avgChange),
            lastUpdated: Date()
        )
    }

    // MARK: - Cache Loading

    private func loadFromCache() {
        Task {
            commodities = (try? await repository.fetchAllCommodities()) ?? []
            news = (try? await newsRepository.fetchAllNews(limit: 20)) ?? []
            weatherData = (try? await weatherRepository.fetchAllWeatherData()) ?? []
            calculateStats()
        }
    }

    // MARK: - Helper Methods

    private func determineCommodityCategory(_ symbol: String) -> CommodityCategory {
        let grains = ["CORN", "WHEAT", "ZC", "ZW"]
        let oilseeds = ["SOYB", "ZS"]
        let metals = ["GC", "SI", "HG"]
        let energy = ["CL", "NG"]

        if grains.contains(symbol) { return .grains }
        if oilseeds.contains(symbol) { return .oilseeds }
        if metals.contains(symbol) { return .metals }
        if energy.contains(symbol) { return .energy }
        return .grains
    }

    private func determineSentiment(_ text: String) -> NewsSentiment {
        let bullish = ["surge", "rally", "gain", "rise", "up", "higher", "strong", "boom"]
        let bearish = ["fall", "drop", "decline", "down", "lower", "weak", "crash", "plunge"]

        let lowercased = text.lowercased()
        let bullishCount = bullish.filter { lowercased.contains($0) }.count
        let bearishCount = bearish.filter { lowercased.contains($0) }.count

        if bullishCount > bearishCount { return .bullish }
        if bearishCount > bullishCount { return .bearish }
        return .neutral
    }

    private func extractTags(_ text: String) -> [String] {
        var tags: [String] = []

        if text.localizedCaseInsensitiveContains("corn") { tags.append("Corn") }
        if text.localizedCaseInsensitiveContains("wheat") { tags.append("Wheat") }
        if text.localizedCaseInsensitiveContains("soybean") { tags.append("Soybeans") }
        if text.localizedCaseInsensitiveContains("weather") { tags.append("Weather") }
        if text.localizedCaseInsensitiveContains("trade") { tags.append("Trade") }
        if text.localizedCaseInsensitiveContains("china") { tags.append("China") }
        if text.localizedCaseInsensitiveContains("export") { tags.append("Exports") }

        return tags
    }

    private func parseWeatherCondition(_ condition: String) -> WeatherCondition {
        let lower = condition.lowercased()

        if lower.contains("sunny") || lower.contains("clear") { return .sunny }
        if lower.contains("cloud") { return .cloudy }
        if lower.contains("rain") { return .rainy }
        if lower.contains("storm") { return .stormy }
        if lower.contains("snow") { return .snowy }
        if lower.contains("fog") { return .foggy }
        return .partlyCloudy
    }

    private func assessAgriculturalImpact(_ weather: WeatherInfo) -> AgriculturalImpact {
        var impacts: [AgriculturalImpact.ImpactFactor] = []
        var riskLevel: AgriculturalImpact.RiskLevel = .low
        var recommendations: [String] = []

        // Temperature analysis
        if weather.temperature > 35 {
            impacts.append(.heatWave)
            riskLevel = .high
            recommendations.append("Extreme heat detected - ensure adequate irrigation")
        } else if weather.temperature < 0 {
            impacts.append(.frost)
            riskLevel = .severe
            recommendations.append("Frost warning - protect sensitive crops")
        }

        // Precipitation analysis
        if weather.precipitation > 50 {
            impacts.append(.excessiveRain)
            riskLevel = .moderate
            recommendations.append("Heavy rainfall - monitor drainage")
        } else if weather.precipitation == 0 && weather.humidity < 30 {
            impacts.append(.drought)
            riskLevel = .moderate
            recommendations.append("Dry conditions - monitor soil moisture")
        }

        if impacts.isEmpty {
            recommendations.append("Favorable weather conditions")
        }

        return AgriculturalImpact(
            overallRisk: riskLevel,
            impacts: impacts,
            recommendations: recommendations,
            affectedCrops: ["Corn", "Wheat", "Soybeans"]
        )
    }

    private func generateWeatherAlerts(from weatherData: [WeatherData]) -> [WeatherAlert] {
        var alerts: [WeatherAlert] = []

        for weather in weatherData {
            // Check for extreme conditions
            if weather.current.temperature > 35 {
                alerts.append(WeatherAlert(
                    id: UUID().uuidString,
                    region: weather.region,
                    alertType: .heatWave,
                    severity: .high,
                    message: "Heat wave warning - temperatures exceeding 35°C",
                    affectedCrops: ["Corn", "Wheat"],
                    validFrom: Date(),
                    validUntil: Date().addingTimeInterval(24 * 3600)
                ))
            }

            if weather.current.temperature < 0 {
                alerts.append(WeatherAlert(
                    id: UUID().uuidString,
                    region: weather.region,
                    alertType: .frost,
                    severity: .severe,
                    message: "Frost warning - freezing temperatures expected",
                    affectedCrops: ["All crops"],
                    validFrom: Date(),
                    validUntil: Date().addingTimeInterval(12 * 3600)
                ))
            }

            if weather.current.precipitation > 50 {
                alerts.append(WeatherAlert(
                    id: UUID().uuidString,
                    region: weather.region,
                    alertType: .flooding,
                    severity: .high,
                    message: "Heavy rainfall - flooding risk",
                    affectedCrops: ["All crops"],
                    validFrom: Date(),
                    validUntil: Date().addingTimeInterval(24 * 3600)
                ))
            }
        }

        return alerts
    }

    private func determineMarketSentiment(_ avgChange: Double) -> MarketSentiment {
        if avgChange > 1.0 { return .bullish }
        if avgChange < -1.0 { return .bearish }
        return .neutral
    }
}

// MARK: - Supporting Models

struct DashboardStats {
    let totalCommodities: Int
    let gainers: Int
    let losers: Int
    let unchanged: Int
    let totalVolume: Double
    let averageChange: Double
    let marketSentiment: MarketSentiment
    let lastUpdated: Date
}

enum MarketSentiment {
    case bullish
    case bearish
    case neutral

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

    var description: String {
        switch self {
        case .bullish: return "Bullish"
        case .bearish: return "Bearish"
        case .neutral: return "Neutral"
        }
    }
}
