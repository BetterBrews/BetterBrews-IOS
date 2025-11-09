//
//  DashboardView.swift
//  AgriMarket
//
//  Main dashboard view
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection

                    // Market Overview
                    if !viewModel.topCommodities.isEmpty {
                        marketOverviewSection
                    }

                    // Weather Alerts
                    if !viewModel.weatherAlerts.isEmpty {
                        weatherAlertsSection
                    }

                    // Market Insights
                    if !viewModel.marketInsights.isEmpty {
                        marketInsightsSection
                    }

                    // Recent News
                    if !viewModel.recentNews.isEmpty {
                        recentNewsSection
                    }
                }
                .padding()
            }
            .navigationTitle("AgriMarket")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .task {
                await viewModel.loadDashboardData()
            }
            .overlay {
                if viewModel.isLoading && viewModel.topCommodities.isEmpty {
                    ProgressView()
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome to AgriMarket")
                .font(.title2)
                .fontWeight(.bold)

            Text("Real-time agricultural commodity tracking")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(Date().formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Market Overview Section
    private var marketOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Market Overview")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.topCommodities) { commodity in
                        NavigationLink(destination: CommodityDetailView(commodityId: commodity.id)) {
                            CommodityCard(commodity: commodity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Weather Alerts Section
    private var weatherAlertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weather Alerts")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(viewModel.weatherAlerts) { alert in
                    WeatherAlertCard(alert: alert)
                }
            }
        }
    }

    // MARK: - Market Insights Section
    private var marketInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Market Insights")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(viewModel.marketInsights) { insight in
                    MarketInsightCard(insight: insight)
                }
            }
        }
    }

    // MARK: - Recent News Section
    private var recentNewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Latest News")
                    .font(.headline)
                Spacer()
                NavigationLink("See All") {
                    NewsView()
                }
                .font(.subheadline)
            }

            VStack(spacing: 8) {
                ForEach(viewModel.recentNews) { article in
                    NavigationLink(destination: NewsDetailView(article: article)) {
                        NewsRowView(article: article)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Commodity Card
struct CommodityCard: View {
    let commodity: Commodity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: commodity.category.icon)
                    .foregroundColor(.green)
                Text(commodity.symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(commodity.name)
                .font(.headline)

            Text(commodity.formattedPrice)
                .font(.title3)
                .fontWeight(.bold)

            HStack {
                Image(systemName: commodity.dayChange >= 0 ? "arrow.up" : "arrow.down")
                Text(commodity.formattedChange)
            }
            .font(.caption)
            .foregroundColor(commodity.dayChange >= 0 ? .green : .red)
        }
        .padding()
        .frame(width: 160)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Weather Alert Card
struct WeatherAlertCard: View {
    let alert: WeatherAlert

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: alert.alertType.icon)
                .font(.title2)
                .foregroundColor(Color(alert.severity.color))

            VStack(alignment: .leading, spacing: 4) {
                Text(alert.alertType.rawValue)
                    .font(.headline)
                Text(alert.region)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(alert.message)
                    .font(.caption)
                    .lineLimit(2)
            }

            Spacer()

            Text(alert.severity.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(alert.severity.color).opacity(0.2))
                .cornerRadius(4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Market Insight Card
struct MarketInsightCard: View {
    let insight: MarketInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: insight.type.icon)
                    .foregroundColor(Color(insight.priority.color))
                Text(insight.type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Text(insight.priority.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(insight.priority.color).opacity(0.2))
                    .cornerRadius(4)
            }

            Text(insight.title)
                .font(.headline)

            Text(insight.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            if !insight.commodities.isEmpty {
                HStack {
                    ForEach(insight.commodities, id: \.self) { commodity in
                        Text(commodity)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - News Row View
struct NewsRowView: View {
    let article: NewsArticle

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(article.summary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    Text(article.source)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(article.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: article.sentiment.icon)
                .foregroundColor(Color(article.sentiment.color))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    DashboardView()
}
