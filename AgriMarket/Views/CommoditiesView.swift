//
//  CommoditiesView.swift
//  AgriMarket
//
//  Commodities listing and filtering
//

import SwiftUI

struct CommoditiesView: View {
    @StateObject private var viewModel = CommodityViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar

                // Category Filter
                categoryFilter

                // Commodities List
                if viewModel.isLoading && viewModel.commodities.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.filteredCommodities.isEmpty {
                    emptyState
                } else {
                    commoditiesList
                }
            }
            .navigationTitle("Commodities")
            .task {
                await viewModel.loadCommodities()
            }
            .refreshable {
                await viewModel.loadCommodities()
            }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search commodities...", text: $viewModel.searchText)
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding()
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterButton(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectCategory(nil)
                }

                ForEach(CommodityCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Commodities List
    private var commoditiesList: some View {
        List(viewModel.filteredCommodities) { commodity in
            NavigationLink(destination: CommodityDetailView(commodityId: commodity.id)) {
                CommodityRowView(commodity: commodity)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No commodities found")
                .font(.headline)
            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Category Filter Button
struct CategoryFilterButton: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.green : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Commodity Row View
struct CommodityRowView: View {
    let commodity: Commodity

    var body: some View {
        HStack {
            // Icon and Symbol
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: commodity.category.icon)
                    .font(.title2)
                    .foregroundColor(.green)
                Text(commodity.symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)

            // Name and Category
            VStack(alignment: .leading, spacing: 4) {
                Text(commodity.name)
                    .font(.headline)
                Text(commodity.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Price and Change
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
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CommoditiesView()
}
