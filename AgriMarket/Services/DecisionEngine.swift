//
//  DecisionEngine.swift
//  AgriMarket
//
//  The brain: Makes harvest selling decisions based on data + AI
//

import Foundation
import Combine

@MainActor
class DecisionEngine: ObservableObject {
    // MARK: - Published State

    @Published var currentDecision: HarvestDecision?
    @Published var currentPrice: Double = 0.0
    @Published var priceChange: Double = 0.0
    @Published var futuresPrice: Double?
    @Published var basis: Basis?
    @Published var isAnalyzing: Bool = false
    @Published var lastError: String?

    // MARK: - Dependencies

    private let usdaService: USDADataService
    private let barChartService: BarChartService
    private let basisCalculator: BasisCalculator
    private let patternService: PatternRecognitionService
    private let calendar: AgriculturalCalendar

    // MARK: - Analysis Parameters

    private let trendWeight: Double = 0.40      // 40% weight
    private let patternWeight: Double = 0.30    // 30% weight
    private let eventWeight: Double = 0.20      // 20% weight
    private let seasonalWeight: Double = 0.10   // 10% weight

    // Decision thresholds
    private let sellThreshold: Double = 0.35    // Score < 0.35 = SELL
    private let waitThreshold: Double = 0.65    // Score > 0.65 = WAIT
    // Between 0.35-0.65 = STORE (uncertain)

    init(
        usdaService: USDADataService = .shared,
        barChartService: BarChartService = .shared,
        basisCalculator: BasisCalculator = .shared,
        patternService: PatternRecognitionService = .shared,
        calendar: AgriculturalCalendar = .shared
    ) {
        self.usdaService = usdaService
        self.barChartService = barChartService
        self.basisCalculator = basisCalculator
        self.patternService = patternService
        self.calendar = calendar
    }

    // MARK: - Main Analysis

    func analyze(commodity: Commodity) async {
        isAnalyzing = true
        lastError = nil

        do {
            // 1. Get current price
            let currentPriceData = try await fetchCurrentPrice(commodity)
            currentPrice = currentPriceData.price
            priceChange = currentPriceData.change

            // 1b. Get CME futures price + calculate basis
            if commodity.name.lowercased().contains("corn") {
                if let frontMonth = try? await barChartService.fetchFrontMonthCorn() {
                    futuresPrice = frontMonth.price
                    basis = basisCalculator.calculateCornBasis(
                        cashPrice: currentPrice,
                        futuresContract: frontMonth
                    )
                }
            }

            // 2. Get historical data (30 days)
            let history = try await fetchPriceHistory(commodity, days: 30)

            // 3. Analyze trend
            let trend = analyzeTrend(history: history)

            // 4. Get upcoming events
            let events = calendar.getUpcomingEvents(commodity: commodity.name, days: 14)

            // 5. Analyze seasonality
            let seasonal = analyzeSeasonality(commodity: commodity.name, date: Date())

            // 6. Find matching patterns
            let patterns = await patternService.findMatches(
                commodity: commodity,
                currentPrice: currentPriceData,
                history: history,
                upcomingEvents: events
            )

            // 7. Build evidence
            let evidence = buildEvidence(
                trend: trend,
                events: events,
                seasonal: seasonal,
                patterns: patterns
            )

            // 8. Make recommendation
            let recommendation = recommend(
                trend: trend,
                patterns: patterns,
                events: events,
                seasonal: seasonal
            )

            // 9. Create decision
            let decision = HarvestDecision(
                commodity: commodity.name,
                action: recommendation.action,
                confidence: recommendation.confidence,
                evidence: evidence,
                pattern: patterns.first,
                currentPrice: currentPrice,
                lastUpdated: Date()
            )

            currentDecision = decision
            isAnalyzing = false

        } catch {
            lastError = error.localizedDescription
            isAnalyzing = false
        }
    }

    // MARK: - Price Fetching

    private func fetchCurrentPrice(_ commodity: Commodity) async throws -> (price: Double, change: Double) {
        // Fetch real USDA data for corn
        if commodity.name.lowercased().contains("corn") {
            let cornPrice = try await usdaService.fetchCurrentCornPrice()
            return (price: cornPrice.price, change: cornPrice.change)
        }

        // Fallback to commodity data
        return (price: commodity.currentPrice, change: commodity.dayChange)
    }

    private func fetchPriceHistory(_ commodity: Commodity, days: Int) async throws -> [PriceData] {
        // Fetch real USDA historical data for corn
        if commodity.name.lowercased().contains("corn") {
            let currentYear = Calendar.current.component(.year, from: Date())
            let cornPrices = try await usdaService.fetchHistoricalPrices(
                startYear: currentYear,
                endYear: currentYear,
                state: "US"
            )

            // Convert to PriceData and filter to last N days
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()

            return cornPrices
                .filter { $0.date >= cutoffDate }
                .map { $0.toPriceData(commodityId: commodity.id) }
        }

        // Fallback: return empty for now
        return []
    }

    // MARK: - Trend Analysis

    private func analyzeTrend(history: [PriceData]) -> PriceTrend {
        guard history.count >= 3 else {
            return PriceTrend(
                direction: .flat,
                strength: 0.0,
                percentChange: 0.0,
                days: 0,
                projectedDays: 0
            )
        }

        let sorted = history.sorted { $0.timestamp < $1.timestamp }
        let recent = sorted.suffix(7) // Last 7 days

        guard let first = recent.first?.close,
              let last = recent.last?.close else {
            return PriceTrend(direction: .flat, strength: 0.0, percentChange: 0.0, days: 0, projectedDays: 0)
        }

        let change = ((last - first) / first) * 100
        let days = recent.count

        // Calculate trend strength (0-1) based on consistency
        var upDays = 0
        var downDays = 0

        for i in 1..<recent.count {
            if recent[i].close > recent[i-1].close {
                upDays += 1
            } else if recent[i].close < recent[i-1].close {
                downDays += 1
            }
        }

        let totalDays = recent.count - 1
        let upRatio = Double(upDays) / Double(totalDays)
        let downRatio = Double(downDays) / Double(totalDays)

        let direction: PriceTrend.Direction
        let strength: Double

        if abs(change) < 0.5 {
            direction = .flat
            strength = 0.0
        } else if change > 0 {
            direction = .up
            strength = upRatio // Strong if all days up
        } else {
            direction = .down
            strength = downRatio
        }

        // Project how many more days trend might continue
        let projectedDays = strength > 0.6 ? min(5, Int(strength * 7)) : 0

        return PriceTrend(
            direction: direction,
            strength: strength,
            percentChange: change,
            days: days,
            projectedDays: projectedDays
        )
    }

    // MARK: - Seasonality Analysis

    private func analyzeSeasonality(commodity: String, date: Date) -> SeasonalAnalysis {
        let month = Calendar.current.component(.month, from: date)

        // Corn harvest seasonality (simplified)
        if commodity.lowercased().contains("corn") {
            switch month {
            case 8: // August - Pre-harvest
                return SeasonalAnalysis(
                    currentPhase: .preHarvest,
                    significance: 0.7,
                    description: "Pre-harvest period - prices often elevated on supply concerns",
                    impact: .positive,
                    score: 0.3
                )
            case 9: // September - Early harvest
                return SeasonalAnalysis(
                    currentPhase: .earlyHarvest,
                    significance: 0.9,
                    description: "Early harvest - prices often peak before harvest pressure builds",
                    impact: .negative,
                    score: -0.4
                )
            case 10: // October - Peak harvest
                return SeasonalAnalysis(
                    currentPhase: .peakHarvest,
                    significance: 1.0,
                    description: "Peak harvest - maximum selling pressure typically depresses prices",
                    impact: .negative,
                    score: -0.6
                )
            case 11: // November - Late harvest
                return SeasonalAnalysis(
                    currentPhase: .lateHarvest,
                    significance: 0.8,
                    description: "Late harvest - prices stabilize as harvest completes",
                    impact: .neutral,
                    score: 0.1
                )
            case 12, 1: // Winter - Post harvest
                return SeasonalAnalysis(
                    currentPhase: .postHarvest,
                    significance: 0.5,
                    description: "Post-harvest - potential rally on storage demand",
                    impact: .positive,
                    score: 0.2
                )
            default:
                return SeasonalAnalysis(
                    currentPhase: .offSeason,
                    significance: 0.3,
                    description: "Off-season - prices driven by demand and weather outlook",
                    impact: .neutral,
                    score: 0.0
                )
            }
        }

        // Default for other commodities
        return SeasonalAnalysis(
            currentPhase: .offSeason,
            significance: 0.2,
            description: "Seasonal factors are moderate",
            impact: .neutral,
            score: 0.0
        )
    }

    // MARK: - Evidence Building

    private func buildEvidence(
        trend: PriceTrend,
        events: [AgEvent],
        seasonal: SeasonalAnalysis,
        patterns: [HistoricalPattern]
    ) -> [Evidence] {
        var evidence: [Evidence] = []

        // Trend evidence
        if abs(trend.percentChange) > 1.0 {
            let trendText = trend.direction == .up ?
                "Price up \(String(format: "%.1f", abs(trend.percentChange)))% in last \(trend.days) days" :
                "Price down \(String(format: "%.1f", abs(trend.percentChange)))% in last \(trend.days) days"

            evidence.append(Evidence(
                icon: trend.direction == .up ? "arrow.up.right" : "arrow.down.right",
                text: trendText,
                impact: trend.direction == .up ? .positive : .negative,
                source: "Price History"
            ))
        }

        // Event evidence (upcoming events in next 7 days)
        let upcomingEvents = events.filter { $0.daysAway <= 7 && $0.daysAway >= 0 }
        for event in upcomingEvents.prefix(2) { // Max 2 events
            let impactText = event.volatilityLevel > 0.7 ? "high volatility expected" :
                            event.volatilityLevel > 0.4 ? "moderate volatility expected" :
                            "minor impact expected"

            evidence.append(Evidence(
                icon: "calendar",
                text: "\(event.name) in \(event.daysAway) days (\(impactText))",
                impact: event.expectedImpact == .volatile ? .negative : .neutral,
                source: "Agricultural Calendar"
            ))
        }

        // Seasonal evidence (if significant)
        if seasonal.significance > 0.6 {
            evidence.append(Evidence(
                icon: "leaf",
                text: seasonal.description,
                impact: seasonal.impact,
                source: "Seasonal Analysis"
            ))
        }

        // Pattern evidence
        if let pattern = patterns.first, pattern.accuracy > 0.65 {
            evidence.append(Evidence(
                icon: "chart.line.uptrend.xyaxis",
                text: "Historical pattern detected: \(pattern.name)",
                impact: pattern.suggestedAction == .sellNow ? .negative : .positive,
                source: "Pattern Recognition"
            ))
        }

        // Basis evidence (cash vs futures)
        if let basis = self.basis {
            let basisText = String(format: "Basis: %+.2f¢ (%@)", basis.basis * 100, basis.interpretation)
            evidence.append(Evidence(
                icon: "chart.bar.doc.horizontal",
                text: basisText,
                impact: basis.isWide ? .positive : basis.isNarrow ? .negative : .neutral,
                source: "CME Futures"
            ))
        }

        return evidence
    }

    // MARK: - Recommendation Algorithm

    private struct Recommendation {
        let action: HarvestDecision.Action
        let confidence: Double
    }

    private func recommend(
        trend: PriceTrend,
        patterns: [HistoricalPattern],
        events: [AgEvent],
        seasonal: SeasonalAnalysis
    ) -> Recommendation {
        var score: Double = 0.5 // Start neutral
        var waitDays = 0

        // 1. TREND COMPONENT (40% weight)
        if trend.direction == .up {
            score += trendWeight * trend.strength
            waitDays = trend.projectedDays
        } else if trend.direction == .down {
            score -= trendWeight * trend.strength
        }

        // 2. PATTERN COMPONENT (30% weight)
        if let pattern = patterns.first {
            let patternInfluence = pattern.accuracy * patternWeight

            switch pattern.suggestedAction {
            case .wait(let days):
                score += patternInfluence
                waitDays = max(waitDays, days)
            case .sellNow:
                score -= patternInfluence
            case .store:
                score += patternInfluence * 0.5 // Slight positive
            case .analyzing:
                break
            }

            // Confidence boost from pattern
            if pattern.accuracy > 0.75 {
                score += pattern.confidenceBoost * 0.1
            }
        }

        // 3. EVENT COMPONENT (20% weight)
        let upcomingEvents = events.filter { $0.isUpcoming }
        for event in upcomingEvents {
            switch event.expectedImpact {
            case .bullish:
                score += eventWeight * 0.5
            case .bearish:
                score -= eventWeight * 0.5
            case .volatile:
                // High volatility = sell before event
                if event.daysAway <= 2 {
                    score -= eventWeight
                }
            case .neutral:
                break
            }
        }

        // 4. SEASONAL COMPONENT (10% weight)
        score += seasonal.score * seasonalWeight * seasonal.significance

        // Clamp score to 0-1
        score = min(max(score, 0.0), 1.0)

        // 5. MAKE DECISION based on score
        let action: HarvestDecision.Action
        if score < sellThreshold {
            action = .sellNow
        } else if score > waitThreshold {
            action = .wait(days: min(max(waitDays, 1), 7)) // 1-7 days
        } else {
            action = .store // Uncertain = watch and wait
        }

        // 6. CALCULATE CONFIDENCE
        // Confidence = how far from neutral (0.5)
        let confidence = min(abs(score - 0.5) * 2, 1.0)

        return Recommendation(action: action, confidence: confidence)
    }

    // MARK: - Quick Summary

    func getDecisionSummary() -> String? {
        guard let decision = currentDecision else { return nil }

        let priceText = String(format: "$%.2f", decision.currentPrice)
        let confidencePercent = Int(decision.confidence * 100)

        return """
        \(decision.commodity): \(priceText)
        Decision: \(decision.action.displayText)
        Confidence: \(confidencePercent)%
        """
    }
}

// MARK: - Pattern Recognition Service (Placeholder)

class PatternRecognitionService {
    static let shared = PatternRecognitionService()

    func findMatches(
        commodity: Commodity,
        currentPrice: (price: Double, change: Double),
        history: [PriceData],
        upcomingEvents: [AgEvent]
    ) async -> [HistoricalPattern] {
        // This will be implemented with real pattern matching
        // For now, return mock pattern if conditions met

        var patterns: [HistoricalPattern] = []

        // Example: Pre-USDA report surge pattern
        if let usdaEvent = upcomingEvents.first(where: { $0.type == .usdaReport }),
           usdaEvent.daysAway <= 5,
           currentPrice.change > 0 {

            patterns.append(HistoricalPattern(
                name: "Pre-USDA Report Rally",
                description: "Price surge before major USDA report",
                sample: "Last 4 times price rose 2%+ before USDA report, it continued +3-5% over next 3 days, then corrected -2%",
                accuracy: 0.73,
                occurredCount: 4,
                suggestedAction: .wait(days: 3),
                confidenceBoost: 0.15
            ))
        }

        return patterns
    }
}

// MARK: - Agricultural Calendar Service (Placeholder)

class AgriculturalCalendar {
    static let shared = AgriculturalCalendar()

    func getUpcomingEvents(commodity: String, days: Int) -> [AgEvent] {
        // This will be populated with real agricultural calendar data
        // For now, return known events

        var events: [AgEvent] = []
        let calendar = Calendar.current

        // Example: Monthly USDA reports (typically 12th of month)
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)

        // Next USDA report
        if let nextReport = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 12)),
           nextReport > today {
            events.append(AgEvent(
                name: "USDA WASDE Report",
                type: .usdaReport,
                date: nextReport,
                expectedImpact: .volatile,
                volatilityLevel: 0.8
            ))
        }

        return events.filter { $0.daysAway <= days }
    }

    func nextMajorEvent(days: Int) -> AgEvent? {
        getUpcomingEvents(commodity: "Corn", days: days)
            .sorted { $0.volatilityLevel > $1.volatilityLevel }
            .first
    }
}
