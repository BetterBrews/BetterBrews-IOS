//
//  APISettingsView.swift
//  AgriMarket
//
//  Configure API keys and view API status
//

import SwiftUI

struct APISettingsView: View {
    @StateObject private var viewModel = APISettingsViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                // API Status Section
                Section(header: Text("API Status")) {
                    ForEach(Array(viewModel.apiStatus.keys.sorted()), id: \.self) { key in
                        HStack {
                            Text(key)
                            Spacer()
                            StatusIndicator(status: viewModel.apiStatus[key] ?? .offline)
                        }
                    }
                }

                // Alpha Vantage
                Section(header: Text("Alpha Vantage (Commodity Prices)")) {
                    TextField("API Key", text: $viewModel.alphaVantageKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Link("Get Free API Key →", destination: URL(string: "https://www.alphavantage.co/support/#api-key")!)
                        .font(.caption)
                        .foregroundColor(.blue)

                    Text("Free tier: 500 calls/day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // WeatherAPI
                Section(header: Text("WeatherAPI (Weather Data)")) {
                    TextField("API Key", text: $viewModel.weatherAPIKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Link("Get Free API Key →", destination: URL(string: "https://www.weatherapi.com/signup.aspx")!)
                        .font(.caption)
                        .foregroundColor(.blue)

                    Text("Free tier: 1M calls/month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // NewsAPI
                Section(header: Text("NewsAPI (Agricultural News)")) {
                    TextField("API Key", text: $viewModel.newsAPIKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Link("Get Free API Key →", destination: URL(string: "https://newsapi.org/register")!)
                        .font(.caption)
                        .foregroundColor(.blue)

                    Text("Free tier: 100 calls/day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // USDA (Optional)
                Section(header: Text("USDA NASS (Optional)")) {
                    TextField("API Key", text: $viewModel.usdaAPIKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Link("Get Free API Key →", destination: URL(string: "https://quickstats.nass.usda.gov/api")!)
                        .font(.caption)
                        .foregroundColor(.blue)

                    Text("Free tier: Unlimited")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Free APIs (No Key Needed)
                Section(header: Text("Always Available (No Key Required)")) {
                    InfoRow(title: "World Bank API", subtitle: "Agricultural data")
                    InfoRow(title: "RSS Feeds", subtitle: "News from Agriculture.com & AgWeb")
                }

                // Test APIs
                Section {
                    Button(action: {
                        Task {
                            await viewModel.testAPIs()
                        }
                    }) {
                        HStack {
                            if viewModel.isTesting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Testing...")
                            } else {
                                Image(systemName: "checkmark.circle")
                                Text("Test All APIs")
                            }
                        }
                    }
                    .disabled(viewModel.isTesting)
                }

                if let testResult = viewModel.testResult {
                    Section(header: Text("Test Results")) {
                        Text(testResult)
                            .font(.caption)
                            .foregroundColor(testResult.contains("✅") ? .green : .red)
                    }
                }
            }
            .navigationTitle("API Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveSettings()
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadCurrentStatus()
            }
        }
    }
}

struct StatusIndicator: View {
    let status: APIManager.APIStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(status.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var statusColor: Color {
        switch status {
        case .operational: return .green
        case .degraded: return .orange
        case .offline: return .red
        }
    }
}

struct InfoRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.body)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - ViewModel

@MainActor
class APISettingsViewModel: ObservableObject {
    @Published var alphaVantageKey = ""
    @Published var weatherAPIKey = ""
    @Published var newsAPIKey = ""
    @Published var usdaAPIKey = ""

    @Published var apiStatus: [String: APIManager.APIStatus] = [:]
    @Published var isTesting = false
    @Published var testResult: String?

    private let apiManager = APIManager.shared

    init() {
        loadSettings()
    }

    func loadSettings() {
        let config = APIManager.APIConfiguration.default
        alphaVantageKey = config.alphaVantageKey
        weatherAPIKey = config.weatherAPIKey
        newsAPIKey = config.newsAPIKey
        usdaAPIKey = config.usdaAPIKey
    }

    func loadCurrentStatus() {
        apiStatus = apiManager.apiStatus
    }

    func saveSettings() {
        let config = APIManager.APIConfiguration(
            alphaVantageKey: alphaVantageKey,
            weatherAPIKey: weatherAPIKey,
            newsAPIKey: newsAPIKey,
            usdaAPIKey: usdaAPIKey
        )

        apiManager.updateConfiguration(config)

        // Show success message
        testResult = "✅ Settings saved successfully"

        // Clear after 3 seconds
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            testResult = nil
        }
    }

    func testAPIs() async {
        isTesting = true
        testResult = nil

        var results: [String] = []

        // Test World Bank (always available)
        do {
            let url = URL(string: "https://api.worldbank.org/v2/country/USA/indicator/AG.PRD.CROP.XD?format=json&per_page=1")!
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                results.append("✅ World Bank API: Working")
            }
        } catch {
            results.append("❌ World Bank API: Failed")
        }

        // Test Alpha Vantage
        if !alphaVantageKey.isEmpty {
            do {
                let url = URL(string: "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=IBM&apikey=\(alphaVantageKey)")!
                let (data, _) = try await URLSession.shared.data(from: url)
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   json["Global Quote"] != nil {
                    results.append("✅ Alpha Vantage: Working")
                } else {
                    results.append("⚠️ Alpha Vantage: Invalid key or rate limited")
                }
            } catch {
                results.append("❌ Alpha Vantage: Failed")
            }
        } else {
            results.append("⚠️ Alpha Vantage: No API key")
        }

        // Test WeatherAPI
        if !weatherAPIKey.isEmpty {
            do {
                let url = URL(string: "https://api.weatherapi.com/v1/current.json?key=\(weatherAPIKey)&q=Chicago")!
                let (data, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    results.append("✅ WeatherAPI: Working")
                } else {
                    results.append("⚠️ WeatherAPI: Invalid key")
                }
            } catch {
                results.append("❌ WeatherAPI: Failed")
            }
        } else {
            results.append("⚠️ WeatherAPI: No API key")
        }

        // Test NewsAPI
        if !newsAPIKey.isEmpty {
            do {
                let url = URL(string: "https://newsapi.org/v2/everything?q=agriculture&pageSize=1&apiKey=\(newsAPIKey)")!
                let (data, _) = try await URLSession.shared.data(from: url)
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   (json["status"] as? String) == "ok" {
                    results.append("✅ NewsAPI: Working")
                } else {
                    results.append("⚠️ NewsAPI: Invalid key")
                }
            } catch {
                results.append("❌ NewsAPI: Failed")
            }
        } else {
            results.append("⚠️ NewsAPI: No API key")
        }

        testResult = results.joined(separator: "\n")
        isTesting = false
    }
}

#Preview {
    APISettingsView()
}
