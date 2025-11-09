//
//  TradeFlow.swift
//  AgriMarket
//
//  Global trade flow tracking similar to Kpler
//

import Foundation

struct TradeFlow: Identifiable, Codable {
    let id: String
    let commodityId: String
    let commodityName: String
    let origin: Country
    let destination: Country
    let volume: Double
    let unit: MeasurementUnit
    let shipmentDate: Date
    let estimatedArrival: Date
    let status: ShipmentStatus
    let vessel: VesselInfo?
    let route: TradeRoute
    let value: Double
    let currency: Currency

    var durationDays: Int {
        Calendar.current.dateComponents([.day], from: shipmentDate, to: estimatedArrival).day ?? 0
    }

    var formattedValue: String {
        "\(currency.symbol)\(String(format: "%.2f", value))M"
    }
}

struct Country: Codable, Hashable {
    let code: String
    let name: String
    let flag: String
    let region: MarketRegion
}

struct VesselInfo: Codable {
    let name: String
    let type: VesselType
    let capacity: Double
    let currentLocation: Location?

    enum VesselType: String, Codable {
        case bulkCarrier = "Bulk Carrier"
        case container = "Container Ship"
        case tanker = "Tanker"
        case general = "General Cargo"
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let name: String?
}

struct TradeRoute: Codable {
    let departurePort: Port
    let arrivalPort: Port
    let distance: Double // nautical miles
    let waypoints: [Location]
}

struct Port: Codable {
    let code: String
    let name: String
    let country: String
    let location: Location
}

enum ShipmentStatus: String, Codable {
    case scheduled = "Scheduled"
    case loading = "Loading"
    case inTransit = "In Transit"
    case arrived = "Arrived"
    case delayed = "Delayed"
    case cancelled = "Cancelled"

    var icon: String {
        switch self {
        case .scheduled: return "calendar"
        case .loading: return "arrow.down.doc.fill"
        case .inTransit: return "airplane"
        case .arrived: return "checkmark.circle.fill"
        case .delayed: return "exclamationmark.triangle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .scheduled: return "blue"
        case .loading: return "orange"
        case .inTransit: return "green"
        case .arrived: return "green"
        case .delayed: return "yellow"
        case .cancelled: return "red"
        }
    }
}

struct TradeStatistics: Codable {
    let commodityId: String
    let period: String
    let totalVolume: Double
    let totalValue: Double
    let topExporters: [CountryVolume]
    let topImporters: [CountryVolume]
    let averagePrice: Double
    let growthRate: Double
}

struct CountryVolume: Identifiable, Codable {
    let id: String
    let country: Country
    let volume: Double
    let value: Double
    let marketShare: Double
}

// MARK: - Sample Data
extension TradeFlow {
    static let sampleData: [TradeFlow] = [
        TradeFlow(
            id: UUID().uuidString,
            commodityId: "CORN",
            commodityName: "Corn",
            origin: Country(code: "US", name: "United States", flag: "🇺🇸", region: .northAmerica),
            destination: Country(code: "CN", name: "China", flag: "🇨🇳", region: .asia),
            volume: 50000,
            unit: .metricTon,
            shipmentDate: Date().addingTimeInterval(-86400 * 5),
            estimatedArrival: Date().addingTimeInterval(86400 * 20),
            status: .inTransit,
            vessel: VesselInfo(
                name: "Pacific Glory",
                type: .bulkCarrier,
                capacity: 75000,
                currentLocation: Location(latitude: 35.5, longitude: -150.2, name: "Pacific Ocean")
            ),
            route: TradeRoute(
                departurePort: Port(
                    code: "USNYC",
                    name: "New York",
                    country: "USA",
                    location: Location(latitude: 40.7128, longitude: -74.0060, name: "New York Port")
                ),
                arrivalPort: Port(
                    code: "CNSHA",
                    name: "Shanghai",
                    country: "China",
                    location: Location(latitude: 31.2304, longitude: 121.4737, name: "Shanghai Port")
                ),
                distance: 6500,
                waypoints: []
            ),
            value: 12.5,
            currency: .usd
        ),
        TradeFlow(
            id: UUID().uuidString,
            commodityId: "SOYBEANS",
            commodityName: "Soybeans",
            origin: Country(code: "BR", name: "Brazil", flag: "🇧🇷", region: .southAmerica),
            destination: Country(code: "EU", name: "European Union", flag: "🇪🇺", region: .europe),
            volume: 65000,
            unit: .metricTon,
            shipmentDate: Date().addingTimeInterval(-86400 * 10),
            estimatedArrival: Date().addingTimeInterval(86400 * 15),
            status: .inTransit,
            vessel: VesselInfo(
                name: "Atlantic Trader",
                type: .bulkCarrier,
                capacity: 80000,
                currentLocation: Location(latitude: 20.5, longitude: -40.2, name: "Atlantic Ocean")
            ),
            route: TradeRoute(
                departurePort: Port(
                    code: "BRSSZ",
                    name: "Santos",
                    country: "Brazil",
                    location: Location(latitude: -23.9608, longitude: -46.3336, name: "Santos Port")
                ),
                arrivalPort: Port(
                    code: "NLRTM",
                    name: "Rotterdam",
                    country: "Netherlands",
                    location: Location(latitude: 51.9244, longitude: 4.4777, name: "Rotterdam Port")
                ),
                distance: 5800,
                waypoints: []
            ),
            value: 28.3,
            currency: .usd
        )
    ]
}
