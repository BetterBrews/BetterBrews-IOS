//
//  DataSyncService.swift
//  AgriMarket
//
//  Synchronization service between remote data and local database
//

import Foundation
import CoreData
import Combine

class DataSyncService: ObservableObject {
    static let shared = DataSyncService()

    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncProgress: Double = 0.0

    private let persistence = PersistenceController.shared
    private let scrapingService = WebScrapingService.shared
    private let commodityService = CommodityService.shared
    private let newsService = NewsService.shared
    private let weatherService = WeatherService.shared

    private var cancellables = Set<AnyCancellable>()

    // Sync intervals
    private let commoditySyncInterval: TimeInterval = 300 // 5 minutes
    private let newsSyncInterval: TimeInterval = 900 // 15 minutes
    private let weatherSyncInterval: TimeInterval = 1800 // 30 minutes

    private init() {
        loadLastSyncDate()
    }

    // MARK: - Full Sync

    func performFullSync() async throws {
        guard !isSyncing else {
            print("Sync already in progress")
            return
        }

        await MainActor.run {
            isSyncing = true
            syncProgress = 0.0
        }

        do {
            // Sync commodities
            await updateProgress(0.1)
            try await syncCommodities()

            // Sync news
            await updateProgress(0.4)
            try await syncNews()

            // Sync weather
            await updateProgress(0.7)
            try await syncWeather()

            // Update last sync date
            await updateProgress(1.0)
            await MainActor.run {
                lastSyncDate = Date()
                saveLastSyncDate()
            }

            print("✅ Full sync completed successfully")

        } catch {
            print("❌ Sync failed: \(error)")
            throw error
        }

        await MainActor.run {
            isSyncing = false
        }
    }

    // MARK: - Commodity Sync

    func syncCommodities() async throws {
        print("🌾 Syncing commodities...")

        // Fetch from scraping service
        let scrapedData = try await scrapingService.scrapeCommodityPrices()

        // Save to CoreData
        await persistence.performBackgroundTask { context in
            for scraped in scrapedData {
                // Check if commodity already exists
                let fetchRequest: NSFetchRequest<CommodityEntity> = CommodityEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "symbol == %@", scraped.symbol)

                if let existing = try? context.fetch(fetchRequest).first {
                    // Update existing
                    existing.currentPrice = scraped.price
                    existing.dayChange = scraped.change
                    existing.dayChangePercent = scraped.changePercent
                    existing.lastUpdated = scraped.timestamp
                    existing.lastSyncDate = Date()

                    if let volume = scraped.volume {
                        existing.volume = volume
                    }
                } else {
                    // Create new
                    let newEntity = CommodityEntity(context: context)
                    newEntity.id = UUID().uuidString
                    newEntity.symbol = scraped.symbol
                    newEntity.name = scraped.name
                    newEntity.currentPrice = scraped.price
                    newEntity.previousClose = scraped.price - scraped.change
                    newEntity.dayChange = scraped.change
                    newEntity.dayChangePercent = scraped.changePercent
                    newEntity.volume = scraped.volume ?? 0
                    newEntity.category = self.determineCommodityCategory(scraped.symbol)
                    newEntity.unit = scraped.unit
                    newEntity.lastUpdated = scraped.timestamp
                    newEntity.lastSyncDate = Date()
                    newEntity.isFavorite = false
                }

                // Save price history
                self.savePriceHistory(scraped: scraped, context: context)
            }

            try? context.save()
        }

        print("✅ Commodities synced: \(scrapedData.count) items")
    }

    private func savePriceHistory(scraped: ScrapedCommodityData, context: NSManagedObjectContext) {
        let priceEntity = PriceDataEntity(context: context)
        priceEntity.id = UUID().uuidString
        priceEntity.commodityId = scraped.symbol
        priceEntity.timestamp = scraped.timestamp
        priceEntity.open = scraped.price
        priceEntity.high = scraped.price + abs(scraped.change) * 0.5
        priceEntity.low = scraped.price - abs(scraped.change) * 0.5
        priceEntity.close = scraped.price
        priceEntity.volume = scraped.volume ?? 0
        priceEntity.averagePrice = scraped.price
    }

    // MARK: - News Sync

    func syncNews() async throws {
        print("📰 Syncing news...")

        let scrapedNews = try await scrapingService.scrapeAgriculturalNews()

        await persistence.performBackgroundTask { context in
            for scraped in scrapedNews {
                // Check if news already exists by URL
                let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "url == %@", scraped.url)

                if (try? context.fetch(fetchRequest).first) == nil {
                    // Create new news entity
                    let newsEntity = NewsEntity(context: context)
                    newsEntity.id = UUID().uuidString
                    newsEntity.title = scraped.title
                    newsEntity.summary = scraped.summary
                    newsEntity.content = scraped.summary // Full content would require additional scraping
                    newsEntity.source = scraped.source
                    newsEntity.author = nil
                    newsEntity.publishedAt = scraped.publishedAt
                    newsEntity.imageUrl = scraped.imageUrl
                    newsEntity.category = scraped.category
                    newsEntity.sentiment = self.determineSentiment(from: scraped.title)
                    newsEntity.url = scraped.url
                    newsEntity.isRead = false
                }
            }

            try? context.save()
        }

        print("✅ News synced: \(scrapedNews.count) articles")
    }

    // MARK: - Weather Sync

    func syncWeather() async throws {
        print("🌤️ Syncing weather...")

        let regions = [
            "Chicago, IL",
            "Des Moines, IA",
            "São Paulo, Brazil",
            "Buenos Aires, Argentina",
            "Paris, France"
        ]

        let weatherData = try await scrapingService.scrapeWeatherData(for: regions)

        await persistence.performBackgroundTask { context in
            for scraped in weatherData {
                let fetchRequest: NSFetchRequest<WeatherDataEntity> = WeatherDataEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "region == %@", scraped.region)

                if let existing = try? context.fetch(fetchRequest).first {
                    // Update existing
                    existing.temperature = scraped.temperature
                    existing.humidity = Int16(scraped.humidity)
                    existing.precipitation = scraped.precipitation
                    existing.windSpeed = scraped.windSpeed
                    existing.weatherCondition = scraped.condition
                    existing.timestamp = scraped.timestamp
                } else {
                    // Create new
                    let weatherEntity = WeatherDataEntity(context: context)
                    weatherEntity.id = UUID().uuidString
                    weatherEntity.region = scraped.region
                    weatherEntity.country = scraped.country
                    weatherEntity.temperature = scraped.temperature
                    weatherEntity.humidity = Int16(scraped.humidity)
                    weatherEntity.precipitation = scraped.precipitation
                    weatherEntity.windSpeed = scraped.windSpeed
                    weatherEntity.weatherCondition = scraped.condition
                    weatherEntity.timestamp = scraped.timestamp
                }
            }

            try? context.save()
        }

        print("✅ Weather synced: \(weatherData.count) regions")
    }

    // MARK: - Automatic Sync

    func startAutomaticSync() {
        // Sync commodities every 5 minutes
        Timer.publish(every: commoditySyncInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    try? await self?.syncCommodities()
                }
            }
            .store(in: &cancellables)

        // Sync news every 15 minutes
        Timer.publish(every: newsSyncInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    try? await self?.syncNews()
                }
            }
            .store(in: &cancellables)

        // Sync weather every 30 minutes
        Timer.publish(every: weatherSyncInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    try? await self?.syncWeather()
                }
            }
            .store(in: &cancellables)
    }

    func stopAutomaticSync() {
        cancellables.removeAll()
    }

    // MARK: - Cache Management

    func clearOldData() async {
        let daysToKeep = 30
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -daysToKeep, to: Date())!

        await persistence.performBackgroundTask { context in
            // Delete old price history
            let priceFetch: NSFetchRequest<NSFetchRequestResult> = PriceDataEntity.fetchRequest()
            priceFetch.predicate = NSPredicate(format: "timestamp < %@", cutoffDate as NSDate)

            let deletePrice = NSBatchDeleteRequest(fetchRequest: priceFetch)
            try? context.execute(deletePrice)

            // Delete old news
            let newsFetch: NSFetchRequest<NSFetchRequestResult> = NewsEntity.fetchRequest()
            newsFetch.predicate = NSPredicate(format: "publishedAt < %@", cutoffDate as NSDate)

            let deleteNews = NSBatchDeleteRequest(fetchRequest: newsFetch)
            try? context.execute(deleteNews)

            try? context.save()
        }

        print("✅ Old data cleared (older than \(daysToKeep) days)")
    }

    // MARK: - Helper Methods

    private func determineCommodityCategory(_ symbol: String) -> String {
        let grains = ["ZC", "ZW", "ZO", "ZR"] // Corn, Wheat, Oats, Rice
        let oilseeds = ["ZS", "ZM", "ZL"] // Soybeans, Soybean Meal, Soybean Oil
        let softs = ["KC", "CT", "SB", "CC", "OJ"] // Coffee, Cotton, Sugar, Cocoa, Orange Juice
        let livestock = ["LE", "HE"] // Live Cattle, Lean Hogs

        if grains.contains(symbol) {
            return "Grains"
        } else if oilseeds.contains(symbol) {
            return "Oilseeds"
        } else if softs.contains(symbol) {
            return "Softs"
        } else if livestock.contains(symbol) {
            return "Livestock"
        }

        return "Grains" // Default
    }

    private func determineSentiment(from text: String) -> String {
        let bullishWords = ["surge", "rally", "gain", "rise", "up", "higher", "increase", "boom", "strong"]
        let bearishWords = ["fall", "drop", "decline", "down", "lower", "decrease", "crash", "weak", "plunge"]

        let lowercased = text.lowercased()
        var bullishScore = 0
        var bearishScore = 0

        for word in bullishWords {
            if lowercased.contains(word) {
                bullishScore += 1
            }
        }

        for word in bearishWords {
            if lowercased.contains(word) {
                bearishScore += 1
            }
        }

        if bullishScore > bearishScore {
            return "Bullish"
        } else if bearishScore > bullishScore {
            return "Bearish"
        } else {
            return "Neutral"
        }
    }

    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            syncProgress = progress
        }
    }

    // MARK: - UserDefaults

    private func loadLastSyncDate() {
        if let date = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date {
            lastSyncDate = date
        }
    }

    private func saveLastSyncDate() {
        UserDefaults.standard.set(lastSyncDate, forKey: "lastSyncDate")
    }

    // MARK: - Check if sync needed

    func isSyncNeeded() -> Bool {
        guard let lastSync = lastSyncDate else { return true }
        let timeSinceSync = Date().timeIntervalSince(lastSync)
        return timeSinceSync > commoditySyncInterval
    }
}
