//
//  WebScrapingService.swift
//  AgriMarket
//
//  Web scraping service for real agricultural data
//

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

class WebScrapingService {
    static let shared = WebScrapingService()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.httpAdditionalHeaders = [
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15"
        ]
        self.session = URLSession(configuration: config)
    }

    // MARK: - Commodity Prices Scraping

    /// Scrape commodity prices from various sources
    func scrapeCommodityPrices() async throws -> [ScrapedCommodityData] {
        var results: [ScrapedCommodityData] = []

        // Scrape from multiple sources in parallel
        async let nasdaqData = scrapeNASDAQCommodities()
        async let investingData = scrapeInvestingCommodities()
        async let tradingEconomicsData = scrapeTradingEconomics()

        let (nasdaq, investing, trading) = try await (nasdaqData, investingData, tradingEconomicsData)

        results.append(contentsOf: nasdaq)
        results.append(contentsOf: investing)
        results.append(contentsOf: trading)

        return results
    }

    // MARK: - NASDAQ Commodities
    private func scrapeNASDAQCommodities() async throws -> [ScrapedCommodityData] {
        // Example: Scraping from NASDAQ commodity futures
        let urls = [
            "https://www.nasdaq.com/market-activity/commodities/zc", // Corn
            "https://www.nasdaq.com/market-activity/commodities/zw", // Wheat
            "https://www.nasdaq.com/market-activity/commodities/zs"  // Soybeans
        ]

        var results: [ScrapedCommodityData] = []

        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }

            do {
                let (data, _) = try await session.data(from: url)
                if let html = String(data: data, encoding: .utf8) {
                    if let commodityData = parseNASDAQHTML(html, url: urlString) {
                        results.append(commodityData)
                    }
                }
            } catch {
                print("Error scraping \(urlString): \(error)")
            }
        }

        return results
    }

    // MARK: - Investing.com Commodities
    private func scrapeInvestingCommodities() async throws -> [ScrapedCommodityData] {
        // Investing.com has commodity data
        let urls = [
            "https://www.investing.com/commodities/us-corn",
            "https://www.investing.com/commodities/us-wheat",
            "https://www.investing.com/commodities/us-soybeans",
            "https://www.investing.com/commodities/us-coffee-c"
        ]

        var results: [ScrapedCommodityData] = []

        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }

            do {
                let (data, _) = try await session.data(from: url)
                if let html = String(data: data, encoding: .utf8) {
                    if let commodityData = parseInvestingHTML(html, url: urlString) {
                        results.append(commodityData)
                    }
                }
            } catch {
                print("Error scraping \(urlString): \(error)")
            }
        }

        return results
    }

    // MARK: - Trading Economics
    private func scrapeTradingEconomics() async throws -> [ScrapedCommodityData] {
        // Trading Economics has agricultural commodity data
        let urlString = "https://tradingeconomics.com/commodities"
        guard let url = URL(string: urlString) else { return [] }

        var results: [ScrapedCommodityData] = []

        do {
            let (data, _) = try await session.data(from: url)
            if let html = String(data: data, encoding: .utf8) {
                results = parseTradingEconomicsHTML(html)
            }
        } catch {
            print("Error scraping Trading Economics: \(error)")
        }

        return results
    }

    // MARK: - USDA Data (Official US Department of Agriculture)
    func scrapeUSDAData() async throws -> [ScrapedCommodityData] {
        // USDA provides JSON APIs for agricultural data
        let urlString = "https://quickstats.nass.usda.gov/api/api_GET/"
        guard let url = URL(string: urlString) else { return [] }

        var results: [ScrapedCommodityData] = []

        do {
            let (data, _) = try await session.data(from: url)
            // Parse USDA JSON data
            results = try parseUSDAJSON(data)
        } catch {
            print("Error fetching USDA data: \(error)")
        }

        return results
    }

    // MARK: - Weather Data Scraping
    func scrapeWeatherData(for regions: [String]) async throws -> [ScrapedWeatherData] {
        var results: [ScrapedWeatherData] = []

        for region in regions {
            if let weatherData = try await scrapeWeatherForRegion(region) {
                results.append(weatherData)
            }
        }

        return results
    }

    private func scrapeWeatherForRegion(_ region: String) async throws -> ScrapedWeatherData? {
        // Use weather APIs like OpenWeatherMap, WeatherAPI, etc.
        let encodedRegion = region.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? region
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=YOUR_API_KEY&q=\(encodedRegion)&days=7"

        guard let url = URL(string: urlString) else { return nil }

        let (data, _) = try await session.data(from: url)
        return try parseWeatherJSON(data, region: region)
    }

    // MARK: - News Scraping
    func scrapeAgriculturalNews() async throws -> [ScrapedNewsData] {
        var results: [ScrapedNewsData] = []

        // Scrape from agricultural news sources
        async let agwebNews = scrapeAgWebNews()
        async let farmerNews = scrapeFarmersNews()
        async let reutersAgri = scrapeReutersAgriculture()

        let (agweb, farmers, reuters) = try await (agwebNews, farmerNews, reutersAgri)

        results.append(contentsOf: agweb)
        results.append(contentsOf: farmers)
        results.append(contentsOf: reuters)

        return results
    }

    private func scrapeAgWebNews() async throws -> [ScrapedNewsData] {
        let urlString = "https://www.agweb.com/markets"
        guard let url = URL(string: urlString) else { return [] }

        let (data, _) = try await session.data(from: url)
        if let html = String(data: data, encoding: .utf8) {
            return parseAgWebHTML(html)
        }
        return []
    }

    private func scrapeFarmersNews() async throws -> [ScrapedNewsData] {
        let urlString = "https://www.farmprogress.com/markets"
        guard let url = URL(string: urlString) else { return [] }

        let (data, _) = try await session.data(from: url)
        if let html = String(data: data, encoding: .utf8) {
            return parseFarmersHTML(html)
        }
        return []
    }

    private func scrapeReutersAgriculture() async throws -> [ScrapedNewsData] {
        let urlString = "https://www.reuters.com/markets/commodities"
        guard let url = URL(string: urlString) else { return [] }

        let (data, _) = try await session.data(from: url)
        if let html = String(data: data, encoding: .utf8) {
            return parseReutersHTML(html)
        }
        return []
    }

    // MARK: - RSS Feed Parsing
    func parseRSSFeed(url: String) async throws -> [ScrapedNewsData] {
        guard let feedURL = URL(string: url) else { return [] }

        let (data, _) = try await session.data(from: feedURL)
        return parseRSSData(data)
    }
}

// MARK: - Scraped Data Models

struct ScrapedCommodityData: Codable {
    let source: String
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    let changePercent: Double
    let volume: Double?
    let timestamp: Date
    let currency: String
    let unit: String
}

struct ScrapedWeatherData: Codable {
    let region: String
    let country: String
    let temperature: Double
    let humidity: Int
    let precipitation: Double
    let windSpeed: Double
    let condition: String
    let timestamp: Date
    let forecast: [WeatherForecastData]
}

struct WeatherForecastData: Codable {
    let date: Date
    let highTemp: Double
    let lowTemp: Double
    let precipitation: Double
    let condition: String
}

struct ScrapedNewsData: Codable {
    let source: String
    let title: String
    let summary: String
    let url: String
    let publishedAt: Date
    let category: String
    let imageUrl: String?
}

// MARK: - HTML Parsing Extensions

extension WebScrapingService {

    private func parseNASDAQHTML(_ html: String, url: String) -> ScrapedCommodityData? {
        // Parse NASDAQ HTML structure
        // Look for price data in specific divs/spans

        var price: Double = 0.0
        var change: Double = 0.0
        var changePercent: Double = 0.0

        // Simple regex-based parsing (in production, use proper HTML parser)
        if let priceMatch = html.range(of: #"<span[^>]*class="[^"]*symbol-page-header__price[^"]*"[^>]*>([0-9.,]+)</span>"#, options: .regularExpression) {
            let priceString = String(html[priceMatch]).replacingOccurrences(of: ",", with: "")
            if let priceValue = priceString.components(separatedBy: CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))).joined().compactMap({ Double(String($0)) }).first {
                price = priceValue
            }
        }

        // Extract symbol from URL
        let symbol = url.components(separatedBy: "/").last?.uppercased() ?? ""

        return ScrapedCommodityData(
            source: "NASDAQ",
            symbol: symbol,
            name: getCommodityName(for: symbol),
            price: price,
            change: change,
            changePercent: changePercent,
            volume: nil,
            timestamp: Date(),
            currency: "USD",
            unit: "per bushel"
        )
    }

    private func parseInvestingHTML(_ html: String, url: String) -> ScrapedCommodityData? {
        // Similar parsing for Investing.com
        // Their structure: <span class="text-2xl" data-test="instrument-price-last">123.45</span>

        var price: Double = 0.0

        // Extract price from Investing.com HTML
        if let priceMatch = html.range(of: #"data-test="instrument-price-last">([0-9.,]+)</span>"#, options: .regularExpression) {
            let matched = html[priceMatch]
            let components = matched.components(separatedBy: ">")
            if components.count >= 2 {
                let priceStr = components[1].replacingOccurrences(of: "</span>", with: "").replacingOccurrences(of: ",", with: "")
                price = Double(priceStr) ?? 0.0
            }
        }

        let symbol = extractSymbolFromURL(url)

        return ScrapedCommodityData(
            source: "Investing.com",
            symbol: symbol,
            name: getCommodityName(for: symbol),
            price: price,
            change: 0,
            changePercent: 0,
            volume: nil,
            timestamp: Date(),
            currency: "USD",
            unit: "per unit"
        )
    }

    private func parseTradingEconomicsHTML(_ html: String) -> [ScrapedCommodityData] {
        var results: [ScrapedCommodityData] = []

        // Trading Economics has a table structure with commodity data
        // Parse the table rows

        return results
    }

    private func parseUSDAJSON(_ data: Data) throws -> [ScrapedCommodityData] {
        // Parse USDA JSON response
        var results: [ScrapedCommodityData] = []

        // USDA provides structured JSON
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // Parse according to USDA API structure
        }

        return results
    }

    private func parseWeatherJSON(_ data: Data, region: String) throws -> ScrapedWeatherData? {
        // Parse weather JSON from API
        struct WeatherResponse: Codable {
            let location: LocationData
            let current: CurrentWeather
            let forecast: ForecastData

            struct LocationData: Codable {
                let name: String
                let country: String
            }

            struct CurrentWeather: Codable {
                let temp_c: Double
                let humidity: Int
                let precip_mm: Double
                let wind_kph: Double
                let condition: Condition

                struct Condition: Codable {
                    let text: String
                }
            }

            struct ForecastData: Codable {
                let forecastday: [ForecastDay]

                struct ForecastDay: Codable {
                    let date: String
                    let day: DayData

                    struct DayData: Codable {
                        let maxtemp_c: Double
                        let mintemp_c: Double
                        let totalprecip_mm: Double
                        let condition: CurrentWeather.Condition
                    }
                }
            }
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(WeatherResponse.self, from: data)

        let forecastData = response.forecast.forecastday.compactMap { day -> WeatherForecastData? in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let date = formatter.date(from: day.date) else { return nil }

            return WeatherForecastData(
                date: date,
                highTemp: day.day.maxtemp_c,
                lowTemp: day.day.mintemp_c,
                precipitation: day.day.totalprecip_mm,
                condition: day.day.condition.text
            )
        }

        return ScrapedWeatherData(
            region: response.location.name,
            country: response.location.country,
            temperature: response.current.temp_c,
            humidity: response.current.humidity,
            precipitation: response.current.precip_mm,
            windSpeed: response.current.wind_kph,
            condition: response.current.condition.text,
            timestamp: Date(),
            forecast: forecastData
        )
    }

    private func parseAgWebHTML(_ html: String) -> [ScrapedNewsData] {
        var results: [ScrapedNewsData] = []

        // Parse AgWeb news articles
        // Look for article titles, summaries, URLs

        return results
    }

    private func parseFarmersHTML(_ html: String) -> [ScrapedNewsData] {
        var results: [ScrapedNewsData] = []

        // Parse Farm Progress news

        return results
    }

    private func parseReutersHTML(_ html: String) -> [ScrapedNewsData] {
        var results: [ScrapedNewsData] = []

        // Parse Reuters commodity news

        return results
    }

    private func parseRSSData(_ data: Data) -> [ScrapedNewsData] {
        var results: [ScrapedNewsData] = []

        // Parse RSS/Atom feed
        #if canImport(FoundationXML)
        let parser = XMLParser(data: data)
        // Implement RSS parsing
        #endif

        return results
    }

    // MARK: - Helper Methods

    private func getCommodityName(for symbol: String) -> String {
        let mapping: [String: String] = [
            "ZC": "Corn",
            "ZW": "Wheat",
            "ZS": "Soybeans",
            "KC": "Coffee",
            "CT": "Cotton",
            "SB": "Sugar"
        ]
        return mapping[symbol] ?? symbol
    }

    private func extractSymbolFromURL(_ url: String) -> String {
        let components = url.components(separatedBy: "/")
        return components.last?.replacingOccurrences(of: "us-", with: "").uppercased() ?? ""
    }
}
