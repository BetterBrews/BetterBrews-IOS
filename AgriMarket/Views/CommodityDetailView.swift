//
//  CommodityDetailView.swift
//  AgriMarket
//
//  Detailed view for individual commodity
//

import SwiftUI
import Charts

struct CommodityDetailView: View {
    @StateObject private var viewModel: CommodityDetailViewModel
    @State private var showingPriceAlert = false

    init(commodityId: String) {
        _viewModel = StateObject(wrappedValue: CommodityDetailViewModel(commodityId: commodityId))
    }

    var body: some View {
        ScrollView {
            if let commodity = viewModel.commodity {
                VStack(spacing: 20) {
                    // Header
                    commodityHeader(commodity)

                    // Price Chart
                    priceChartSection

                    // Market Statistics
                    if let stats = viewModel.marketStatistics {
                        marketStatsSection(stats)
                    }

                    // Trade Information
                    tradeInfoSection(commodity)

                    // Related News
                    if !viewModel.relatedNews.isEmpty {
                        relatedNewsSection
                    }
                }
                .padding()
            } else if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle(viewModel.commodity?.name ?? "Loading...")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingPriceAlert = true }) {
                    Image(systemName: "bell.badge.fill")
                }
            }
        }
        .task {
            await viewModel.loadCommodityDetails()
        }
    }

    // MARK: - Commodity Header
    private func commodityHeader(_ commodity: Commodity) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: commodity.category.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.green)

                VStack(alignment: .leading) {
                    Text(commodity.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(commodity.symbol) • \(commodity.category.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Divider()

            HStack {
                VStack(alignment: .leading) {
                    Text("Current Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(commodity.formattedPrice)
                        .font(.title)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Change")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        Image(systemName: commodity.dayChange >= 0 ? "arrow.up" : "arrow.down")
                        Text(commodity.formattedChange)
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(commodity.dayChange >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // MARK: - Price Chart Section
    private var priceChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price History")
                .font(.headline)

            // Timeframe Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                        Button(action: {
                            Task {
                                await viewModel.changeTimeframe(timeframe)
                            }
                        }) {
                            Text(timeframe.rawValue)
                                .font(.caption)
                                .fontWeight(viewModel.selectedTimeframe == timeframe ? .semibold : .regular)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(viewModel.selectedTimeframe == timeframe ? Color.green : Color(.systemGray6))
                                .foregroundColor(viewModel.selectedTimeframe == timeframe ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
            }

            // Chart
            if let priceHistory = viewModel.priceHistory {
                SimplePriceChart(data: priceHistory.data)
                    .frame(height: 200)
            } else {
                ProgressView()
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // MARK: - Market Stats Section
    private func marketStatsSection(_ stats: MarketStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Market Statistics")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatItem(title: "Week High", value: String(format: "$%.2f", stats.weekHigh))
                StatItem(title: "Week Low", value: String(format: "$%.2f", stats.weekLow))
                StatItem(title: "Month High", value: String(format: "$%.2f", stats.monthHigh))
                StatItem(title: "Month Low", value: String(format: "$%.2f", stats.monthLow))
                StatItem(title: "Year High", value: String(format: "$%.2f", stats.yearHigh))
                StatItem(title: "Year Low", value: String(format: "$%.2f", stats.yearLow))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // MARK: - Trade Info Section
    private func tradeInfoSection(_ commodity: Commodity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trade Information")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Trading Unit", value: commodity.unit.fullName)
                InfoRow(label: "Volume", value: String(format: "%.0f", commodity.volume))

                if !commodity.origins.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Major Exporters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(commodity.origins.joined(separator: ", "))
                            .font(.body)
                    }
                }

                if !commodity.destinations.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Major Importers")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(commodity.destinations.joined(separator: ", "))
                            .font(.body)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // MARK: - Related News Section
    private var relatedNewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related News")
                .font(.headline)

            ForEach(viewModel.relatedNews.prefix(3)) { article in
                NavigationLink(destination: NewsDetailView(article: article)) {
                    NewsRowView(article: article)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

// MARK: - Simple Price Chart
struct SimplePriceChart: View {
    let data: [PriceData]

    var body: some View {
        Chart {
            ForEach(data) { point in
                LineMark(
                    x: .value("Date", point.timestamp),
                    y: .value("Price", point.close)
                )
                .foregroundStyle(.green)

                AreaMark(
                    x: .value("Date", point.timestamp),
                    y: .value("Price", point.close)
                )
                .foregroundStyle(.green.opacity(0.1))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5))
        }
        .chartYAxis {
            AxisMarks(position: .trailing)
        }
    }
}

#Preview {
    NavigationView {
        CommodityDetailView(commodityId: "CORN")
    }
}
