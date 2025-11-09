//
//  AgriMarketApp.swift
//  AgriMarket
//
//  Agricultural Commodities Trading Platform
//  Similar to AgFlow, Fastmarkets, and Kpler
//

import SwiftUI

@main
struct AgriMarketApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var syncService = DataSyncService.shared

    // CoreData persistence
    let persistenceController = PersistenceController.shared

    // Background fetch
    let backgroundService = BackgroundFetchService.shared

    init() {
        // Setup background tasks
        backgroundService.setupForAppDelegate()

        // Start automatic sync
        DataSyncService.shared.startAutomaticSync()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(syncService)
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
                .onAppear {
                    performInitialSync()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    backgroundService.handleAppDidEnterBackground()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    backgroundService.handleAppWillEnterForeground()
                }
        }
    }

    private func performInitialSync() {
        Task {
            if syncService.isSyncNeeded() {
                try? await syncService.performFullSync()
            }
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var selectedCurrency: Currency = .usd
    @Published var favoritecommodities: Set<String> = []
    @Published var priceAlerts: [PriceAlert] = []

    init() {
        loadUserPreferences()
    }

    private func loadUserPreferences() {
        // Load from UserDefaults
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if let currencyCode = UserDefaults.standard.string(forKey: "selectedCurrency"),
           let currency = Currency(rawValue: currencyCode) {
            selectedCurrency = currency
        }
    }

    func savePreferences() {
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        UserDefaults.standard.set(selectedCurrency.rawValue, forKey: "selectedCurrency")
    }
}
