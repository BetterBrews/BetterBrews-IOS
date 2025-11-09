//
//  CommodityService.swift
//  AgriMarket
//
//  Service for commodity data and prices
//

import Foundation
import Combine

class CommodityService {
    static let shared = CommodityService()
    private let networkManager = NetworkManager.shared

    private init() {}

    // MARK: - Fetch Commodities
    func fetchCommodities() async throws -> [Commodity] {
        // In production, this would call the real API
        // For now, return sample data with a simulated network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        return Commodity.sampleData
    }

    func fetchCommodity(id: String) async throws -> Commodity {
        // Simulate API call
        try await Task.sleep(nanoseconds: 300_000_000)
        guard let commodity = Commodity.sampleData.first(where: { $0.id == id }) else {
            throw NetworkError.notFound
        }
        return commodity
    }

    // MARK: - Fetch Price Data
    func fetchPriceHistory(
        commodityId: String,
        timeframe: TimeFrame
    ) async throws -> PriceHistory {
        // Simulate API call
        try await Task.sleep(nanoseconds: 400_000_000)

        let days = daysForTimeframe(timeframe)
        let priceData = PriceData.generateSampleData(for: commodityId, days: days)

        return PriceHistory(
            commodityId: commodityId,
            timeframe: timeframe,
            data: priceData
        )
    }

    func fetchRealTimePrice(commodityId: String) async throws -> Double {
        // Simulate real-time price update
        try await Task.sleep(nanoseconds: 100_000_000)
        guard let commodity = Commodity.sampleData.first(where: { $0.id == commodityId }) else {
            throw NetworkError.notFound
        }
        // Add some random variation
        let variation = Double.random(in: -2...2)
        return commodity.currentPrice + variation
    }

    // MARK: - Search
    func searchCommodities(query: String) async throws -> [Commodity] {
        try await Task.sleep(nanoseconds: 200_000_000)
        return Commodity.sampleData.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.symbol.localizedCaseInsensitiveContains(query) ||
            $0.category.rawValue.localizedCaseInsensitiveContains(query)
        }
    }

    func fetchCommoditiesByCategory(_ category: CommodityCategory) async throws -> [Commodity] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return Commodity.sampleData.filter { $0.category == category }
    }

    // MARK: - Market Statistics
    func fetchMarketStatistics(commodityId: String) async throws -> MarketStatistics {
        try await Task.sleep(nanoseconds: 400_000_000)
        guard let commodity = Commodity.sampleData.first(where: { $0.id == commodityId }) else {
            throw NetworkError.notFound
        }

        return MarketStatistics(
            commodityId: commodityId,
            weekHigh: commodity.currentPrice * 1.15,
            weekLow: commodity.currentPrice * 0.92,
            monthHigh: commodity.currentPrice * 1.25,
            monthLow: commodity.currentPrice * 0.85,
            yearHigh: commodity.currentPrice * 1.45,
            yearLow: commodity.currentPrice * 0.70,
            averageVolume: commodity.volume,
            beta: 1.2,
            volatility: 0.25
        )
    }

    // MARK: - Helper Methods
    private func daysForTimeframe(_ timeframe: TimeFrame) -> Int {
        switch timeframe {
        case .oneDay: return 1
        case .oneWeek: return 7
        case .oneMonth: return 30
        case .threeMonths: return 90
        case .sixMonths: return 180
        case .oneYear: return 365
        case .ytd:
            let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))!
            return Calendar.current.dateComponents([.day], from: startOfYear, to: Date()).day ?? 30
        case .all: return 730 // 2 years
        }
    }
}

// MARK: - Market Statistics Model
struct MarketStatistics: Codable {
    let commodityId: String
    let weekHigh: Double
    let weekLow: Double
    let monthHigh: Double
    let monthLow: Double
    let yearHigh: Double
    let yearLow: Double
    let averageVolume: Double
    let beta: Double
    let volatility: Double
}
