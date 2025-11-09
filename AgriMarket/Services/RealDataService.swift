//
//  RealDataService.swift
//  AgriMarket
//
//  REAL working implementation with free APIs
//

import Foundation

/// This is a WORKING implementation using real free APIs
/// Replace WebScrapingService with this for immediate results
class RealDataService {
    static let shared = RealDataService()

    private let session: URLSession

    // FREE API Keys - Get yours at:
    // https://www.alphavantage.co/support/#api-key
    // https://www.weatherapi.com/signup.aspx
    // https://newsapi.org/register
    private let alphaVantageKey = "YOUR_KEY_HERE" // Demo: "demo"
    private let weatherAPIKey = "YOUR_KEY_HERE"
    private let newsAPIKey = "YOUR_KEY_HERE"

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - WORKING: World Bank API (No Key Needed!)

    /// Get real agricultural data from World Bank
    /// FREE, no registration needed!
    func fetchWorldBankAgriculturalData() async throws -> [WorldBankData] {
        // Crop production index
        let url = URL(string: "https://api.worldbank.org/v2/country/USA/indicator/AG.PRD.CROP.XD?format=json&per_page=10")!

        let (data, _) = try await session.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]

        // World Bank returns array with metadata first, data second
        guard json.count > 1 else { return [] }

        let dataArray = json[1] as! [[String: Any]]

        return dataArray.compactMap { item -> WorldBankData? in
            guard let value = item["value"] as? Double,
                  let date = item["date"] as? String else {
                return nil
            }

            return WorldBankData(
                indicator: "Crop Production Index",
                country: "USA",
                year: date,
                value: value
            )
        }
    }

    // MARK: - WORKING: Alpha Vantage (500 calls/day free)

    /// Get real commodity prices from Alpha Vantage
    /// Register free at: https://www.alphavantage.co/
    func fetchAlphaVantageCommodity(symbol: String) async throws -> AlphaVantageQuote? {
        let urlString = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(alphaVantageKey)"
        guard let url = URL(string: urlString) else { return nil }

        let (data, _) = try await session.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        guard let quote = json["Global Quote"] as? [String: String] else {
            return nil
        }

        return AlphaVantageQuote(
            symbol: quote["01. symbol"] ?? "",
            price: Double(quote["05. price"] ?? "0") ?? 0,
            change: Double(quote["09. change"] ?? "0") ?? 0,
            changePercent: quote["10. change percent"]?.replacingOccurrences(of: "%", with: "") ?? "0",
            volume: Double(quote["06. volume"] ?? "0") ?? 0,
            latestTradingDay: quote["07. latest trading day"] ?? ""
        )
    }

    // MARK: - WORKING: WeatherAPI (1M calls/month free)

    /// Get real weather data
    /// Register free at: https://www.weatherapi.com/
    func fetchWeatherAPIData(location: String) async throws -> WeatherAPIResponse? {
        let encoded = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? location
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(weatherAPIKey)&q=\(encoded)&days=7&aqi=no"
        guard let url = URL(string: urlString) else { return nil }

        let (data, _) = try await session.data(from: url)

        let decoder = JSONDecoder()
        return try decoder.decode(WeatherAPIResponse.self, from: data)
    }

    // MARK: - WORKING: NewsAPI (100 calls/day free)

    /// Get real agricultural news
    /// Register free at: https://newsapi.org/
    func fetchNewsAPIArticles(query: String = "agriculture") async throws -> [NewsAPIArticle] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://newsapi.org/v2/everything?q=\(encoded)&sortBy=publishedAt&pageSize=20&apiKey=\(newsAPIKey)"
        guard let url = URL(string: urlString) else { return [] }

        let (data, _) = try await session.data(from: url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(NewsAPIResponse.self, from: data)

        return response.articles
    }

    // MARK: - WORKING: Agriculture.com RSS Feed (Free, no key)

    /// Parse real RSS feeds from agricultural news sites
    /// Completely FREE, no registration needed!
    func fetchAgricultureRSS() async throws -> [RSSItem] {
        let feeds = [
            "https://www.agriculture.com/rss",
            "https://www.farmfutures.com/rss.xml"
        ]

        var allItems: [RSSItem] = []

        for feedURL in feeds {
            guard let url = URL(string: feedURL) else { continue }

            do {
                let (data, _) = try await session.data(from: url)
                let parser = DataParserService.shared
                let items = try parser.parseRSS(data)
                allItems.append(contentsOf: items)
            } catch {
                print("Error parsing feed \(feedURL): \(error)")
            }
        }

        return allItems
    }

    // MARK: - WORKING: USDA NASS API (Free with registration)

    /// Get official USDA agricultural statistics
    /// Register free at: https://quickstats.nass.usda.gov/api
    func fetchUSDAData(apiKey: String) async throws -> [USDARecord] {
        let urlString = "https://quickstats.nass.usda.gov/api/api_GET/?key=\(apiKey)&commodity_desc=CORN&year=2024&agg_level_desc=STATE&format=JSON"
        guard let url = URL(string: urlString) else { return [] }

        let (data, _) = try await session.data(from: url)

        struct USDAResponse: Codable {
            let data: [USDARecord]
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(USDAResponse.self, from: data)

        return response.data
    }

    // MARK: - Convert to App Models

    func convertToScrapedCommodity(_ quote: AlphaVantageQuote) -> ScrapedCommodityData {
        let changePercent = Double(quote.changePercent) ?? 0

        return ScrapedCommodityData(
            source: "Alpha Vantage",
            symbol: quote.symbol,
            name: getCommodityName(quote.symbol),
            price: quote.price,
            change: quote.change,
            changePercent: changePercent,
            volume: quote.volume,
            timestamp: Date(),
            currency: "USD",
            unit: "per unit"
        )
    }

    func convertToScrapedNews(_ article: NewsAPIArticle) -> ScrapedNewsData {
        ScrapedNewsData(
            source: article.source.name,
            title: article.title,
            summary: article.description ?? "",
            url: article.url,
            publishedAt: article.publishedAt,
            category: "Market Analysis",
            imageUrl: article.urlToImage
        )
    }

    func convertToScrapedWeather(_ weather: WeatherAPIResponse) -> ScrapedWeatherData {
        let forecasts = weather.forecast.forecastday.map { day in
            WeatherForecastData(
                date: ISO8601DateFormatter().date(from: day.date) ?? Date(),
                highTemp: day.day.maxtemp_c,
                lowTemp: day.day.mintemp_c,
                precipitation: day.day.totalprecip_mm,
                condition: day.day.condition.text
            )
        }

        return ScrapedWeatherData(
            region: weather.location.name,
            country: weather.location.country,
            temperature: weather.current.temp_c,
            humidity: weather.current.humidity,
            precipitation: weather.current.precip_mm,
            windSpeed: weather.current.wind_kph,
            condition: weather.current.condition.text,
            timestamp: Date(),
            forecast: forecasts
        )
    }

    private func getCommodityName(_ symbol: String) -> String {
        let mapping = [
            "CORN": "Corn",
            "WHEAT": "Wheat",
            "SOYB": "Soybeans",
            "ZC": "Corn Futures",
            "ZW": "Wheat Futures",
            "ZS": "Soybean Futures"
        ]
        return mapping[symbol] ?? symbol
    }
}

// MARK: - Data Models

struct WorldBankData: Codable {
    let indicator: String
    let country: String
    let year: String
    let value: Double
}

struct AlphaVantageQuote {
    let symbol: String
    let price: Double
    let change: Double
    let changePercent: String
    let volume: Double
    let latestTradingDay: String
}

// MARK: - WeatherAPI Models

struct WeatherAPIResponse: Codable {
    let location: WeatherLocation
    let current: WeatherCurrent
    let forecast: WeatherForecast

    struct WeatherLocation: Codable {
        let name: String
        let country: String
        let lat: Double
        let lon: Double
    }

    struct WeatherCurrent: Codable {
        let temp_c: Double
        let temp_f: Double
        let condition: WeatherCondition
        let wind_kph: Double
        let precip_mm: Double
        let humidity: Int
        let cloud: Int
        let feelslike_c: Double
    }

    struct WeatherCondition: Codable {
        let text: String
        let icon: String
    }

    struct WeatherForecast: Codable {
        let forecastday: [ForecastDay]

        struct ForecastDay: Codable {
            let date: String
            let day: Day

            struct Day: Codable {
                let maxtemp_c: Double
                let mintemp_c: Double
                let avgtemp_c: Double
                let totalprecip_mm: Double
                let avghumidity: Double
                let condition: WeatherCondition
            }
        }
    }
}

// MARK: - NewsAPI Models

struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsAPIArticle]
}

struct NewsAPIArticle: Codable {
    let source: NewsSource
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: Date
    let content: String?

    struct NewsSource: Codable {
        let id: String?
        let name: String
    }
}

// MARK: - USDA Models

struct USDARecord: Codable {
    let commodity_desc: String
    let year: Int
    let state_name: String
    let statisticcat_desc: String
    let unit_desc: String
    let Value: String
}

// MARK: - Example Usage

extension RealDataService {
    /// Complete working example - call this from DataSyncService
    func fetchAllRealData() async throws -> (
        commodities: [ScrapedCommodityData],
        news: [ScrapedNewsData],
        weather: [ScrapedWeatherData]
    ) {
        // 1. Fetch World Bank data (FREE, no key needed!)
        let worldBankData = try await fetchWorldBankAgriculturalData()
        print("✅ World Bank: \(worldBankData.count) records")

        // 2. Fetch RSS feeds (FREE, no key needed!)
        let rssNews = try await fetchAgricultureRSS()
        print("✅ RSS News: \(rssNews.count) articles")

        // 3. If you have API keys, fetch these:
        var commodities: [ScrapedCommodityData] = []
        var newsArticles: [ScrapedNewsData] = []
        var weatherData: [ScrapedWeatherData] = []

        // Alpha Vantage (requires free key)
        if alphaVantageKey != "YOUR_KEY_HERE" {
            let symbols = ["CORN", "WHEAT", "SOYB"]
            for symbol in symbols {
                if let quote = try? await fetchAlphaVantageCommodity(symbol: symbol) {
                    commodities.append(convertToScrapedCommodity(quote))
                }
            }
            print("✅ Alpha Vantage: \(commodities.count) commodities")
        }

        // NewsAPI (requires free key)
        if newsAPIKey != "YOUR_KEY_HERE" {
            let articles = try await fetchNewsAPIArticles(query: "agriculture commodities")
            newsArticles = articles.map { convertToScrapedNews($0) }
            print("✅ NewsAPI: \(newsArticles.count) articles")
        }

        // WeatherAPI (requires free key)
        if weatherAPIKey != "YOUR_KEY_HERE" {
            let locations = ["Chicago", "Des Moines", "Kansas City"]
            for location in locations {
                if let weather = try? await fetchWeatherAPIData(location: location) {
                    weatherData.append(convertToScrapedWeather(weather))
                }
            }
            print("✅ WeatherAPI: \(weatherData.count) locations")
        }

        return (commodities, newsArticles, weatherData)
    }
}
