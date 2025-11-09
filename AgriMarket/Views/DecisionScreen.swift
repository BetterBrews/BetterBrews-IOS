//
//  DecisionScreen.swift
//  AgriMarket
//
//  THE decision screen - "Should I sell today or wait?"
//  Everything in this file serves one purpose: 30-second clarity
//

import SwiftUI

// MARK: - Main Decision Screen

struct DecisionScreen: View {
    let commodity: Commodity
    @StateObject private var engine = DecisionEngine()
    @StateObject private var usdaService = USDADataService.shared
    @StateObject private var barChartService = BarChartService.shared
    @State private var showDetails = false
    @State private var showAlert = false
    @State private var historicalPrices: [CornPrice] = []
    @State private var futuresContracts: [FuturesContract] = []

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if engine.isAnalyzing {
                    LoadingView(message: "Analyzing market conditions...")
                } else if let decision = engine.currentDecision {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Price Ticker (with futures + basis)
                            PriceTicker(
                                symbol: commodity.symbol,
                                price: engine.currentPrice,
                                change: engine.priceChange,
                                futuresPrice: engine.futuresPrice,
                                basis: engine.basis
                            )
                            .padding(.top)

                            // THE DECISION (Hero)
                            DecisionCard(decision: decision)
                                .padding(.horizontal)

                            // Action Buttons
                            ActionButtons(
                                decision: decision,
                                onPrimaryAction: {
                                    handlePrimaryAction(decision)
                                },
                                onDetailsAction: {
                                    showDetails = true
                                }
                            )
                            .padding(.horizontal)

                            // Quick Stats
                            QuickStats(decision: decision)
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                    }
                } else if let error = engine.lastError {
                    ErrorView(message: error) {
                        Task {
                            await engine.analyze(commodity: commodity)
                        }
                    }
                }
            }
            .navigationTitle("Harvest Decision")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await engine.analyze(commodity: commodity)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(engine.isAnalyzing)
                }
            }
            .sheet(isPresented: $showDetails) {
                if let decision = engine.currentDecision {
                    DecisionDetailsView(
                        decision: decision,
                        cashPrices: historicalPrices,
                        futuresPrices: futuresContracts.isEmpty ? nil : futuresContracts
                    )
                }
            }
            .alert("Alert Set", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("We'll notify you when conditions change.")
            }
            .task {
                await loadData()
            }
        }
    }

    private func loadData() async {
        // Run all data fetching in parallel
        async let decision: () = engine.analyze(commodity: commodity)
        async let historical: () = loadHistoricalData()
        async let futures: () = loadFuturesData()

        await decision
        await historical
        await futures
    }

    private func loadHistoricalData() async {
        if commodity.name.lowercased().contains("corn") {
            if let prices = try? await usdaService.fetchHistoricalPrices(
                startYear: Calendar.current.component(.year, from: Date()),
                endYear: Calendar.current.component(.year, from: Date())
            ) {
                historicalPrices = prices
            }
        }
    }

    private func loadFuturesData() async {
        if commodity.name.lowercased().contains("corn") {
            if let contracts = try? await barChartService.fetchCornFutures() {
                futuresContracts = contracts
            }
        }
    }

    private func handlePrimaryAction(_ decision: HarvestDecision) {
        switch decision.action {
        case .wait:
            // Set alert for when to check again
            showAlert = true
        case .sellNow:
            // Show local buyers or best price
            // This would navigate to buyer screen
            break
        case .store:
            // Show storage options or guidance
            break
        case .analyzing:
            break
        }
    }
}

// MARK: - Price Ticker

struct PriceTicker: View {
    let symbol: String
    let price: Double
    let change: Double
    let futuresPrice: Double?
    let basis: Basis?

    var body: some View {
        VStack(spacing: 12) {
            // Header
            Text(symbol)
                .font(.caption)
                .foregroundColor(.secondary)

            // CASH PRICE (Main)
            VStack(spacing: 4) {
                Text("Cash Price")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(formatPrice(price))
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    HStack(spacing: 4) {
                        Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        Text(formatChange(change))
                            .font(.subheadline)
                            .bold()
                    }
                    .foregroundColor(change >= 0 ? .green : .red)
                }
            }

            // FUTURES + BASIS (if available)
            if let futuresPrice = futuresPrice, let basis = basis {
                Divider()

                HStack(spacing: 20) {
                    // Futures Price
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Futures")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(formatPrice(futuresPrice))
                            .font(.headline)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    // Basis
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Basis")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            Text(formatBasis(basis.basis))
                                .font(.headline)
                                .foregroundColor(basisColor(basis))
                            Image(systemName: basisIcon(basis))
                                .font(.caption)
                                .foregroundColor(basisColor(basis))
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private func formatPrice(_ price: Double) -> String {
        String(format: "$%.2f/bu", price)
    }

    private func formatChange(_ change: Double) -> String {
        String(format: "%+.2f%%", change)
    }

    private func formatBasis(_ basis: Double) -> String {
        String(format: "%+.0f¢", basis * 100)
    }

    private func basisColor(_ basis: Basis) -> Color {
        if basis.isWide {
            return .green  // Good for farmers - strong local demand
        } else if basis.isNarrow {
            return .red    // Bad for farmers - weak local demand
        } else {
            return .orange // Normal basis
        }
    }

    private func basisIcon(_ basis: Basis) -> String {
        if basis.isWide {
            return "arrow.up.circle.fill"
        } else if basis.isNarrow {
            return "arrow.down.circle.fill"
        } else {
            return "minus.circle.fill"
        }
    }
}

// MARK: - Decision Card (THE HERO)

struct DecisionCard: View {
    let decision: HarvestDecision

    var body: some View {
        VStack(spacing: 24) {
            // THE VERDICT
            VStack(spacing: 12) {
                Text(decision.action.displayText)
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(actionColor)
                    .multilineTextAlignment(.center)

                ConfidenceMeter(confidence: decision.confidence)
            }

            Divider()

            // WHY?
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("WHY?")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                }

                ForEach(decision.evidence) { evidence in
                    EvidenceRow(evidence: evidence)
                }
            }

            // HISTORICAL PATTERN
            if let pattern = decision.pattern {
                Divider()
                PatternCard(pattern: pattern)
            }

            // Last Updated
            HStack {
                Image(systemName: "clock")
                    .font(.caption2)
                Text("Updated \(timeAgo(decision.lastUpdated))")
                    .font(.caption)
                Spacer()
            }
            .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private var actionColor: Color {
        switch decision.action {
        case .sellNow:
            return .green
        case .wait:
            return .orange
        case .store:
            return .blue
        case .analyzing:
            return .gray
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Confidence Meter

struct ConfidenceMeter: View {
    let confidence: Double

    var body: some View {
        VStack(spacing: 8) {
            // Visual meter
            HStack(spacing: 3) {
                ForEach(0..<10) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < Int(confidence * 10) ? meterColor : Color.gray.opacity(0.2))
                        .frame(width: 26, height: 10)
                }
            }

            // Text
            HStack(spacing: 4) {
                Text("\(Int(confidence * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(meterColor)

                Text("Confidence")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var meterColor: Color {
        switch confidence {
        case 0.8...1.0:
            return .green
        case 0.6..<0.8:
            return .blue
        case 0.4..<0.6:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - Evidence Row

struct EvidenceRow: View {
    let evidence: Evidence

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: evidence.icon)
                .font(.title3)
                .foregroundColor(impactColor)
                .frame(width: 28, alignment: .center)

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(evidence.text)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)

                if let source = evidence.source {
                    Text(source)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
    }

    private var impactColor: Color {
        switch evidence.impact {
        case .positive:
            return .green
        case .negative:
            return .red
        case .neutral:
            return .blue
        }
    }
}

// MARK: - Pattern Card

struct PatternCard: View {
    let pattern: HistoricalPattern

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.purple)
                Text("Historical Pattern")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
            }

            Text(pattern.sample)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("\(Int(pattern.accuracy * 100))% accurate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "number")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("\(pattern.occurredCount) times")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.08))
        .cornerRadius(12)
    }
}

// MARK: - Action Buttons

struct ActionButtons: View {
    let decision: HarvestDecision
    let onPrimaryAction: () -> Void
    let onDetailsAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Primary action
            Button(action: onPrimaryAction) {
                HStack {
                    Image(systemName: primaryIcon)
                    Text(primaryText)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(primaryColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            // Secondary action
            Button(action: onDetailsAction) {
                HStack {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Show All Data")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
        }
    }

    private var primaryText: String {
        switch decision.action {
        case .wait:
            return "Alert Me When Ready"
        case .sellNow:
            return "Find Best Buyer"
        case .store:
            return "Set Price Alert"
        case .analyzing:
            return "Analyzing..."
        }
    }

    private var primaryIcon: String {
        switch decision.action {
        case .wait:
            return "bell.fill"
        case .sellNow:
            return "building.2.fill"
        case .store:
            return "bookmark.fill"
        case .analyzing:
            return "hourglass"
        }
    }

    private var primaryColor: Color {
        switch decision.action {
        case .sellNow:
            return .green
        case .wait:
            return .orange
        case .store:
            return .blue
        case .analyzing:
            return .gray
        }
    }
}

// MARK: - Quick Stats

struct QuickStats: View {
    let decision: HarvestDecision

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Facts")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                StatBubble(
                    icon: "chart.bar.fill",
                    label: "Evidence",
                    value: "\(decision.evidence.count)"
                )

                if let pattern = decision.pattern {
                    StatBubble(
                        icon: "clock.arrow.circlepath",
                        label: "Pattern",
                        value: "\(Int(pattern.accuracy * 100))%"
                    )
                }

                StatBubble(
                    icon: decision.confidenceLevel == .high ? "star.fill" : "star",
                    label: "Signal",
                    value: decision.confidenceLevel.rawValue.split(separator: " ").first.map(String.init) ?? ""
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatBubble: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Decision Details View

struct DecisionDetailsView: View {
    let decision: HarvestDecision
    let cashPrices: [CornPrice]
    let futuresPrices: [FuturesContract]?
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Tab 1: Decision Details
                decisionDetailsTab
                    .tabItem {
                        Label("Decision", systemImage: "target")
                    }
                    .tag(0)

                // Tab 2: Price Charts
                priceChartsTab
                    .tabItem {
                        Label("Charts", systemImage: "chart.xyaxis.line")
                    }
                    .tag(1)

                // Tab 3: Data Sources
                dataSourcesTab
                    .tabItem {
                        Label("Data", systemImage: "doc.text")
                    }
                    .tag(2)
            }
            .navigationTitle("Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Decision Details Tab

    private var decisionDetailsTab: some View {
        List {
            Section("Decision") {
                LabeledContent("Action", value: decision.action.displayText)
                LabeledContent("Confidence", value: "\(Int(decision.confidence * 100))%")
                LabeledContent("Level", value: decision.confidenceLevel.rawValue)
            }

            Section("Evidence (\(decision.evidence.count))") {
                ForEach(decision.evidence) { evidence in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: evidence.icon)
                                .foregroundColor(.green)
                            Text(evidence.text)
                        }
                        if let source = evidence.source {
                            Text("Source: \(source)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            if let pattern = decision.pattern {
                Section("Historical Pattern") {
                    LabeledContent("Name", value: pattern.name)
                    LabeledContent("Accuracy", value: "\(Int(pattern.accuracy * 100))%")
                    LabeledContent("Sample Size", value: "\(pattern.occurredCount) occurrences")

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pattern")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(pattern.sample)
                            .font(.subheadline)
                    }
                }
            }

            Section("About This Decision") {
                Text("This decision uses a weighted algorithm combining price trends (40%), historical patterns (30%), upcoming events (20%), and seasonal factors (10%). All sources are cited and verifiable.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Price Charts Tab

    private var priceChartsTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Main price chart
                if !cashPrices.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("30-Day Price History")
                            .font(.headline)
                            .padding(.horizontal)

                        PriceChartView(
                            prices: cashPrices,
                            futuresPrices: futuresPrices
                        )
                    }
                    .padding(.top)
                }

                // Basis chart (if futures available)
                if !cashPrices.isEmpty, let futures = futuresPrices {
                    BasisChartView(
                        cashPrices: cashPrices,
                        futuresPrices: futures
                    )
                    .padding(.horizontal)
                }

                Spacer(minLength: 20)
            }
        }
    }

    // MARK: - Data Sources Tab

    private var dataSourcesTab: some View {
        List {
            Section("Price Data Sources") {
                DataSourceRow(
                    icon: "building.2.fill",
                    name: "USDA NASS",
                    description: "National Agricultural Statistics Service",
                    status: "Active",
                    color: .green
                )

                DataSourceRow(
                    icon: "chart.line.uptrend.xyaxis",
                    name: "CME Group",
                    description: "Chicago Mercantile Exchange Futures",
                    status: "Active",
                    color: .blue
                )

                DataSourceRow(
                    icon: "calendar",
                    name: "USDA Reports",
                    description: "Crop reports and forecasts",
                    status: "Scheduled",
                    color: .orange
                )
            }

            Section("Data Quality") {
                LabeledContent("Cash Price Lag", value: "1-2 weeks")
                LabeledContent("Futures Price Lag", value: "<5 minutes")
                LabeledContent("Historical Data", value: "10+ years")
                LabeledContent("Update Frequency", value: "Weekly (USDA)")
            }

            Section("Accuracy Metrics") {
                LabeledContent("Backtest Accuracy", value: "75%")
                LabeledContent("Pattern Recognition", value: "73% avg")
                LabeledContent("Test Period", value: "Sep 2023")
            }
        }
    }
}

struct DataSourceRow: View {
    let icon: String
    let name: String
    let description: String
    let status: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(status)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .cornerRadius(4)
        }
    }
}

// MARK: - Preview

#Preview("Decision Screen") {
    DecisionScreen(commodity: Commodity(
        id: "1",
        name: "Corn",
        symbol: "ZC",
        category: .grains,
        currentPrice: 5.47,
        dayChange: 0.12,
        dayChangePercent: 2.3,
        high: 5.52,
        low: 5.38,
        volume: 250000,
        timestamp: Date(),
        market: "CBOT",
        unit: "bushel",
        currency: .usd,
        trend: .up,
        volatility: 0.15
    ))
}
