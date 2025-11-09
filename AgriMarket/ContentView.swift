//
//  ContentView.swift
//  AgriMarket
//
//  Main navigation - DECISION FIRST
//  "Should I sell today or wait?" - answered in 30 seconds
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var selectedCommodity: Commodity?

    var body: some View {
        TabView(selection: $selectedTab) {
            // TAB 1: THE DECISION (Primary)
            DecisionScreen(commodity: defaultCommodity)
                .tabItem {
                    Label("Decision", systemImage: "target")
                }
                .tag(0)

            // TAB 2: Markets (Context)
            MarketsView()
                .tabItem {
                    Label("Markets", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)

            // TAB 3: Commodities (Browse)
            CommoditiesView()
                .tabItem {
                    Label("Prices", systemImage: "leaf.fill")
                }
                .tag(2)

            // TAB 4: News (Intel)
            NewsView()
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }
                .tag(3)

            // TAB 5: Settings
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .accentColor(.green)
    }

    /// Default commodity to analyze (Corn)
    /// In production, this would be user's selected commodity from settings
    private var defaultCommodity: Commodity {
        Commodity(
            id: "corn",
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
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
