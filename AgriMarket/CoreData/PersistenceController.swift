//
//  PersistenceController.swift
//  AgriMarket
//
//  CoreData stack and persistence management
//

import CoreData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // Preview instance for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // Create sample data for previews
        for i in 0..<5 {
            let commodity = CommodityEntity(context: context)
            commodity.id = "COMMODITY_\(i)"
            commodity.name = "Sample Commodity \(i)"
            commodity.symbol = "SYM\(i)"
            commodity.category = "Grains"
            commodity.currentPrice = Double.random(in: 100...500)
            commodity.previousClose = Double.random(in: 100...500)
            commodity.dayChange = Double.random(in: -10...10)
            commodity.dayChangePercent = Double.random(in: -5...5)
            commodity.volume = Double.random(in: 10000...100000)
            commodity.unit = "MT"
            commodity.lastUpdated = Date()
            commodity.lastSyncDate = Date()
            commodity.isFavorite = false
        }

        try? context.save()
        return controller
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AgriMarket")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save Context
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // MARK: - Background Context
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }

    // MARK: - Batch Delete
    func deleteAll<T: NSManagedObject>(entity: T.Type) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        let context = container.viewContext
        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult

        if let objectIDArray = result?.result as? [NSManagedObjectID] {
            let changes = [NSDeletedObjectsKey: objectIDArray]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        }
    }
}

// MARK: - Core Data Entity Extensions

extension CommodityEntity {
    func toDomain() -> Commodity {
        Commodity(
            id: id ?? "",
            name: name ?? "",
            symbol: symbol ?? "",
            category: CommodityCategory(rawValue: category ?? "") ?? .grains,
            description: "",
            unit: MeasurementUnit(rawValue: unit ?? "") ?? .metricTon,
            currentPrice: currentPrice,
            previousClose: previousClose,
            dayChange: dayChange,
            dayChangePercent: dayChangePercent,
            volume: volume,
            marketCap: marketCap,
            lastUpdated: lastUpdated ?? Date(),
            origins: [],
            destinations: []
        )
    }

    static func fromDomain(_ commodity: Commodity, context: NSManagedObjectContext) -> CommodityEntity {
        let entity = CommodityEntity(context: context)
        entity.id = commodity.id
        entity.name = commodity.name
        entity.symbol = commodity.symbol
        entity.category = commodity.category.rawValue
        entity.currentPrice = commodity.currentPrice
        entity.previousClose = commodity.previousClose
        entity.dayChange = commodity.dayChange
        entity.dayChangePercent = commodity.dayChangePercent
        entity.volume = commodity.volume
        entity.marketCap = commodity.marketCap
        entity.unit = commodity.unit.rawValue
        entity.lastUpdated = commodity.lastUpdated
        entity.lastSyncDate = Date()
        entity.isFavorite = false
        return entity
    }
}

extension PriceDataEntity {
    func toDomain() -> PriceData {
        PriceData(
            id: id ?? "",
            commodityId: commodityId ?? "",
            timestamp: timestamp ?? Date(),
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume,
            averagePrice: averagePrice
        )
    }

    static func fromDomain(_ priceData: PriceData, context: NSManagedObjectContext) -> PriceDataEntity {
        let entity = PriceDataEntity(context: context)
        entity.id = priceData.id
        entity.commodityId = priceData.commodityId
        entity.timestamp = priceData.timestamp
        entity.open = priceData.open
        entity.high = priceData.high
        entity.low = priceData.low
        entity.close = priceData.close
        entity.volume = priceData.volume
        entity.averagePrice = priceData.averagePrice
        return entity
    }
}

extension NewsEntity {
    func toDomain() -> NewsArticle {
        NewsArticle(
            id: id ?? "",
            title: title ?? "",
            summary: summary ?? "",
            content: content ?? "",
            source: source ?? "",
            author: author,
            publishedAt: publishedAt ?? Date(),
            imageUrl: imageUrl,
            category: NewsCategory(rawValue: category ?? "") ?? .marketAnalysis,
            relatedCommodities: [],
            sentiment: NewsSentiment(rawValue: sentiment ?? "") ?? .neutral,
            tags: [],
            url: url ?? ""
        )
    }
}

extension PriceAlertEntity {
    func toDomain() -> PriceAlert {
        PriceAlert(
            id: id ?? "",
            commodityId: commodityId ?? "",
            commodityName: commodityName ?? "",
            targetPrice: targetPrice,
            condition: PriceAlert.AlertCondition(rawValue: condition ?? "") ?? .above,
            isActive: isActive,
            createdAt: createdAt ?? Date(),
            triggeredAt: triggeredAt
        )
    }
}
