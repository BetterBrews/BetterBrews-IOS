//
//  PriceData.swift
//  AgriMarket
//
//  Price history and data points
//

import Foundation

struct PriceData: Identifiable, Codable {
    let id: String
    let commodityId: String
    let timestamp: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    let averagePrice: Double

    var priceRange: Double {
        high - low
    }

    var isUpDay: Bool {
        close > open
    }
}

struct PriceHistory: Codable {
    let commodityId: String
    let timeframe: TimeFrame
    let data: [PriceData]

    var latestPrice: Double? {
        data.last?.close
    }

    var highestPrice: Double? {
        data.map { $0.high }.max()
    }

    var lowestPrice: Double? {
        data.map { $0.low }.min()
    }

    var averageVolume: Double {
        guard !data.isEmpty else { return 0 }
        return data.map { $0.volume }.reduce(0, +) / Double(data.count)
    }
}

enum TimeFrame: String, Codable, CaseIterable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case ytd = "YTD"
    case all = "All"

    var displayName: String {
        switch self {
        case .oneDay: return "1 Day"
        case .oneWeek: return "1 Week"
        case .oneMonth: return "1 Month"
        case .threeMonths: return "3 Months"
        case .sixMonths: return "6 Months"
        case .oneYear: return "1 Year"
        case .ytd: return "Year to Date"
        case .all: return "All Time"
        }
    }
}

struct PriceAlert: Identifiable, Codable {
    let id: String
    let commodityId: String
    let commodityName: String
    let targetPrice: Double
    let condition: AlertCondition
    let isActive: Bool
    let createdAt: Date
    var triggeredAt: Date?

    enum AlertCondition: String, Codable {
        case above = "Above"
        case below = "Below"

        var symbol: String {
            switch self {
            case .above: return "↑"
            case .below: return "↓"
            }
        }
    }
}

// MARK: - Sample Data
extension PriceData {
    static func generateSampleData(for commodityId: String, days: Int = 30) -> [PriceData] {
        var data: [PriceData] = []
        var currentPrice = 100.0

        for day in 0..<days {
            let date = Calendar.current.date(byAdding: .day, value: -days + day, to: Date())!
            let volatility = Double.random(in: -5...5)
            currentPrice += volatility

            let open = currentPrice
            let high = currentPrice + Double.random(in: 0...3)
            let low = currentPrice - Double.random(in: 0...3)
            let close = Double.random(in: low...high)
            let volume = Double.random(in: 50000...150000)

            data.append(PriceData(
                id: UUID().uuidString,
                commodityId: commodityId,
                timestamp: date,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume,
                averagePrice: (high + low) / 2
            ))

            currentPrice = close
        }

        return data
    }
}
