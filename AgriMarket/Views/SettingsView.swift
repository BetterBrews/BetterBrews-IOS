//
//  SettingsView.swift
//  AgriMarket
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                // Appearance Section
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $appState.isDarkMode)
                }

                // Currency Section
                Section(header: Text("Preferences")) {
                    Picker("Currency", selection: $appState.selectedCurrency) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            HStack {
                                Text(currency.symbol)
                                Text(currency.rawValue)
                            }
                            .tag(currency)
                        }
                    }
                }

                // Notifications Section
                Section(header: Text("Notifications")) {
                    NavigationLink("Price Alerts") {
                        PriceAlertsView()
                    }

                    Toggle("Weather Alerts", isOn: .constant(true))
                    Toggle("News Notifications", isOn: .constant(true))
                    Toggle("Market Updates", isOn: .constant(false))
                }

                // Data Section
                Section(header: Text("Data & Privacy")) {
                    NavigationLink("Saved Commodities") {
                        Text("Saved commodities list")
                    }

                    Button("Clear Cache") {
                        // Clear cache action
                    }
                }

                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    NavigationLink("Terms of Service") {
                        Text("Terms of Service")
                    }

                    NavigationLink("Privacy Policy") {
                        Text("Privacy Policy")
                    }

                    NavigationLink("About AgriMarket") {
                        AboutView()
                    }
                }

                // Support Section
                Section(header: Text("Support")) {
                    Link("Contact Support", destination: URL(string: "mailto:support@agrimarket.com")!)
                    Link("Visit Website", destination: URL(string: "https://agrimarket.com")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        appState.savePreferences()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Price Alerts View
struct PriceAlertsView: View {
    @State private var alerts: [PriceAlert] = []

    var body: some View {
        List {
            if alerts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No Price Alerts")
                        .font(.headline)
                    Text("Set up alerts to get notified when commodity prices reach your target")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(alerts) { alert in
                    PriceAlertRow(alert: alert)
                }
                .onDelete { indexSet in
                    alerts.remove(atOffsets: indexSet)
                }
            }
        }
        .navigationTitle("Price Alerts")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

// MARK: - Price Alert Row
struct PriceAlertRow: View {
    let alert: PriceAlert

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.commodityName)
                    .font(.headline)

                HStack {
                    Text(alert.condition.symbol)
                    Text(String(format: "$%.2f", alert.targetPrice))
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            Spacer()

            if alert.isActive {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Icon
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)

                // App Name
                Text("AgriMarket")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Agricultural Commodities Trading Platform")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Divider()
                    .padding(.horizontal)

                // Description
                VStack(alignment: .leading, spacing: 16) {
                    Text("About")
                        .font(.headline)

                    Text("AgriMarket is a comprehensive agricultural commodities trading and analysis platform. Track real-time prices, monitor global trade flows, analyze weather patterns, and stay updated with the latest market news.")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text("Features")
                        .font(.headline)
                        .padding(.top)

                    FeatureItem(icon: "chart.line.uptrend.xyaxis", title: "Real-time Price Tracking")
                    FeatureItem(icon: "globe.americas.fill", title: "Global Trade Flow Monitoring")
                    FeatureItem(icon: "cloud.sun.fill", title: "Weather Analytics")
                    FeatureItem(icon: "newspaper.fill", title: "Market News & Insights")
                    FeatureItem(icon: "bell.fill", title: "Price Alerts & Notifications")
                    FeatureItem(icon: "chart.bar.fill", title: "Advanced Analytics")
                }
                .padding()

                Divider()
                    .padding(.horizontal)

                // Credits
                VStack(spacing: 8) {
                    Text("Inspired by industry leaders:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("AgFlow • Fastmarkets • Kpler")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }

                // Version
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

// MARK: - Feature Item
struct FeatureItem: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 30)

            Text(title)
                .font(.body)

            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
