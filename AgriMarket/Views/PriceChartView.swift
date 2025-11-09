//
//  PriceChartView.swift
//  AgriMarket
//
//  Professional commodity price charts
//  Like Fastmarkets, AgFlow, but mobile-first
//
//  Why this matters:
//  - "Show me, don't just tell me"
//  - Visual confirmation builds trust
//  - Users can verify AI reasoning
//  - Expected in professional platforms
//

import SwiftUI
import Charts

// MARK: - Price Chart View

struct PriceChartView: View {
    let prices: [CornPrice]
    let futuresPrices: [FuturesContract]?
    @State private var selectedTimeframe: ChartTimeframe = .thirtyDays
    @State private var selectedPrice: CornPrice?
    @State private var showFutures = true

    var body: some View {
        VStack(spacing: 16) {
            // Timeframe Picker
            Picker("Timeframe", selection: $selectedTimeframe) {
                Text("7D").tag(ChartTimeframe.sevenDays)
                Text("30D").tag(ChartTimeframe.thirtyDays)
                Text("90D").tag(ChartTimeframe.ninetyDays)
                Text("1Y").tag(ChartTimeframe.oneYear)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Price Chart
            CashPriceChart(
                prices: filteredPrices,
                selectedPrice: $selectedPrice
            )
            .frame(height: 250)
            .padding(.horizontal)

            // Futures Overlay Toggle (if available)
            if futuresPrices != nil {
                Toggle("Show Futures Overlay", isOn: $showFutures)
                    .padding(.horizontal)
            }

            // Price Summary
            if let selected = selectedPrice {
                SelectedPriceDetail(price: selected)
                    .padding(.horizontal)
            } else if let latest = filteredPrices.last {
                CurrentPriceDetail(
                    price: latest,
                    change: calculateChange()
                )
                .padding(.horizontal)
            }

            // Statistics
            PriceStatistics(prices: filteredPrices)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }

    private var filteredPrices: [CornPrice] {
        let cutoffDate = selectedTimeframe.startDate
        return prices
            .filter { $0.date >= cutoffDate }
            .sorted { $0.date < $1.date }
    }

    private func calculateChange() -> (value: Double, percent: Double) {
        guard filteredPrices.count >= 2 else {
            return (0, 0)
        }

        let first = filteredPrices.first!.price
        let last = filteredPrices.last!.price
        let change = last - first
        let percent = (change / first) * 100

        return (change, percent)
    }
}

// MARK: - Chart Timeframe

enum ChartTimeframe {
    case sevenDays
    case thirtyDays
    case ninetyDays
    case oneYear

    var startDate: Date {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .sevenDays:
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .thirtyDays:
            return calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case .ninetyDays:
            return calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case .oneYear:
            return calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
    }

    var displayName: String {
        switch self {
        case .sevenDays: return "7 Days"
        case .thirtyDays: return "30 Days"
        case .ninetyDays: return "90 Days"
        case .oneYear: return "1 Year"
        }
    }
}

// MARK: - Cash Price Chart

struct CashPriceChart: View {
    let prices: [CornPrice]
    @Binding var selectedPrice: CornPrice?

    var body: some View {
        Chart {
            ForEach(prices, id: \.date) { price in
                // Area fill
                AreaMark(
                    x: .value("Date", price.date),
                    y: .value("Price", price.price)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .green.opacity(0.3),
                            .green.opacity(0.05)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // Line
                LineMark(
                    x: .value("Date", price.date),
                    y: .value("Price", price.price)
                )
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 2))

                // Selected point
                if let selected = selectedPrice,
                   selected.date == price.date {
                    PointMark(
                        x: .value("Date", price.date),
                        y: .value("Price", price.price)
                    )
                    .foregroundStyle(.green)
                    .symbolSize(100)
                }
            }

            // Average line
            if !prices.isEmpty {
                let avgPrice = prices.map { $0.price }.reduce(0, +) / Double(prices.count)

                RuleMark(y: .value("Average", avgPrice))
                    .foregroundStyle(.gray.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Avg")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
            }
        }
        .chartYScale(domain: .automatic(includesZero: false))
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: strideCount)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let price = value.as(Double.self) {
                        Text("$\(price, specifier: "%.2f")")
                            .font(.caption)
                    }
                }
            }
        }
        .chartAngleSelection(value: $selectedPrice)
    }

    private var strideCount: Int {
        switch prices.count {
        case 0...10: return 1
        case 11...30: return 7
        case 31...90: return 14
        default: return 30
        }
    }
}

// MARK: - Basis Chart

struct BasisChartView: View {
    let cashPrices: [CornPrice]
    let futuresPrices: [FuturesContract]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Basis History")
                .font(.headline)

            Chart {
                ForEach(basisData, id: \.date) { data in
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Basis", data.basis * 100) // Convert to cents
                    )
                    .foregroundStyle(basisColor(data.basis))
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    // Zero line (basis = 0)
                    RuleMark(y: .value("Zero", 0))
                        .foregroundStyle(.gray.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let basis = value.as(Double.self) {
                            Text("\(basis, specifier: "%.0f")¢")
                                .font(.caption)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }

            // Basis interpretation
            if let latest = basisData.last {
                BasisInterpretationCard(basis: latest.basis)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private struct BasisPoint {
        let date: Date
        let basis: Double
    }

    private var basisData: [BasisPoint] {
        // Match cash prices to nearest futures date
        cashPrices.compactMap { cash in
            // For simplicity, use first futures contract
            guard let futures = futuresPrices.first else { return nil }

            return BasisPoint(
                date: cash.date,
                basis: cash.price - futures.price
            )
        }
    }

    private func basisColor(_ basis: Double) -> Color {
        if basis > 0.20 {
            return .green
        } else if basis < -0.10 {
            return .red
        } else {
            return .orange
        }
    }
}

struct BasisInterpretationCard: View {
    let basis: Double

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: basis > 0.20 ? "arrow.up.circle.fill" :
                             basis < -0.10 ? "arrow.down.circle.fill" :
                             "minus.circle.fill")
                .font(.title2)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(interpretation)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("Basis: \(basis * 100, specifier: "%+.0f")¢")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }

    private var color: Color {
        if basis > 0.20 {
            return .green
        } else if basis < -0.10 {
            return .red
        } else {
            return .orange
        }
    }

    private var interpretation: String {
        if basis > 0.20 {
            return "Strong local demand - good time to sell cash"
        } else if basis < -0.10 {
            return "Weak local demand - consider forward contract"
        } else {
            return "Normal basis - market is balanced"
        }
    }
}

// MARK: - Price Details

struct CurrentPriceDetail: View {
    let price: CornPrice
    let change: (value: Double, percent: Double)

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Current Price")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }

            HStack(alignment: .firstTextBaseline) {
                Text("$\(price.price, specifier: "%.2f")/bu")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: change.value >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("$\(abs(change.value), specifier: "%.2f")")
                    }
                    .font(.headline)
                    .foregroundColor(change.value >= 0 ? .green : .red)

                    Text("\(change.percent, specifier: "%+.1f")%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SelectedPriceDetail: View {
    let price: CornPrice

    var body: some View {
        VStack(spacing: 8) {
            Text(formatDate(price.date))
                .font(.caption)
                .foregroundColor(.secondary)

            Text("$\(price.price, specifier: "%.2f")/bu")
                .font(.title2)
                .fontWeight(.bold)

            if price.change != 0 {
                HStack(spacing: 4) {
                    Image(systemName: price.change >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(price.changePercent, specifier: "%+.1f")%")
                }
                .font(.subheadline)
                .foregroundColor(price.change >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Price Statistics

struct PriceStatistics: View {
    let prices: [CornPrice]

    var body: some View {
        VStack(spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                StatCard(
                    title: "High",
                    value: "$\(high, specifier: "%.2f")",
                    color: .green
                )

                StatCard(
                    title: "Low",
                    value: "$\(low, specifier: "%.2f")",
                    color: .red
                )

                StatCard(
                    title: "Avg",
                    value: "$\(average, specifier: "%.2f")",
                    color: .blue
                )

                StatCard(
                    title: "Range",
                    value: "$\(range, specifier: "%.2f")",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var high: Double {
        prices.map { $0.price }.max() ?? 0
    }

    private var low: Double {
        prices.map { $0.price }.min() ?? 0
    }

    private var average: Double {
        guard !prices.isEmpty else { return 0 }
        return prices.map { $0.price }.reduce(0, +) / Double(prices.count)
    }

    private var range: Double {
        high - low
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Full Analysis View

struct PriceAnalysisView: View {
    let cashPrices: [CornPrice]
    let futuresPrices: [FuturesContract]?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Cash Price Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cash Price History")
                            .font(.headline)
                            .padding(.horizontal)

                        PriceChartView(
                            prices: cashPrices,
                            futuresPrices: futuresPrices
                        )
                    }

                    // Basis Chart (if futures available)
                    if let futures = futuresPrices {
                        BasisChartView(
                            cashPrices: cashPrices,
                            futuresPrices: futures
                        )
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Price Analysis")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview

#Preview("Price Chart") {
    PriceChartView(
        prices: MockData.cornPrices,
        futuresPrices: MockData.futuresContracts
    )
}

#Preview("Full Analysis") {
    PriceAnalysisView(
        cashPrices: MockData.cornPrices,
        futuresPrices: MockData.futuresContracts
    )
}

// MARK: - Mock Data

struct MockData {
    static var cornPrices: [CornPrice] {
        var prices: [CornPrice] = []
        let calendar = Calendar.current
        let basePrice = 5.50

        for day in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -day, to: Date()) else { continue }

            let noise = Double.random(in: -0.10...0.10)
            let trend = Double(30 - day) * 0.01 // Slight upward trend
            let price = basePrice + noise + trend

            prices.append(CornPrice(
                price: price,
                date: date,
                change: noise,
                changePercent: (noise / price) * 100,
                volume: Double.random(in: 200000...500000),
                source: "USDA"
            ))
        }

        return prices.sorted { $0.date < $1.date }
    }

    static var futuresContracts: [FuturesContract] {
        [
            FuturesContract(
                symbol: "ZCZ24",
                name: "Dec 2024",
                commodity: .corn,
                price: 5.25,
                change: 0.05,
                changePercent: 0.96,
                high: 5.30,
                low: 5.20,
                volume: 150000,
                openInterest: 300000,
                expirationDate: Date(),
                lastUpdated: Date()
            )
        ]
    }
}
