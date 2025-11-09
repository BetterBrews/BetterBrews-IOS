//
//  CommodityViewModel.swift
//  AgriMarket
//
//  ViewModel for Commodities
//

import Foundation
import Combine

@MainActor
class CommodityViewModel: ObservableObject {
    @Published var commodities: [Commodity] = []
    @Published var filteredCommodities: [Commodity] = []
    @Published var selectedCategory: CommodityCategory?
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let commodityService = CommodityService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSearchObserver()
    }

    func loadCommodities() async {
        isLoading = true
        errorMessage = nil

        do {
            commodities = try await commodityService.fetchCommodities()
            applyFilters()
        } catch {
            errorMessage = "Failed to load commodities: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func selectCategory(_ category: CommodityCategory?) {
        selectedCategory = category
        applyFilters()
    }

    private func setupSearchObserver() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }

    private func applyFilters() {
        var result = commodities

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }

        filteredCommodities = result
    }
}

@MainActor
class CommodityDetailViewModel: ObservableObject {
    @Published var commodity: Commodity?
    @Published var priceHistory: PriceHistory?
    @Published var marketStatistics: MarketStatistics?
    @Published var relatedNews: [NewsArticle] = []
    @Published var selectedTimeframe: TimeFrame = .oneMonth
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let commodityService = CommodityService.shared
    private let newsService = NewsService.shared
    let commodityId: String

    init(commodityId: String) {
        self.commodityId = commodityId
    }

    func loadCommodityDetails() async {
        isLoading = true
        errorMessage = nil

        do {
            async let commodityData = commodityService.fetchCommodity(id: commodityId)
            async let priceData = commodityService.fetchPriceHistory(commodityId: commodityId, timeframe: selectedTimeframe)
            async let stats = commodityService.fetchMarketStatistics(commodityId: commodityId)
            async let news = newsService.fetchNews(commodityId: commodityId, limit: 10)

            let (loadedCommodity, loadedPriceHistory, loadedStats, loadedNews) = try await (commodityData, priceData, stats, news)

            commodity = loadedCommodity
            priceHistory = loadedPriceHistory
            marketStatistics = loadedStats
            relatedNews = loadedNews
        } catch {
            errorMessage = "Failed to load commodity details: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func changeTimeframe(_ timeframe: TimeFrame) async {
        selectedTimeframe = timeframe
        do {
            priceHistory = try await commodityService.fetchPriceHistory(
                commodityId: commodityId,
                timeframe: timeframe
            )
        } catch {
            errorMessage = "Failed to load price history: \(error.localizedDescription)"
        }
    }
}
