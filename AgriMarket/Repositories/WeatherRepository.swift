//
//  WeatherRepository.swift
//  AgriMarket
//
//  Repository for weather data access
//

import Foundation
import CoreData

class WeatherRepository {
    static let shared = WeatherRepository()

    private let persistence = PersistenceController.shared
    private let syncService = DataSyncService.shared

    private init() {}

    // MARK: - Fetch Weather

    func fetchAllWeatherData() async throws -> [WeatherData] {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<WeatherDataEntity> = WeatherDataEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \WeatherDataEntity.region, ascending: true)]

        let entities = try context.fetch(fetchRequest)

        // Convert to domain model (simplified for this example)
        return entities.compactMap { entity -> WeatherData? in
            guard let region = entity.region,
                  let country = entity.country,
                  let condition = entity.weatherCondition,
                  let timestamp = entity.timestamp else {
                return nil
            }

            return WeatherData(
                id: entity.id ?? UUID().uuidString,
                location: Location(latitude: 0, longitude: 0, name: region),
                region: region,
                country: country,
                timestamp: timestamp,
                current: CurrentWeather(
                    temperature: entity.temperature,
                    feelsLike: entity.temperature,
                    humidity: Int(entity.humidity),
                    precipitation: entity.precipitation,
                    windSpeed: entity.windSpeed,
                    windDirection: "N",
                    condition: WeatherCondition(rawValue: condition) ?? .sunny,
                    uvIndex: 0,
                    visibility: 10.0,
                    pressure: 1013.0
                ),
                forecast: [],
                agriculturalImpact: AgriculturalImpact(
                    overallRisk: .low,
                    impacts: [],
                    recommendations: [],
                    affectedCrops: []
                )
            )
        }
    }

    func fetchWeatherForRegion(_ region: String) async throws -> WeatherData? {
        let context = persistence.viewContext
        let fetchRequest: NSFetchRequest<WeatherDataEntity> = WeatherDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "region == %@", region)
        fetchRequest.fetchLimit = 1

        guard let entity = try context.fetch(fetchRequest).first,
              let regionName = entity.region,
              let country = entity.country,
              let condition = entity.weatherCondition,
              let timestamp = entity.timestamp else {
            return nil
        }

        return WeatherData(
            id: entity.id ?? UUID().uuidString,
            location: Location(latitude: 0, longitude: 0, name: regionName),
            region: regionName,
            country: country,
            timestamp: timestamp,
            current: CurrentWeather(
                temperature: entity.temperature,
                feelsLike: entity.temperature,
                humidity: Int(entity.humidity),
                precipitation: entity.precipitation,
                windSpeed: entity.windSpeed,
                windDirection: "N",
                condition: WeatherCondition(rawValue: condition) ?? .sunny,
                uvIndex: 0,
                visibility: 10.0,
                pressure: 1013.0
            ),
            forecast: [],
            agriculturalImpact: determineAgriculturalImpact(
                temperature: entity.temperature,
                precipitation: entity.precipitation,
                humidity: Int(entity.humidity)
            )
        )
    }

    // MARK: - Sync

    func syncFromRemote() async throws {
        try await syncService.syncWeather()
    }

    // MARK: - Agricultural Risk Assessment

    private func determineAgriculturalImpact(
        temperature: Double,
        precipitation: Double,
        humidity: Int
    ) -> AgriculturalImpact {
        var impacts: [AgriculturalImpact.ImpactFactor] = []
        var recommendations: [String] = []
        var riskLevel: AgriculturalImpact.RiskLevel = .low

        // Extreme temperature
        if temperature > 35 {
            impacts.append(.heatWave)
            recommendations.append("High temperatures detected - ensure adequate irrigation")
            riskLevel = .high
        } else if temperature < 0 {
            impacts.append(.frost)
            recommendations.append("Frost risk - protect sensitive crops")
            riskLevel = .high
        }

        // Drought conditions
        if precipitation == 0 && humidity < 30 {
            impacts.append(.drought)
            recommendations.append("Drought conditions - monitor soil moisture closely")
            riskLevel = max(riskLevel, .moderate)
        }

        // Excessive rain
        if precipitation > 50 {
            impacts.append(.excessiveRain)
            recommendations.append("Heavy rainfall - check drainage systems")
            riskLevel = max(riskLevel, .moderate)
        }

        // Flooding risk
        if precipitation > 100 {
            impacts.append(.flooding)
            recommendations.append("Flooding risk - take preventive measures")
            riskLevel = .severe
        }

        // Good conditions
        if impacts.isEmpty {
            recommendations.append("Good weather conditions for agricultural activities")
        }

        return AgriculturalImpact(
            overallRisk: riskLevel,
            impacts: impacts,
            recommendations: recommendations,
            affectedCrops: ["Corn", "Wheat", "Soybeans"]
        )
    }

    // MARK: - Weather Alerts

    func getActiveWeatherAlerts() async throws -> [WeatherAlert] {
        let allWeather = try await fetchAllWeatherData()
        var alerts: [WeatherAlert] = []

        for weather in allWeather {
            // Check for extreme conditions
            if weather.current.temperature > 35 {
                alerts.append(WeatherAlert(
                    id: UUID().uuidString,
                    region: weather.region,
                    alertType: .heatWave,
                    severity: .high,
                    message: "Heat wave warning - temperatures exceeding 35°C",
                    affectedCrops: ["Corn", "Wheat"],
                    validFrom: Date(),
                    validUntil: Date().addingTimeInterval(24 * 3600)
                ))
            }

            if weather.current.temperature < 0 {
                alerts.append(WeatherAlert(
                    id: UUID().uuidString,
                    region: weather.region,
                    alertType: .frost,
                    severity: .severe,
                    message: "Frost warning - temperatures below freezing",
                    affectedCrops: ["All crops"],
                    validFrom: Date(),
                    validUntil: Date().addingTimeInterval(12 * 3600)
                ))
            }

            if weather.current.precipitation > 100 {
                alerts.append(WeatherAlert(
                    id: UUID().uuidString,
                    region: weather.region,
                    alertType: .flooding,
                    severity: .severe,
                    message: "Flooding risk - heavy rainfall expected",
                    affectedCrops: ["All crops"],
                    validFrom: Date(),
                    validUntil: Date().addingTimeInterval(24 * 3600)
                ))
            }

            if weather.current.precipitation == 0 && weather.current.humidity < 20 {
                alerts.append(WeatherAlert(
                    id: UUID().uuidString,
                    region: weather.region,
                    alertType: .drought,
                    severity: .moderate,
                    message: "Drought conditions persisting",
                    affectedCrops: ["Corn", "Soybeans"],
                    validFrom: Date(),
                    validUntil: Date().addingTimeInterval(7 * 24 * 3600)
                ))
            }
        }

        return alerts
    }
}

// Helper function to compare risk levels
func max(_ lhs: AgriculturalImpact.RiskLevel, _ rhs: AgriculturalImpact.RiskLevel) -> AgriculturalImpact.RiskLevel {
    let order: [AgriculturalImpact.RiskLevel] = [.low, .moderate, .high, .severe]
    let lhsIndex = order.firstIndex(of: lhs) ?? 0
    let rhsIndex = order.firstIndex(of: rhs) ?? 0
    return lhsIndex > rhsIndex ? lhs : rhs
}
