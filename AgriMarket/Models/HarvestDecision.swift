//
//  HarvestDecision.swift
//  AgriMarket
//
//  The core decision model - "Should I sell today or wait?"
//

import Foundation

// MARK: - Harvest Decision

struct HarvestDecision: Identifiable, Codable {
    let id: UUID
    let commodity: String // "Corn", "Soybeans", etc.
    let action: Action
    let confidence: Double // 0.0 - 1.0
    let evidence: [Evidence]
    let pattern: HistoricalPattern?
    let currentPrice: Double
    let lastUpdated: Date

    init(
        commodity: String,
        action: Action,
        confidence: Double,
        evidence: [Evidence],
        pattern: HistoricalPattern? = nil,
        currentPrice: Double,
        lastUpdated: Date = Date()
    ) {
        self.id = UUID()
        self.commodity = commodity
        self.action = action
        self.confidence = min(max(confidence, 0.0), 1.0) // Clamp 0-1
        self.evidence = evidence
        self.pattern = pattern
        self.currentPrice = currentPrice
        self.lastUpdated = lastUpdated
    }

    enum Action: Codable, Equatable {
        case sellNow
        case wait(days: Int)
        case store
        case analyzing // Initial state

        var displayText: String {
            switch self {
            case .sellNow:
                return "SELL TODAY"
            case .wait(let days):
                return days == 1 ? "WAIT 1 DAY" : "WAIT \(days) DAYS"
            case .store:
                return "STORE FOR LATER"
            case .analyzing:
                return "ANALYZING..."
            }
        }

        var shortText: String {
            switch self {
            case .sellNow:
                return "SELL"
            case .wait(let days):
                return "WAIT \(days)D"
            case .store:
                return "STORE"
            case .analyzing:
                return "..."
            }
        }
    }

    var confidenceLevel: ConfidenceLevel {
        switch confidence {
        case 0.8...1.0:
            return .high
        case 0.6..<0.8:
            return .medium
        case 0.4..<0.6:
            return .low
        default:
            return .veryLow
        }
    }

    enum ConfidenceLevel: String {
        case high = "High Confidence"
        case medium = "Medium Confidence"
        case low = "Low Confidence"
        case veryLow = "Very Low Confidence"

        var description: String {
            switch self {
            case .high:
                return "Strong signal - act with confidence"
            case .medium:
                return "Good signal - reasonable confidence"
            case .low:
                return "Weak signal - exercise caution"
            case .veryLow:
                return "Very weak signal - monitor closely"
            }
        }
    }
}

// MARK: - Evidence

struct Evidence: Identifiable, Codable {
    let id: UUID
    let icon: String // SF Symbol name
    let text: String
    let impact: Impact
    let source: String? // Optional data source reference

    init(icon: String, text: String, impact: Impact, source: String? = nil) {
        self.id = UUID()
        self.icon = icon
        self.text = text
        self.impact = impact
        self.source = source
    }

    enum Impact: String, Codable {
        case positive = "positive" // Supports waiting/higher prices
        case negative = "negative" // Supports selling now
        case neutral = "neutral"   // Context only

        var description: String {
            switch self {
            case .positive:
                return "Bullish signal"
            case .negative:
                return "Bearish signal"
            case .neutral:
                return "Market context"
            }
        }
    }
}

// MARK: - Historical Pattern

struct HistoricalPattern: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let sample: String // "Last 4 times this happened..."
    let accuracy: Double // 0.0 - 1.0
    let occurredCount: Int // How many times we've seen this
    let suggestedAction: HarvestDecision.Action
    let confidenceBoost: Double // How much this increases confidence

    init(
        name: String,
        description: String,
        sample: String,
        accuracy: Double,
        occurredCount: Int,
        suggestedAction: HarvestDecision.Action,
        confidenceBoost: Double = 0.0
    ) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.sample = sample
        self.accuracy = min(max(accuracy, 0.0), 1.0)
        self.occurredCount = occurredCount
        self.suggestedAction = suggestedAction
        self.confidenceBoost = confidenceBoost
    }

    var accuracyLevel: AccuracyLevel {
        switch accuracy {
        case 0.75...1.0:
            return .high
        case 0.65..<0.75:
            return .medium
        case 0.55..<0.65:
            return .low
        default:
            return .unreliable
        }
    }

    enum AccuracyLevel: String {
        case high = "Highly Reliable"
        case medium = "Moderately Reliable"
        case low = "Somewhat Reliable"
        case unreliable = "Low Reliability"
    }
}

// MARK: - Price Trend

struct PriceTrend: Codable {
    let direction: Direction
    let strength: Double // 0.0 - 1.0 (how strong the trend is)
    let percentChange: Double
    let days: Int
    let projectedDays: Int // How many more days trend might continue

    enum Direction: String, Codable {
        case up = "up"
        case down = "down"
        case flat = "flat"

        var displayText: String {
            switch self {
            case .up: return "Rising"
            case .down: return "Falling"
            case .flat: return "Stable"
            }
        }
    }

    var isStrong: Bool {
        strength > 0.6
    }
}

// MARK: - Agricultural Event

struct AgEvent: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: EventType
    let date: Date
    let expectedImpact: Impact
    let volatilityLevel: Double // 0.0 - 1.0

    init(
        name: String,
        type: EventType,
        date: Date,
        expectedImpact: Impact,
        volatilityLevel: Double = 0.5
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.date = date
        self.expectedImpact = expectedImpact
        self.volatilityLevel = volatilityLevel
    }

    enum EventType: String, Codable {
        case usdaReport = "USDA Report"
        case weatherEvent = "Weather Event"
        case harvestStart = "Harvest Start"
        case harvestPeak = "Harvest Peak"
        case plantingReport = "Planting Report"
        case exportNews = "Export News"
        case other = "Other"
    }

    enum Impact: String, Codable {
        case bullish = "bullish"
        case bearish = "bearish"
        case volatile = "volatile"
        case neutral = "neutral"
    }

    var daysAway: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }

    var isUpcoming: Bool {
        daysAway >= 0 && daysAway <= 14
    }
}

// MARK: - Seasonal Analysis

struct SeasonalAnalysis: Codable {
    let currentPhase: HarvestPhase
    let significance: Double // 0.0 - 1.0 (how significant is seasonal factor)
    let description: String
    let impact: Evidence.Impact
    let score: Double // -1.0 to 1.0 (negative = sell, positive = wait)

    enum HarvestPhase: String, Codable {
        case preHarvest = "Pre-Harvest"
        case earlyHarvest = "Early Harvest"
        case peakHarvest = "Peak Harvest"
        case lateHarvest = "Late Harvest"
        case postHarvest = "Post-Harvest"
        case offSeason = "Off-Season"

        var typicalPriceTrend: String {
            switch self {
            case .preHarvest:
                return "Prices typically rise on supply concerns"
            case .earlyHarvest:
                return "Prices often peak early in harvest"
            case .peakHarvest:
                return "Prices typically decline on harvest pressure"
            case .lateHarvest:
                return "Prices stabilize as harvest completes"
            case .postHarvest:
                return "Prices can rally on storage demand"
            case .offSeason:
                return "Prices driven by demand/weather outlook"
            }
        }
    }
}

// MARK: - Decision Summary (For API/Export)

struct DecisionSummary: Codable {
    let commodity: String
    let action: String
    let confidence: Double
    let reasons: [String]
    let currentPrice: Double
    let timestamp: Date

    init(from decision: HarvestDecision) {
        self.commodity = decision.commodity
        self.action = decision.action.displayText
        self.confidence = decision.confidence
        self.reasons = decision.evidence.map { $0.text }
        self.currentPrice = decision.currentPrice
        self.timestamp = decision.lastUpdated
    }
}
