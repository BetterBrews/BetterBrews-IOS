//
//  APIManager.swift
//  AgriMarket
//
//  Centralized API management with real working implementations
//

import Foundation
import Combine

class APIManager: ObservableObject {
    static let shared = APIManager()

    @Published var isOnline = true
    @Published var apiStatus: [String: APIStatus] = [:]

    private let session: URLSession
    private let cache = URLCache.shared

    // API Configurations
    private var config: APIConfiguration

    struct APIConfiguration {
        var alphaVantageKey: String
        var weatherAPIKey: String
        var newsAPIKey: String
        var usdaAPIKey: String

        static var `default`: APIConfiguration {
            APIConfiguration(
                alphaVantageKey: UserDefaults.standard.string(forKey: "alphaVantageKey") ?? "demo",
                weatherAPIKey: UserDefaults.standard.string(forKey: "weatherAPIKey") ?? "",
                newsAPIKey: UserDefaults.standard.string(forKey: "newsAPIKey") ?? "",
                usdaAPIKey: UserDefaults.standard.string(forKey: "usdaAPIKey") ?? ""
            )
        }

        func save() {
            UserDefaults.standard.set(alphaVantageKey, forKey: "alphaVantageKey")
            UserDefaults.standard.set(weatherAPIKey, forKey: "weatherAPIKey")
            UserDefaults.standard.set(newsAPIKey, forKey: "newsAPIKey")
            UserDefaults.standard.set(usdaAPIKey, forKey: "usdaAPIKey")
        }
    }

    enum APIStatus: String {
        case operational = "Operational"
        case degraded = "Degraded"
        case offline = "Offline"
    }

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: configuration)
        self.config = .default
    }

    // MARK: - API Configuration

    func updateConfiguration(_ config: APIConfiguration) {
        self.config = config
        config.save()
    }

    func hasValidKeys() -> Bool {
        !config.alphaVantageKey.isEmpty && config.alphaVantageKey != "demo"
    }

    // MARK: - Commodity Data

    func fetchCommodityPrices(symbols: [String]) async throws -> [CommodityPrice] {
        guard hasValidKeys() else {
            // Fallback to World Bank data
            return try await fetchWorldBankData()
        }

        var prices: [CommodityPrice] = []

        for symbol in symbols {
            do {
                if let price = try await fetchAlphaVantageQuote(symbol: symbol) {
                    prices.append(price)
                }
                // Rate limiting - Alpha Vantage: 5 calls/minute
                try await Task.sleep(nanoseconds: 12_000_000_000) // 12 seconds
            } catch {
                print("Error fetching \(symbol): \(error)")
                updateAPIStatus("Alpha Vantage", status: .degraded)
            }
        }

        if !prices.isEmpty {
            updateAPIStatus("Alpha Vantage", status: .operational)
        }

        return prices
    }

    private func fetchAlphaVantageQuote(symbol: String) async throws -> CommodityPrice? {
        let urlString = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(config.alphaVantageKey)"
        guard let url = URL(string: urlString) else { return nil }

        let (data, response) = try await session.data(from: url)

        // Check if rate limited
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let note = json["Note"] as? String, note.contains("API call frequency") {
            throw APIError.rateLimited
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let quote = json["Global Quote"] as? [String: String] else {
            return nil
        }

        return CommodityPrice(
            symbol: quote["01. symbol"] ?? symbol,
            name: getCommodityName(symbol),
            price: Double(quote["05. price"] ?? "0") ?? 0,
            change: Double(quote["09. change"] ?? "0") ?? 0,
            changePercent: parsePercent(quote["10. change percent"] ?? "0"),
            volume: Double(quote["06. volume"] ?? "0") ?? 0,
            timestamp: Date()
        )
    }

    // Fallback: World Bank Crop Production Index
    private func fetchWorldBankData() async throws -> [CommodityPrice] {
        let url = URL(string: "https://api.worldbank.org/v2/country/USA/indicator/AG.PRD.CROP.XD?format=json&per_page=1")!

        let (data, _) = try await session.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]

        guard json.count > 1,
              let dataArray = json[1] as? [[String: Any]],
              let firstItem = dataArray.first,
              let value = firstItem["value"] as? Double else {
            throw APIError.invalidResponse
        }

        updateAPIStatus("World Bank", status: .operational)

        // Create synthetic commodity data based on crop index
        return [
            CommodityPrice(
                symbol: "CROP_INDEX",
                name: "Crop Production Index",
                price: value,
                change: 0,
                changePercent: 0,
                volume: 0,
                timestamp: Date()
            )
        ]
    }

    // MARK: - Weather Data

    func fetchWeather(locations: [String]) async throws -> [WeatherInfo] {
        guard !config.weatherAPIKey.isEmpty else {
            throw APIError.missingAPIKey("WeatherAPI")
        }

        var weatherData: [WeatherInfo] = []

        for location in locations {
            do {
                if let weather = try await fetchWeatherAPIData(location: location) {
                    weatherData.append(weather)
                }
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            } catch {
                print("Error fetching weather for \(location): \(error)")
            }
        }

        if !weatherData.isEmpty {
            updateAPIStatus("WeatherAPI", status: .operational)
        }

        return weatherData
    }

    private func fetchWeatherAPIData(location: String) async throws -> WeatherInfo? {
        let encoded = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? location
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(config.weatherAPIKey)&q=\(encoded)&days=7&aqi=yes"
        guard let url = URL(string: urlString) else { return nil }

        let (data, _) = try await session.data(from: url)

        struct WeatherResponse: Codable {
            let location: Location
            let current: Current
            let forecast: Forecast

            struct Location: Codable {
                let name: String
                let country: String
                let lat: Double
                let lon: Double
            }

            struct Current: Codable {
                let temp_c: Double
                let condition: Condition
                let wind_kph: Double
                let precip_mm: Double
                let humidity: Int
                let feelslike_c: Double
                let uv: Double
            }

            struct Condition: Codable {
                let text: String
                let icon: String
            }

            struct Forecast: Codable {
                let forecastday: [ForecastDay]

                struct ForecastDay: Codable {
                    let date: String
                    let day: Day

                    struct Day: Codable {
                        let maxtemp_c: Double
                        let mintemp_c: Double
                        let totalprecip_mm: Double
                        let avghumidity: Double
                        let condition: Condition
                    }
                }
            }
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(WeatherResponse.self, from: data)

        return WeatherInfo(
            location: location,
            country: response.location.country,
            temperature: response.current.temp_c,
            feelsLike: response.current.feelslike_c,
            humidity: response.current.humidity,
            precipitation: response.current.precip_mm,
            windSpeed: response.current.wind_kph,
            condition: response.current.condition.text,
            uvIndex: Int(response.current.uv),
            forecast: response.forecast.forecastday.map { day in
                WeatherForecastDay(
                    date: day.date,
                    highTemp: day.day.maxtemp_c,
                    lowTemp: day.day.mintemp_c,
                    precipitation: day.day.totalprecip_mm,
                    condition: day.day.condition.text
                )
            }
        )
    }

    // MARK: - News Data

    func fetchNews(query: String = "agriculture", pageSize: Int = 20) async throws -> [NewsItem] {
        // First try RSS feeds (no key needed)
        let rssNews = try await fetchRSSNews()
        if !rssNews.isEmpty {
            updateAPIStatus("RSS Feeds", status: .operational)
            return rssNews
        }

        // Fallback to NewsAPI if key available
        guard !config.newsAPIKey.isEmpty else {
            throw APIError.missingAPIKey("NewsAPI")
        }

        return try await fetchNewsAPIData(query: query, pageSize: pageSize)
    }

    private func fetchRSSNews() async throws -> [NewsItem] {
        let feeds = [
            "https://www.agriculture.com/rss",
            "https://www.agweb.com/rss"
        ]

        var allNews: [NewsItem] = []

        for feedURL in feeds {
            guard let url = URL(string: feedURL) else { continue }

            do {
                let (data, _) = try await session.data(from: url)
                let parser = DataParserService.shared
                let items = try parser.parseRSS(data)

                let news = items.prefix(10).map { item in
                    NewsItem(
                        title: item.title,
                        description: item.description,
                        url: item.link,
                        source: "Agriculture RSS",
                        publishedAt: item.pubDate ?? Date(),
                        imageUrl: nil
                    )
                }

                allNews.append(contentsOf: news)
            } catch {
                print("Error parsing RSS feed \(feedURL): \(error)")
            }
        }

        return allNews
    }

    private func fetchNewsAPIData(query: String, pageSize: Int) async throws -> [NewsItem] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://newsapi.org/v2/everything?q=\(encoded)&sortBy=publishedAt&pageSize=\(pageSize)&apiKey=\(config.newsAPIKey)"
        guard let url = URL(string: urlString) else { return [] }

        let (data, _) = try await session.data(from: url)

        struct NewsAPIResponse: Codable {
            let status: String
            let articles: [Article]

            struct Article: Codable {
                let title: String
                let description: String?
                let url: String
                let urlToImage: String?
                let publishedAt: String
                let source: Source

                struct Source: Codable {
                    let name: String
                }
            }
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(NewsAPIResponse.self, from: data)

        updateAPIStatus("NewsAPI", status: .operational)

        return response.articles.map { article in
            NewsItem(
                title: article.title,
                description: article.description ?? "",
                url: article.url,
                source: article.source.name,
                publishedAt: ISO8601DateFormatter().date(from: article.publishedAt) ?? Date(),
                imageUrl: article.urlToImage
            )
        }
    }

    // MARK: - Helper Methods

    private func updateAPIStatus(_ api: String, status: APIStatus) {
        DispatchQueue.main.async {
            self.apiStatus[api] = status
        }
    }

    private func getCommodityName(_ symbol: String) -> String {
        let mapping: [String: String] = [
            "CORN": "Corn",
            "WHEAT": "Wheat",
            "SOYB": "Soybeans",
            "ZC": "Corn Futures",
            "ZW": "Wheat Futures",
            "ZS": "Soybean Futures",
            "GC": "Gold",
            "SI": "Silver",
            "CL": "Crude Oil"
        ]
        return mapping[symbol] ?? symbol
    }

    private func parsePercent(_ string: String) -> Double {
        let cleaned = string.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces)
        return Double(cleaned) ?? 0
    }

    // MARK: - Network Status

    func checkConnectivity() async -> Bool {
        do {
            let url = URL(string: "https://www.google.com")!
            let (_, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                let isOnline = httpResponse.statusCode == 200
                await MainActor.run {
                    self.isOnline = isOnline
                }
                return isOnline
            }
        } catch {
            await MainActor.run {
                self.isOnline = false
            }
        }
        return false
    }
}

// MARK: - Models

struct CommodityPrice {
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    let changePercent: Double
    let volume: Double
    let timestamp: Date
}

struct WeatherInfo {
    let location: String
    let country: String
    let temperature: Double
    let feelsLike: Double
    let humidity: Int
    let precipitation: Double
    let windSpeed: Double
    let condition: String
    let uvIndex: Int
    let forecast: [WeatherForecastDay]
}

struct WeatherForecastDay {
    let date: String
    let highTemp: Double
    let lowTemp: Double
    let precipitation: Double
    let condition: String
}

struct NewsItem {
    let title: String
    let description: String
    let url: String
    let source: String
    let publishedAt: Date
    let imageUrl: String?
}

enum APIError: LocalizedError {
    case invalidResponse
    case rateLimited
    case missingAPIKey(String)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid API response"
        case .rateLimited:
            return "API rate limit exceeded. Please wait."
        case .missingAPIKey(let api):
            return "Missing API key for \(api)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
