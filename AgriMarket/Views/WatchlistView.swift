//
//  WatchlistView.swift
//  AgriMarket
//
//  User's personalized watchlist of commodities
//

import SwiftUI

struct WatchlistView: View {
    @StateObject private var viewModel = WatchlistViewModel()
    @State private var showingAddCommodity = false

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    LoadingView(message: "Loading watchlist...")
                } else if viewModel.watchlist.isEmpty {
                    EmptyStateView(
                        icon: "star.fill",
                        title: "No Watchlist Items",
                        message: "Add commodities to your watchlist to track their prices easily.",
                        action: { showingAddCommodity = true },
                        actionTitle: "Add Commodity"
                    )
                } else {
                    watchlistContent
                }
            }
            .navigationTitle("Watchlist")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCommodity = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCommodity) {
                AddToWatchlistView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadWatchlist()
            }
        }
    }

    private var watchlistContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Summary Card
                summaryCard

                // Watchlist Items
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.watchlist) { commodity in
                        WatchlistItemCard(
                            commodity: commodity,
                            onRemove: {
                                Task {
                                    await viewModel.removeFromWatchlist(commodity.id)
                                }
                            }
                        )
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refreshWatchlist()
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.watchlist.count)")
                        .font(.title)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Avg Change")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%+.2f%%", viewModel.averageChange))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.averageChange >= 0 ? .green : .red)
                }
            }

            Divider()

            HStack(spacing: 20) {
                StatBadge(
                    icon: "arrow.up.circle.fill",
                    value: "\(viewModel.gainersCount)",
                    label: "Gainers",
                    color: .green
                )

                StatBadge(
                    icon: "arrow.down.circle.fill",
                    value: "\(viewModel.losersCount)",
                    label: "Losers",
                    color: .red
                )

                StatBadge(
                    icon: "minus.circle.fill",
                    value: "\(viewModel.unchangedCount)",
                    label: "Unchanged",
                    color: .gray
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct WatchlistItemCard: View {
    let commodity: Commodity
    let onRemove: () -> Void

    var body: some View {
        NavigationLink(destination: CommodityDetailView(commodityId: commodity.id)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: commodity.category.icon)
                            .foregroundColor(.green)
                        Text(commodity.name)
                            .font(.headline)
                    }

                    Text(commodity.symbol)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(commodity.formattedPrice)
                        .font(.headline)

                    HStack(spacing: 4) {
                        Image(systemName: commodity.dayChange >= 0 ? "arrow.up" : "arrow.down")
                        Text(commodity.formattedChange)
                    }
                    .font(.caption)
                    .foregroundColor(commodity.dayChange >= 0 ? .green : .red)
                }

                Button(action: onRemove) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
                .buttonStyle(.borderless)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AddToWatchlistView: View {
    @ObservedObject var viewModel: WatchlistViewModel
    @Environment(\.dismiss) var dismiss
    @State private var allCommodities: [Commodity] = []
    @State private var searchText = ""
    @State private var isLoading = false

    var filteredCommodities: [Commodity] {
        if searchText.isEmpty {
            return allCommodities
        }
        return allCommodities.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.symbol.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, placeholder: "Search commodities...")

                if isLoading {
                    LoadingView()
                } else {
                    List(filteredCommodities) { commodity in
                        Button(action: {
                            Task {
                                await viewModel.addToWatchlist(commodity.id)
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: commodity.category.icon)
                                    .foregroundColor(.green)

                                VStack(alignment: .leading) {
                                    Text(commodity.name)
                                        .font(.headline)
                                    Text(commodity.symbol)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if viewModel.watchlist.contains(where: { $0.id == commodity.id }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add to Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await loadCommodities()
            }
        }
    }

    private func loadCommodities() async {
        isLoading = true
        do {
            allCommodities = try await CommodityRepository.shared.fetchAllCommodities()
        } catch {
            print("Error loading commodities: \(error)")
        }
        isLoading = false
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(placeholder, text: $text)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// MARK: - ViewModel

@MainActor
class WatchlistViewModel: ObservableObject {
    @Published var watchlist: [Commodity] = []
    @Published var isLoading = false

    private let repository = CommodityRepository.shared

    var averageChange: Double {
        guard !watchlist.isEmpty else { return 0 }
        return watchlist.reduce(0) { $0 + $1.dayChangePercent } / Double(watchlist.count)
    }

    var gainersCount: Int {
        watchlist.filter { $0.dayChange > 0 }.count
    }

    var losersCount: Int {
        watchlist.filter { $0.dayChange < 0 }.count
    }

    var unchangedCount: Int {
        watchlist.count - gainersCount - losersCount
    }

    func loadWatchlist() async {
        isLoading = true
        do {
            watchlist = try await repository.fetchFavoriteCommodities()
        } catch {
            print("Error loading watchlist: \(error)")
        }
        isLoading = false
    }

    func refreshWatchlist() async {
        // Sync first, then reload
        try? await repository.syncFromRemote()
        await loadWatchlist()
    }

    func addToWatchlist(_ commodityId: String) async {
        try? await repository.toggleFavorite(commodityId: commodityId)
        await loadWatchlist()
    }

    func removeFromWatchlist(_ commodityId: String) async {
        try? await repository.toggleFavorite(commodityId: commodityId)
        await loadWatchlist()
    }
}

#Preview {
    WatchlistView()
}
