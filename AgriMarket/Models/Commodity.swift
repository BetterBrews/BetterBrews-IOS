//
//  Commodity.swift
//  AgriMarket
//
//  Core commodity model
//

import Foundation

struct Commodity: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let category: CommodityCategory
    let description: String
    let unit: MeasurementUnit
    let currentPrice: Double
    let previousClose: Double
    let dayChange: Double
    let dayChangePercent: Double
    let volume: Double
    let marketCap: Double?
    let lastUpdated: Date
    let origins: [String] // Major producing countries
    let destinations: [String] // Major consuming countries

    var changeColor: String {
        dayChange >= 0 ? "green" : "red"
    }

    var formattedPrice: String {
        String(format: "$%.2f", currentPrice)
    }

    var formattedChange: String {
        String(format: "%+.2f%%", dayChangePercent)
    }
}

enum CommodityCategory: String, Codable, CaseIterable {
    case grains = "Grains"
    case oilseeds = "Oilseeds"
    case softs = "Softs"
    case livestock = "Livestock"
    case dairy = "Dairy"
    case fertilizers = "Fertilizers"
    case energy = "Energy"
    case metals = "Metals"

    var icon: String {
        switch self {
        case .grains: return "leaf.fill"
        case .oilseeds: return "drop.fill"
        case .softs: return "cup.and.saucer.fill"
        case .livestock: return "pawprint.fill"
        case .dairy: return "cup.and.saucer"
        case .fertilizers: return "flask.fill"
        case .energy: return "bolt.fill"
        case .metals: return "circle.hexagongrid.fill"
        }
    }
}

enum MeasurementUnit: String, Codable {
    case bushel = "bu"
    case metricTon = "MT"
    case pound = "lb"
    case cwt = "cwt" // hundredweight
    case gallon = "gal"
    case barrel = "bbl"
    case ton = "ton"

    var fullName: String {
        switch self {
        case .bushel: return "Bushel"
        case .metricTon: return "Metric Ton"
        case .pound: return "Pound"
        case .cwt: return "Hundredweight"
        case .gallon: return "Gallon"
        case .barrel: return "Barrel"
        case .ton: return "Ton"
        }
    }
}

// MARK: - Sample Data
extension Commodity {
    static let sampleData: [Commodity] = [
        Commodity(
            id: "CORN",
            name: "Corn",
            symbol: "ZC",
            category: .grains,
            description: "Yellow Corn No. 2",
            unit: .bushel,
            currentPrice: 485.50,
            previousClose: 478.25,
            dayChange: 7.25,
            dayChangePercent: 1.52,
            volume: 125000,
            marketCap: 45000000000,
            lastUpdated: Date(),
            origins: ["USA", "Brazil", "Argentina", "Ukraine"],
            destinations: ["China", "Japan", "Mexico", "EU"]
        ),
        Commodity(
            id: "WHEAT",
            name: "Wheat",
            symbol: "ZW",
            category: .grains,
            description: "Soft Red Winter Wheat",
            unit: .bushel,
            currentPrice: 642.75,
            previousClose: 648.50,
            dayChange: -5.75,
            dayChangePercent: -0.89,
            volume: 98000,
            marketCap: 38000000000,
            lastUpdated: Date(),
            origins: ["USA", "Russia", "Canada", "France"],
            destinations: ["Egypt", "Indonesia", "Algeria", "China"]
        ),
        Commodity(
            id: "SOYBEANS",
            name: "Soybeans",
            symbol: "ZS",
            category: .oilseeds,
            description: "Yellow Soybeans No. 1",
            unit: .bushel,
            currentPrice: 1345.25,
            previousClose: 1338.00,
            dayChange: 7.25,
            dayChangePercent: 0.54,
            volume: 145000,
            marketCap: 52000000000,
            lastUpdated: Date(),
            origins: ["USA", "Brazil", "Argentina"],
            destinations: ["China", "EU", "Mexico"]
        ),
        Commodity(
            id: "COFFEE",
            name: "Coffee",
            symbol: "KC",
            category: .softs,
            description: "Arabica Coffee",
            unit: .pound,
            currentPrice: 178.50,
            previousClose: 175.20,
            dayChange: 3.30,
            dayChangePercent: 1.88,
            volume: 32000,
            marketCap: 15000000000,
            lastUpdated: Date(),
            origins: ["Brazil", "Vietnam", "Colombia", "Indonesia"],
            destinations: ["USA", "EU", "Japan"]
        ),
        Commodity(
            id: "COTTON",
            name: "Cotton",
            symbol: "CT",
            category: .softs,
            description: "Cotton No. 2",
            unit: .pound,
            currentPrice: 82.35,
            previousClose: 83.10,
            dayChange: -0.75,
            dayChangePercent: -0.90,
            volume: 28000,
            marketCap: 12000000000,
            lastUpdated: Date(),
            origins: ["USA", "India", "China", "Brazil"],
            destinations: ["China", "Bangladesh", "Vietnam"]
        ),
        Commodity(
            id: "SUGAR",
            name: "Sugar",
            symbol: "SB",
            category: .softs,
            description: "Sugar No. 11",
            unit: .pound,
            currentPrice: 24.68,
            previousClose: 24.52,
            dayChange: 0.16,
            dayChangePercent: 0.65,
            volume: 52000,
            marketCap: 18000000000,
            lastUpdated: Date(),
            origins: ["Brazil", "India", "Thailand", "China"],
            destinations: ["China", "Indonesia", "USA", "UAE"]
        )
    ]
}
