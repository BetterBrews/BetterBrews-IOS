//
//  TradeFlowService.swift
//  AgriMarket
//
//  Service for global trade flow tracking
//

import Foundation

class TradeFlowService {
    static let shared = TradeFlowService()
    private let networkManager = NetworkManager.shared

    private init() {}

    // MARK: - Fetch Trade Flows
    func fetchTradeFlows(
        commodityId: String? = nil,
        status: ShipmentStatus? = nil
    ) async throws -> [TradeFlow] {
        try await Task.sleep(nanoseconds: 500_000_000)

        var flows = TradeFlow.sampleData

        if let commodityId = commodityId {
            flows = flows.filter { $0.commodityId == commodityId }
        }

        if let status = status {
            flows = flows.filter { $0.status == status }
        }

        return flows
    }

    func fetchTradeFlow(id: String) async throws -> TradeFlow {
        try await Task.sleep(nanoseconds: 200_000_000)
        guard let flow = TradeFlow.sampleData.first(where: { $0.id == id }) else {
            throw NetworkError.notFound
        }
        return flow
    }

    // MARK: - Trade Statistics
    func fetchTradeStatistics(
        commodityId: String,
        period: String = "2024"
    ) async throws -> TradeStatistics {
        try await Task.sleep(nanoseconds: 400_000_000)

        return TradeStatistics(
            commodityId: commodityId,
            period: period,
            totalVolume: 5000000,
            totalValue: 2500000000,
            topExporters: [
                CountryVolume(
                    id: "US",
                    country: Country(code: "US", name: "United States", flag: "🇺🇸", region: .northAmerica),
                    volume: 2000000,
                    value: 1000000000,
                    marketShare: 40.0
                ),
                CountryVolume(
                    id: "BR",
                    country: Country(code: "BR", name: "Brazil", flag: "🇧🇷", region: .southAmerica),
                    volume: 1500000,
                    value: 750000000,
                    marketShare: 30.0
                ),
                CountryVolume(
                    id: "AR",
                    country: Country(code: "AR", name: "Argentina", flag: "🇦🇷", region: .southAmerica),
                    volume: 1000000,
                    value: 500000000,
                    marketShare: 20.0
                )
            ],
            topImporters: [
                CountryVolume(
                    id: "CN",
                    country: Country(code: "CN", name: "China", flag: "🇨🇳", region: .asia),
                    volume: 2500000,
                    value: 1250000000,
                    marketShare: 50.0
                ),
                CountryVolume(
                    id: "EU",
                    country: Country(code: "EU", name: "European Union", flag: "🇪🇺", region: .europe),
                    volume: 1000000,
                    value: 500000000,
                    marketShare: 20.0
                )
            ],
            averagePrice: 500.0,
            growthRate: 5.5
        )
    }

    // MARK: - Routes
    func fetchActiveRoutes() async throws -> [TradeRoute] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return TradeFlow.sampleData.map { $0.route }
    }

    func fetchRoutesByOrigin(countryCode: String) async throws -> [TradeFlow] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return TradeFlow.sampleData.filter { $0.origin.code == countryCode }
    }

    func fetchRoutesByDestination(countryCode: String) async throws -> [TradeFlow] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return TradeFlow.sampleData.filter { $0.destination.code == countryCode }
    }
}
