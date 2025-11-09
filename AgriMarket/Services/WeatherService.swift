//
//  WeatherService.swift
//  AgriMarket
//
//  Service for weather data and forecasts
//

import Foundation

class WeatherService {
    static let shared = WeatherService()
    private let networkManager = NetworkManager.shared

    private init() {}

    // MARK: - Fetch Weather Data
    func fetchWeatherData(for region: String) async throws -> WeatherData {
        try await Task.sleep(nanoseconds: 400_000_000)
        guard let weather = WeatherData.sampleData.first(where: { $0.region == region }) else {
            throw NetworkError.notFound
        }
        return weather
    }

    func fetchWeatherByLocation(latitude: Double, longitude: Double) async throws -> WeatherData {
        try await Task.sleep(nanoseconds: 400_000_000)
        // Return the first sample data for demo
        return WeatherData.sampleData.first!
    }

    // MARK: - Agricultural Regions
    func fetchKeyAgriculturalRegions() async throws -> [WeatherData] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return WeatherData.sampleData
    }

    // MARK: - Weather Alerts
    func fetchWeatherAlerts() async throws -> [WeatherAlert] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return [
            WeatherAlert(
                id: UUID().uuidString,
                region: "Midwest Corn Belt",
                alertType: .frost,
                severity: .moderate,
                message: "Frost warning for tonight. Temperatures expected to drop to -2°C.",
                affectedCrops: ["Corn", "Soybeans"],
                validFrom: Date(),
                validUntil: Date().addingTimeInterval(86400)
            ),
            WeatherAlert(
                id: UUID().uuidString,
                region: "Central Brazil",
                alertType: .drought,
                severity: .high,
                message: "Prolonged drought conditions continue. No significant rainfall expected for next 10 days.",
                affectedCrops: ["Soybeans", "Coffee"],
                validFrom: Date().addingTimeInterval(-86400 * 7),
                validUntil: Date().addingTimeInterval(86400 * 10)
            )
        ]
    }

    // MARK: - Soil Moisture
    func fetchSoilMoisture(region: String) async throws -> SoilMoisture {
        try await Task.sleep(nanoseconds: 200_000_000)
        return SoilMoisture(
            region: region,
            moistureLevel: Double.random(in: 20...80),
            status: .adequate,
            lastUpdated: Date()
        )
    }
}

// MARK: - Weather Alert Model
struct WeatherAlert: Identifiable, Codable {
    let id: String
    let region: String
    let alertType: AlertType
    let severity: Severity
    let message: String
    let affectedCrops: [String]
    let validFrom: Date
    let validUntil: Date

    enum AlertType: String, Codable {
        case frost = "Frost"
        case drought = "Drought"
        case flooding = "Flooding"
        case storm = "Storm"
        case heatWave = "Heat Wave"

        var icon: String {
            switch self {
            case .frost: return "snowflake"
            case .drought: return "sun.max"
            case .flooding: return "water.waves"
            case .storm: return "cloud.bolt.rain.fill"
            case .heatWave: return "thermometer.sun.fill"
            }
        }
    }

    enum Severity: String, Codable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case severe = "Severe"

        var color: String {
            switch self {
            case .low: return "yellow"
            case .moderate: return "orange"
            case .high: return "red"
            case .severe: return "purple"
            }
        }
    }
}
