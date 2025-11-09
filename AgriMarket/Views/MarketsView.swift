//
//  MarketsView.swift
//  AgriMarket
//
//  Global markets and trade flows
//

import SwiftUI

struct MarketsView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack {
                Picker("View", selection: $selectedTab) {
                    Text("Markets").tag(0)
                    Text("Trade Flows").tag(1)
                    Text("Regions").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                TabView(selection: $selectedTab) {
                    GlobalMarketsView()
                        .tag(0)

                    TradeFlowsView()
                        .tag(1)

                    RegionalMarketsView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Markets")
        }
    }
}

// MARK: - Global Markets View
struct GlobalMarketsView: View {
    @State private var markets: [Market] = []
    @State private var isLoading = false

    var body: some View {
        List {
            ForEach(markets) { market in
                MarketRowView(market: market)
            }
        }
        .listStyle(.plain)
        .task {
            await loadMarkets()
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
    }

    private func loadMarkets() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        markets = Market.sampleData
        isLoading = false
    }
}

// MARK: - Market Row View
struct MarketRowView: View {
    let market: Market

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(market.region.icon)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(market.name)
                        .font(.headline)
                    Text("\(market.country) • \(market.currency.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Circle()
                    .fill(market.isOpen ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                Text(market.isOpen ? "Open" : "Closed")
                    .font(.caption)
                    .foregroundColor(market.isOpen ? .green : .red)
            }

            if !market.marketIndices.isEmpty {
                Divider()
                ForEach(market.marketIndices) { index in
                    HStack {
                        Text(index.name)
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "%.2f", index.value))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        HStack(spacing: 2) {
                            Image(systemName: index.change >= 0 ? "arrow.up" : "arrow.down")
                            Text(String(format: "%+.2f%%", index.changePercent))
                        }
                        .font(.caption)
                        .foregroundColor(index.change >= 0 ? .green : .red)
                    }
                }
            }

            HStack {
                Text("Trading Hours:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(market.openTime) - \(market.closeTime) \(market.timezone)")
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Trade Flows View
struct TradeFlowsView: View {
    @State private var tradeFlows: [TradeFlow] = []
    @State private var isLoading = false

    var body: some View {
        List {
            ForEach(tradeFlows) { flow in
                NavigationLink(destination: TradeFlowDetailView(flow: flow)) {
                    TradeFlowRowView(flow: flow)
                }
            }
        }
        .listStyle(.plain)
        .task {
            await loadTradeFlows()
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
    }

    private func loadTradeFlows() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        tradeFlows = TradeFlow.sampleData
        isLoading = false
    }
}

// MARK: - Trade Flow Row View
struct TradeFlowRowView: View {
    let flow: TradeFlow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(flow.commodityName)
                    .font(.headline)
                Spacer()
                Text(flow.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(flow.status.color).opacity(0.2))
                    .cornerRadius(4)
            }

            HStack {
                Text("\(flow.origin.flag) \(flow.origin.name)")
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                Text("\(flow.destination.flag) \(flow.destination.name)")
            }
            .font(.subheadline)

            HStack {
                Label("\(String(format: "%.0f", flow.volume)) \(flow.unit.rawValue)", systemImage: "cube.box.fill")
                Spacer()
                Label(flow.formattedValue, systemImage: "dollarsign.circle.fill")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            if let vessel = flow.vessel {
                HStack {
                    Image(systemName: "ferry.fill")
                    Text(vessel.name)
                    Text("•")
                    Text("ETA: \(flow.estimatedArrival.formatted(date: .abbreviated, time: .omitted))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Regional Markets View
struct RegionalMarketsView: View {
    var body: some View {
        List {
            ForEach(MarketRegion.allCases, id: \.self) { region in
                NavigationLink(destination: RegionDetailView(region: region)) {
                    HStack {
                        Text(region.icon)
                            .font(.title2)
                        Text(region.rawValue)
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Trade Flow Detail View
struct TradeFlowDetailView: View {
    let flow: TradeFlow

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Route Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Route Information")
                        .font(.headline)

                    VStack(spacing: 16) {
                        RoutePoint(
                            title: "Origin",
                            location: "\(flow.origin.flag) \(flow.origin.name)",
                            port: flow.route.departurePort.name,
                            date: flow.shipmentDate
                        )

                        Image(systemName: "arrow.down")
                            .foregroundColor(.secondary)

                        RoutePoint(
                            title: "Destination",
                            location: "\(flow.destination.flag) \(flow.destination.name)",
                            port: flow.route.arrivalPort.name,
                            date: flow.estimatedArrival
                        )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

                // Shipment Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Shipment Details")
                        .font(.headline)

                    VStack(spacing: 8) {
                        InfoRow(label: "Commodity", value: flow.commodityName)
                        InfoRow(label: "Volume", value: "\(String(format: "%.0f", flow.volume)) \(flow.unit.rawValue)")
                        InfoRow(label: "Value", value: flow.formattedValue)
                        InfoRow(label: "Duration", value: "\(flow.durationDays) days")
                        InfoRow(label: "Distance", value: "\(String(format: "%.0f", flow.route.distance)) nautical miles")
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

                // Vessel Information
                if let vessel = flow.vessel {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vessel Information")
                            .font(.headline)

                        VStack(spacing: 8) {
                            InfoRow(label: "Vessel Name", value: vessel.name)
                            InfoRow(label: "Type", value: vessel.type.rawValue)
                            InfoRow(label: "Capacity", value: "\(String(format: "%.0f", vessel.capacity)) MT")
                            if let location = vessel.currentLocation {
                                InfoRow(label: "Current Location", value: location.name ?? "At Sea")
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
            }
            .padding()
        }
        .navigationTitle("Shipment Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Route Point
struct RoutePoint: View {
    let title: String
    let location: String
    let port: String
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(location)
                .font(.headline)
            Text(port)
                .font(.subheadline)
            Text(date.formatted(date: .long, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Region Detail View
struct RegionDetailView: View {
    let region: MarketRegion

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(region.icon)
                    .font(.system(size: 80))

                Text(region.rawValue)
                    .font(.title)
                    .fontWeight(.bold)

                Text("Regional market information and analytics will be displayed here.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
        }
        .navigationTitle(region.rawValue)
    }
}

#Preview {
    MarketsView()
}
