//
//  CommodityRepository.swift
//  AgriMarket
//
//  Repository pattern for commodity data access
//

import Foundation
import CoreData
import Combine

class CommodityRepository: ObservableObject {
    static let shared = CommodityRepository()

    private let persistence = PersistenceController.shared
    private let syncService = DataSyncService.shared

    @Published var commodities: [Commodity] = []
    @Published var favoriteCommodities: [Commodity] = []

    private init() {}

    // MARK: - Fetch Commodities

    func fetchAllCommodities() async throws -> [Commodity] {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<CommodityEntity> = CommodityEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CommodityEntity.name, ascending: true)]

        let entities = try context.fetch(fetchRequest)
        return entities.map { $0.toDomain() }
    }

    func fetchCommodity(id: String) async throws -> Commodity? {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<CommodityEntity> = CommodityEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1

        if let entity = try context.fetch(fetchRequest).first {
            return entity.toDomain()
        }

        return nil
    }

    func fetchCommoditiesByCategory(_ category: CommodityCategory) async throws -> [Commodity] {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<CommodityEntity> = CommodityEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CommodityEntity.name, ascending: true)]

        let entities = try context.fetch(fetchRequest)
        return entities.map { $0.toDomain() }
    }

    func fetchFavoriteCommodities() async throws -> [Commodity] {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<CommodityEntity> = CommodityEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isFavorite == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CommodityEntity.name, ascending: true)]

        let entities = try context.fetch(fetchRequest)
        return entities.map { $0.toDomain() }
    }

    func searchCommodities(query: String) async throws -> [Commodity] {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<CommodityEntity> = CommodityEntity.fetchRequest()

        let namePredicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        let symbolPredicate = NSPredicate(format: "symbol CONTAINS[cd] %@", query)
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [namePredicate, symbolPredicate])

        let entities = try context.fetch(fetchRequest)
        return entities.map { $0.toDomain() }
    }

    // MARK: - Price History

    func fetchPriceHistory(commodityId: String, timeframe: TimeFrame) async throws -> [PriceData] {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<PriceDataEntity> = PriceDataEntity.fetchRequest()

        let startDate = calculateStartDate(for: timeframe)
        fetchRequest.predicate = NSPredicate(
            format: "commodityId == %@ AND timestamp >= %@",
            commodityId,
            startDate as NSDate
        )
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PriceDataEntity.timestamp, ascending: true)]

        let entities = try context.fetch(fetchRequest)
        return entities.map { $0.toDomain() }
    }

    private func calculateStartDate(for timeframe: TimeFrame) -> Date {
        let calendar = Calendar.current
        let now = Date()

        switch timeframe {
        case .oneDay:
            return calendar.date(byAdding: .day, value: -1, to: now)!
        case .oneWeek:
            return calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
        case .oneMonth:
            return calendar.date(byAdding: .month, value: -1, to: now)!
        case .threeMonths:
            return calendar.date(byAdding: .month, value: -3, to: now)!
        case .sixMonths:
            return calendar.date(byAdding: .month, value: -6, to: now)!
        case .oneYear:
            return calendar.date(byAdding: .year, value: -1, to: now)!
        case .ytd:
            return calendar.date(from: calendar.dateComponents([.year], from: now))!
        case .all:
            return calendar.date(byAdding: .year, value: -10, to: now)!
        }
    }

    // MARK: - Favorites

    func toggleFavorite(commodityId: String) async throws {
        await persistence.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<CommodityEntity> = CommodityEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", commodityId)

            if let entity = try? context.fetch(fetchRequest).first {
                entity.isFavorite.toggle()
                try? context.save()
            }
        }
    }

    // MARK: - Save/Update

    func saveCommodity(_ commodity: Commodity) async throws {
        await persistence.performBackgroundTask { context in
            _ = CommodityEntity.fromDomain(commodity, context: context)
            try? context.save()
        }
    }

    func saveCommodities(_ commodities: [Commodity]) async throws {
        await persistence.performBackgroundTask { context in
            for commodity in commodities {
                _ = CommodityEntity.fromDomain(commodity, context: context)
            }
            try? context.save()
        }
    }

    // MARK: - Sync with Remote

    func syncFromRemote() async throws {
        try await syncService.syncCommodities()
        let updated = try await fetchAllCommodities()

        await MainActor.run {
            self.commodities = updated
        }
    }

    // MARK: - Statistics

    func getMarketStatistics() async throws -> MarketStatistics {
        let allCommodities = try await fetchAllCommodities()

        let totalGainers = allCommodities.filter { $0.dayChange > 0 }.count
        let totalLosers = allCommodities.filter { $0.dayChange < 0 }.count
        let totalVolume = allCommodities.reduce(0) { $0 + $1.volume }

        // Calculate market sentiment
        let sentiment: Double = Double(totalGainers - totalLosers) / Double(allCommodities.count)

        return MarketStatistics(
            totalCommodities: allCommodities.count,
            gainers: totalGainers,
            losers: totalLosers,
            totalVolume: totalVolume,
            marketSentiment: sentiment
        )
    }

    // MARK: - Analytics

    func getTopPerformers(limit: Int = 5) async throws -> [Commodity] {
        let allCommodities = try await fetchAllCommodities()
        return Array(allCommodities.sorted { $0.dayChangePercent > $1.dayChangePercent }.prefix(limit))
    }

    func getTopLosers(limit: Int = 5) async throws -> [Commodity] {
        let allCommodities = try await fetchAllCommodities()
        return Array(allCommodities.sorted { $0.dayChangePercent < $1.dayChangePercent }.prefix(limit))
    }

    func getHighestVolume(limit: Int = 5) async throws -> [Commodity] {
        let allCommodities = try await fetchAllCommodities()
        return Array(allCommodities.sorted { $0.volume > $1.volume }.prefix(limit))
    }
}

// MARK: - Market Statistics Model

struct MarketStatistics {
    let totalCommodities: Int
    let gainers: Int
    let losers: Int
    let totalVolume: Double
    let marketSentiment: Double // -1 (bearish) to 1 (bullish)
}
