//
//  ContentView.swift
//  AgriMarket
//
//  Main navigation and tab view for the application
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var syncService: DataSyncService
    @StateObject private var apiManager = APIManager.shared
    @State private var selectedTab = 0
    @State private var showAPISettings = false
    @State private var hasShownAPIPrompt = UserDefaults.standard.bool(forKey: "hasShownAPIPrompt")

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // Dashboard Tab
                EnhancedDashboardScreen()
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(0)

                // Watchlist Tab
                WatchlistView()
                    .tabItem {
                        Label("Watchlist", systemImage: "star.fill")
                    }
                    .tag(1)

                // Markets Tab
                MarketsView()
                    .tabItem {
                        Label("Markets", systemImage: "globe.americas.fill")
                    }
                    .tag(2)

                // Commodities Tab
                CommoditiesView()
                    .tabItem {
                        Label("Commodities", systemImage: "leaf.fill")
                    }
                    .tag(3)

                // News Tab
                NewsView()
                    .tabItem {
                        Label("News", systemImage: "newspaper.fill")
                    }
                    .tag(4)

                // Analytics Tab
                AnalyticsView()
                    .tabItem {
                        Label("Analytics", systemImage: "chart.bar.fill")
                    }
                    .tag(5)
            }
            .accentColor(.green)

            // Network Status Banner (overlay)
            VStack {
                NetworkStatusBanner(isOnline: apiManager.isOnline)
                    .transition(.move(edge: .top))
                Spacer()
            }
        }
        .sheet(isPresented: $showAPISettings) {
            APISettingsView()
        }
        .onAppear {
            // Show API settings prompt on first launch
            if !hasShownAPIPrompt {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showAPISettings = true
                    hasShownAPIPrompt = true
                    UserDefaults.standard.set(true, forKey: "hasShownAPIPrompt")
                }
            }
        }
    }
}

// MARK: - Enhanced Dashboard Screen

struct EnhancedDashboardScreen: View {
    @StateObject private var viewModel = EnhancedDashboardViewModel()
    @EnvironmentObject var syncService: DataSyncService

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isInitialLoading {
                    LoadingView(message: "Loading market data...")
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Last Update Info
                            if let lastSync = syncService.lastSyncDate {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                    Text("Last updated: \(formatDate(lastSync))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    if syncService.isSyncing {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }

                            // Market Statistics
                            if let stats = viewModel.marketStatistics {
                                MarketStatisticsCard(stats: stats)
                                    .padding(.horizontal)
                            } else if viewModel.statisticsError != nil {
                                ErrorView(
                                    message: viewModel.statisticsError ?? "Failed to load statistics",
                                    retry: { Task { await viewModel.loadMarketStatistics() } }
                                )
                                .padding()
                            }

                            // Top Gainers
                            DashboardSection(
                                title: "Top Gainers",
                                icon: "arrow.up.right.circle.fill",
                                color: .green
                            ) {
                                if viewModel.isLoadingCommodities {
                                    ForEach(0..<3, id: \.self) { _ in
                                        SkeletonView()
                                            .frame(height: 60)
                                    }
                                } else if let error = viewModel.commoditiesError {
                                    ErrorView(
                                        message: error,
                                        retry: { Task { await viewModel.loadCommodities() } }
                                    )
                                } else if viewModel.topGainers.isEmpty {
                                    EmptyStateView(
                                        icon: "chart.line.uptrend.xyaxis",
                                        title: "No Gainers",
                                        message: "There are no gainers available at this time"
                                    )
                                } else {
                                    ForEach(viewModel.topGainers) { commodity in
                                        CommodityRow(commodity: commodity)
                                    }
                                }
                            }
                            .padding(.horizontal)

                            // Top Losers
                            DashboardSection(
                                title: "Top Losers",
                                icon: "arrow.down.right.circle.fill",
                                color: .red
                            ) {
                                if viewModel.isLoadingCommodities {
                                    ForEach(0..<3, id: \.self) { _ in
                                        SkeletonView()
                                            .frame(height: 60)
                                    }
                                } else if viewModel.topLosers.isEmpty {
                                    EmptyStateView(
                                        icon: "chart.line.downtrend.xyaxis",
                                        title: "No Losers",
                                        message: "There are no losers available at this time"
                                    )
                                } else {
                                    ForEach(viewModel.topLosers) { commodity in
                                        CommodityRow(commodity: commodity)
                                    }
                                }
                            }
                            .padding(.horizontal)

                            // Weather Alerts
                            if !viewModel.weatherAlerts.isEmpty {
                                DashboardSection(
                                    title: "Weather Alerts",
                                    icon: "exclamationmark.triangle.fill",
                                    color: .orange
                                ) {
                                    ForEach(viewModel.weatherAlerts, id: \.self) { alert in
                                        WeatherAlertRow(alert: alert)
                                    }
                                }
                                .padding(.horizontal)
                            }

                            // Latest News
                            DashboardSection(
                                title: "Latest News",
                                icon: "newspaper.fill",
                                color: .blue
                            ) {
                                if viewModel.isLoadingNews {
                                    ForEach(0..<3, id: \.self) { _ in
                                        SkeletonView()
                                            .frame(height: 80)
                                    }
                                } else if let error = viewModel.newsError {
                                    ErrorView(
                                        message: error,
                                        retry: { Task { await viewModel.loadNews() } }
                                    )
                                } else if viewModel.latestNews.isEmpty {
                                    EmptyStateView(
                                        icon: "newspaper",
                                        title: "No News",
                                        message: "There are no news articles available at this time"
                                    )
                                } else {
                                    ForEach(viewModel.latestNews.prefix(5)) { news in
                                        NewsRowCompact(news: news)
                                    }
                                }
                            }
                            .padding(.horizontal)

                            // Market Insights
                            if !viewModel.marketInsights.isEmpty {
                                DashboardSection(
                                    title: "Market Insights",
                                    icon: "lightbulb.fill",
                                    color: .purple
                                ) {
                                    ForEach(viewModel.marketInsights, id: \.self) { insight in
                                        InsightRow(insight: insight)
                                    }
                                }
                                .padding(.horizontal)
                            }

                            Spacer(minLength: 20)
                        }
                    }
                    .refreshable {
                        await viewModel.refreshAll()
                    }
                }
            }
            .navigationTitle("AgriMarket")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.refreshAll()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(syncService.isSyncing)
                }
            }
            .task {
                await viewModel.loadAll()
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Supporting Views

struct DashboardSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 8) {
                content
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MarketStatisticsCard: View {
    let stats: MarketStatistics

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                StatBox(
                    title: "Total",
                    value: "\(stats.totalCommodities)",
                    icon: "chart.bar.fill",
                    color: .blue
                )

                StatBox(
                    title: "Gainers",
                    value: "\(stats.gainers)",
                    icon: "arrow.up",
                    color: .green
                )

                StatBox(
                    title: "Losers",
                    value: "\(stats.losers)",
                    icon: "arrow.down",
                    color: .red
                )
            }

            // Market Sentiment Indicator
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Market Sentiment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(sentimentText)
                        .font(.caption)
                        .bold()
                        .foregroundColor(sentimentColor)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)

                        Rectangle()
                            .fill(sentimentColor)
                            .frame(width: geometry.size.width * sentimentPercentage, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var sentimentPercentage: CGFloat {
        CGFloat((stats.marketSentiment + 1) / 2) // Convert -1...1 to 0...1
    }

    private var sentimentColor: Color {
        if stats.marketSentiment > 0.3 {
            return .green
        } else if stats.marketSentiment < -0.3 {
            return .red
        } else {
            return .orange
        }
    }

    private var sentimentText: String {
        if stats.marketSentiment > 0.3 {
            return "Bullish"
        } else if stats.marketSentiment < -0.3 {
            return "Bearish"
        } else {
            return "Neutral"
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .bold()

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct CommodityRow: View {
    let commodity: Commodity

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(commodity.name)
                    .font(.headline)
                Text(commodity.symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatPrice(commodity.currentPrice))
                    .font(.headline)

                HStack(spacing: 4) {
                    Image(systemName: commodity.dayChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text(formatPercentage(commodity.dayChangePercent))
                }
                .font(.caption)
                .foregroundColor(commodity.dayChange >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 8)
    }

    private func formatPrice(_ price: Double) -> String {
        String(format: "$%.2f", price)
    }

    private func formatPercentage(_ percent: Double) -> String {
        String(format: "%+.2f%%", percent)
    }
}

struct WeatherAlertRow: View {
    let alert: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(alert)
                .font(.subheadline)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct NewsRowCompact: View {
    let news: News

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(news.title)
                .font(.subheadline)
                .lineLimit(2)

            HStack {
                Text(news.source)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if let publishedAt = news.publishedAt {
                    Text(formatDate(publishedAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct InsightRow: View {
    let insight: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.purple)
                .font(.title3)

            Text(insight)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(DataSyncService.shared)
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
