//
//  Weather.swift
//  AgriMarket
//
//  Weather data and forecasts for agricultural regions
//

import Foundation

struct WeatherData: Identifiable, Codable {
    let id: String
    let location: Location
    let region: String
    let country: String
    let timestamp: Date
    let current: CurrentWeather
    let forecast: [WeatherForecast]
    let agriculturalImpact: AgriculturalImpact
}

struct CurrentWeather: Codable {
    let temperature: Double // Celsius
    let feelsLike: Double
    let humidity: Int // percentage
    let precipitation: Double // mm
    let windSpeed: Double // km/h
    let windDirection: String
    let condition: WeatherCondition
    let uvIndex: Int
    let visibility: Double // km
    let pressure: Double // hPa

    var temperatureFahrenheit: Double {
        (temperature * 9/5) + 32
    }
}

struct WeatherForecast: Identifiable, Codable {
    let id: String
    let date: Date
    let highTemp: Double
    let lowTemp: Double
    let precipitation: Double
    let precipitationProbability: Int
    let condition: WeatherCondition
    let windSpeed: Double
}

enum WeatherCondition: String, Codable {
    case sunny = "Sunny"
    case partlyCloudy = "Partly Cloudy"
    case cloudy = "Cloudy"
    case rainy = "Rainy"
    case stormy = "Stormy"
    case snowy = "Snowy"
    case foggy = "Foggy"

    var icon: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .stormy: return "cloud.bolt.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .foggy: return "cloud.fog.fill"
        }
    }
}

struct AgriculturalImpact: Codable {
    let overallRisk: RiskLevel
    let impacts: [ImpactFactor]
    let recommendations: [String]
    let affectedCrops: [String]

    enum RiskLevel: String, Codable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case severe = "Severe"

        var color: String {
            switch self {
            case .low: return "green"
            case .moderate: return "yellow"
            case .high: return "orange"
            case .severe: return "red"
            }
        }
    }

    enum ImpactFactor: String, Codable {
        case drought = "Drought"
        case flooding = "Flooding"
        case frost = "Frost"
        case heatWave = "Heat Wave"
        case excessiveRain = "Excessive Rain"
        case wind = "High Winds"
        case hail = "Hail"

        var icon: String {
            switch self {
            case .drought: return "sun.max"
            case .flooding: return "water.waves"
            case .frost: return "snowflake"
            case .heatWave: return "thermometer.sun.fill"
            case .excessiveRain: return "cloud.heavyrain.fill"
            case .wind: return "wind"
            case .hail: return "cloud.hail.fill"
            }
        }
    }
}

struct SoilMoisture: Codable {
    let region: String
    let moistureLevel: Double // percentage
    let status: MoistureStatus
    let lastUpdated: Date

    enum MoistureStatus: String, Codable {
        case drought = "Drought"
        case dry = "Dry"
        case adequate = "Adequate"
        case moist = "Moist"
        case saturated = "Saturated"

        var color: String {
            switch self {
            case .drought: return "red"
            case .dry: return "orange"
            case .adequate: return "green"
            case .moist: return "blue"
            case .saturated: return "purple"
            }
        }
    }
}

// MARK: - Sample Data
extension WeatherData {
    static let sampleData: [WeatherData] = [
        WeatherData(
            id: UUID().uuidString,
            location: Location(latitude: 41.8781, longitude: -87.6298, name: "Chicago, IL"),
            region: "Midwest Corn Belt",
            country: "USA",
            timestamp: Date(),
            current: CurrentWeather(
                temperature: 22.5,
                feelsLike: 21.0,
                humidity: 65,
                precipitation: 2.5,
                windSpeed: 15.0,
                windDirection: "NW",
                condition: .partlyCloudy,
                uvIndex: 6,
                visibility: 10.0,
                pressure: 1013.25
            ),
            forecast: [
                WeatherForecast(
                    id: UUID().uuidString,
                    date: Date().addingTimeInterval(86400),
                    highTemp: 24.0,
                    lowTemp: 16.0,
                    precipitation: 5.0,
                    precipitationProbability: 40,
                    condition: .rainy,
                    windSpeed: 12.0
                ),
                WeatherForecast(
                    id: UUID().uuidString,
                    date: Date().addingTimeInterval(86400 * 2),
                    highTemp: 26.0,
                    lowTemp: 18.0,
                    precipitation: 0.0,
                    precipitationProbability: 10,
                    condition: .sunny,
                    windSpeed: 8.0
                )
            ],
            agriculturalImpact: AgriculturalImpact(
                overallRisk: .low,
                impacts: [],
                recommendations: [
                    "Good conditions for planting",
                    "Monitor soil moisture levels",
                    "Precipitation expected tomorrow - plan fieldwork accordingly"
                ],
                affectedCrops: ["Corn", "Soybeans"]
            )
        ),
        WeatherData(
            id: UUID().uuidString,
            location: Location(latitude: -23.5505, longitude: -46.6333, name: "São Paulo, Brazil"),
            region: "Central Brazil",
            country: "Brazil",
            timestamp: Date(),
            current: CurrentWeather(
                temperature: 28.0,
                feelsLike: 30.0,
                humidity: 80,
                precipitation: 0.0,
                windSpeed: 10.0,
                windDirection: "E",
                condition: .sunny,
                uvIndex: 9,
                visibility: 12.0,
                pressure: 1010.0
            ),
            forecast: [
                WeatherForecast(
                    id: UUID().uuidString,
                    date: Date().addingTimeInterval(86400),
                    highTemp: 30.0,
                    lowTemp: 20.0,
                    precipitation: 0.0,
                    precipitationProbability: 5,
                    condition: .sunny,
                    windSpeed: 12.0
                )
            ],
            agriculturalImpact: AgriculturalImpact(
                overallRisk: .moderate,
                impacts: [.drought],
                recommendations: [
                    "Drought conditions persist",
                    "Consider irrigation for sensitive crops",
                    "Monitor soybean development closely"
                ],
                affectedCrops: ["Soybeans", "Coffee", "Cotton"]
            )
        )
    ]
}
