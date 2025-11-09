//
//  NewsRepository.swift
//  AgriMarket
//
//  Repository for news data access
//

import Foundation
import CoreData

class NewsRepository {
    static let shared = NewsRepository()

    private let persistence = PersistenceController.shared
    private let syncService = DataSyncService.shared

    private init() {}

    // MARK: - Fetch News

    func fetchAllNews(limit: Int = 50) async throws -> [NewsArticle] {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \NewsEntity.publishedAt, ascending: false)]
        fetchRequest.fetchLimit = limit

        let entities = try context.fetch(fetchRequest)
        return entities.map { $0.toDomain() }
    }

    func fetchNewsByCategory(_ category: NewsCategory, limit: Int = 20) async throws -> [NewsArticle] {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \NewsEntity.publishedAt, ascending: false)]
        fetchRequest.fetchLimit = limit

        let entities = try context.fetch(fetchRequest)
        return entities.map { $0.toDomain() }
    }

    func fetchNewsBySentiment(_ sentiment: NewsSentiment, limit: Int = 20) async throws -> [NewsArticle] {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sentiment == %@", sentiment.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \NewsEntity.publishedAt, ascending: false)]
        fetchRequest.fetchLimit = limit

        let entities = try context.fetch(fetchRequest)
        return entities.map { $0.toDomain() }
    }

    func fetchUnreadNews() async throws -> [NewsArticle] {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isRead == NO")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \NewsEntity.publishedAt, ascending: false)]

        let entities = try context.fetch(fetchRequest)
        return entities.map { $0.toDomain() }
    }

    func searchNews(query: String) async throws -> [NewsArticle] {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()

        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        let summaryPredicate = NSPredicate(format: "summary CONTAINS[cd] %@", query)
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, summaryPredicate])
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \NewsEntity.publishedAt, ascending: false)]

        let entities = try context.fetch(fetchRequest)
        return entities.map { $0.toDomain() }
    }

    // MARK: - Mark as Read

    func markAsRead(newsId: String) async throws {
        await persistence.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", newsId)

            if let entity = try? context.fetch(fetchRequest).first {
                entity.isRead = true
                try? context.save()
            }
        }
    }

    func markAllAsRead() async throws {
        await persistence.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isRead == NO")

            let entities = try? context.fetch(fetchRequest)
            entities?.forEach { $0.isRead = true }
            try? context.save()
        }
    }

    // MARK: - Sync

    func syncFromRemote() async throws {
        try await syncService.syncNews()
    }

    // MARK: - Statistics

    func getNewsStats() async throws -> NewsStatistics {
        let context = persistence.viewContext

        let totalRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        let totalCount = try context.count(for: totalRequest)

        let unreadRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        unreadRequest.predicate = NSPredicate(format: "isRead == NO")
        let unreadCount = try context.count(for: unreadRequest)

        let bullishRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        bullishRequest.predicate = NSPredicate(format: "sentiment == %@", "Bullish")
        let bullishCount = try context.count(for: bullishRequest)

        let bearishRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        bearishRequest.predicate = NSPredicate(format: "sentiment == %@", "Bearish")
        let bearishCount = try context.count(for: bearishRequest)

        return NewsStatistics(
            total: totalCount,
            unread: unreadCount,
            bullish: bullishCount,
            bearish: bearishCount
        )
    }
}

struct NewsStatistics {
    let total: Int
    let unread: Int
    let bullish: Int
    let bearish: Int

    var marketSentiment: Double {
        guard total > 0 else { return 0 }
        return Double(bullish - bearish) / Double(total)
    }
}
