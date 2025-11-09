//
//  Market.swift
//  AgriMarket
//
//  Market and exchange information
//

import Foundation

struct Market: Identifiable, Codable {
    let id: String
    let name: String
    let country: String
    let region: MarketRegion
    let currency: Currency
    let timezone: String
    let isOpen: Bool
    let openTime: String
    let closeTime: String
    let marketIndices: [MarketIndex]
}

enum MarketRegion: String, Codable, CaseIterable {
    case northAmerica = "North America"
    case southAmerica = "South America"
    case europe = "Europe"
    case asia = "Asia"
    case africa = "Africa"
    case oceania = "Oceania"

    var icon: String {
        switch self {
        case .northAmerica: return "🇺🇸"
        case .southAmerica: return "🇧🇷"
        case .europe: return "🇪🇺"
        case .asia: return "🇨🇳"
        case .africa: return "🌍"
        case .oceania: return "🇦🇺"
        }
    }
}

struct MarketIndex: Identifiable, Codable {
    let id: String
    let name: String
    let value: Double
    let change: Double
    let changePercent: Double
}

enum Currency: String, Codable, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case cny = "CNY"
    case brl = "BRL"
    case cad = "CAD"
    case aud = "AUD"

    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .cny: return "¥"
        case .brl: return "R$"
        case .cad: return "C$"
        case .aud: return "A$"
        }
    }
}

// MARK: - Sample Data
extension Market {
    static let sampleData: [Market] = [
        Market(
            id: "CBOT",
            name: "Chicago Board of Trade",
            country: "USA",
            region: .northAmerica,
            currency: .usd,
            timezone: "CST",
            isOpen: true,
            openTime: "08:30",
            closeTime: "13:15",
            marketIndices: [
                MarketIndex(id: "GRAINS", name: "Grains Index", value: 1245.50, change: 12.30, changePercent: 0.99)
            ]
        ),
        Market(
            id: "EURONEXT",
            name: "Euronext",
            country: "EU",
            region: .europe,
            currency: .eur,
            timezone: "CET",
            isOpen: false,
            openTime: "09:00",
            closeTime: "17:30",
            marketIndices: [
                MarketIndex(id: "AGRI", name: "Agricultural Index", value: 892.30, change: -5.20, changePercent: -0.58)
            ]
        ),
        Market(
            id: "DCE",
            name: "Dalian Commodity Exchange",
            country: "China",
            region: .asia,
            currency: .cny,
            timezone: "CST",
            isOpen: false,
            openTime: "09:00",
            closeTime: "15:00",
            marketIndices: [
                MarketIndex(id: "AGRI_CN", name: "China Agri Index", value: 3245.80, change: 28.50, changePercent: 0.89)
            ]
        )
    ]
}
