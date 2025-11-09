//
//  AnalyticsView.swift
//  AgriMarket
//
//  Analytics and insights dashboard
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @State private var selectedTab = 0
    @State private var weatherData: [WeatherData] = []
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                Picker("Analytics Type", selection: $selectedTab) {
                    Text("Weather").tag(0)
                    Text("Trends").tag(1)
                    Text("Reports").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                TabView(selection: $selectedTab) {
                    WeatherAnalyticsView()
                        .tag(0)

                    TrendsAnalyticsView()
                        .tag(1)

                    ReportsView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Analytics")
        }
    }
}

// MARK: - Weather Analytics View
struct WeatherAnalyticsView: View {
    @State private var weatherData: [WeatherData] = []
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                } else {
                    ForEach(weatherData) { data in
                        WeatherRegionCard(weatherData: data)
                    }
                }
            }
            .padding()
        }
        .task {
            await loadWeatherData()
        }
    }

    private func loadWeatherData() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        weatherData = WeatherData.sampleData
        isLoading = false
    }
}

// MARK: - Weather Region Card
struct WeatherRegionCard: View {
    let weatherData: WeatherData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(weatherData.region)
                        .font(.headline)
                    Text(weatherData.country)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Image(systemName: weatherData.current.condition.icon)
                        .font(.title)
                        .foregroundColor(.orange)
                    Text(weatherData.current.condition.rawValue)
                        .font(.caption)
                }
            }

            // Current Weather
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Temperature")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f°C", weatherData.current.temperature))
                        .font(.title2)
                        .fontWeight(.bold)
                }

                VStack(alignment: .leading) {
                    Text("Humidity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(weatherData.current.humidity)%")
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                VStack(alignment: .leading) {
                    Text("Precipitation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f mm", weatherData.current.precipitation))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }

            Divider()

            // Agricultural Impact
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Agricultural Impact")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(weatherData.agriculturalImpact.overallRisk.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(weatherData.agriculturalImpact.overallRisk.color).opacity(0.2))
                        .cornerRadius(4)
                }

                if !weatherData.agriculturalImpact.recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(weatherData.agriculturalImpact.recommendations.prefix(2), id: \.self) { recommendation in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(recommendation)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }

            // Forecast
            if !weatherData.forecast.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("7-Day Forecast")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(weatherData.forecast.prefix(7)) { forecast in
                                ForecastDayView(forecast: forecast)
                            }
                        }
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

// MARK: - Forecast Day View
struct ForecastDayView: View {
    let forecast: WeatherForecast

    var body: some View {
        VStack(spacing: 8) {
            Text(forecast.date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.caption)
                .foregroundColor(.secondary)

            Image(systemName: forecast.condition.icon)
                .font(.title3)
                .foregroundColor(.orange)

            Text("\(Int(forecast.highTemp))°")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("\(Int(forecast.lowTemp))°")
                .font(.caption)
                .foregroundColor(.secondary)

            if forecast.precipitationProbability > 30 {
                Label("\(forecast.precipitationProbability)%", systemImage: "drop.fill")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Trends Analytics View
struct TrendsAnalyticsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Market Trends
                TrendCard(
                    title: "Corn Prices",
                    trend: .up,
                    value: "+5.2%",
                    description: "Prices trending upward due to strong export demand"
                )

                TrendCard(
                    title: "Wheat Supply",
                    trend: .down,
                    value: "-3.8%",
                    description: "Supply concerns from drought in key regions"
                )

                TrendCard(
                    title: "Soybean Volume",
                    trend: .up,
                    value: "+7.1%",
                    description: "Trading volume increased significantly this month"
                )

                TrendCard(
                    title: "Coffee Demand",
                    trend: .neutral,
                    value: "+0.5%",
                    description: "Stable demand with minor fluctuations"
                )
            }
            .padding()
        }
    }
}

// MARK: - Trend Card
struct TrendCard: View {
    enum Trend {
        case up, down, neutral

        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "arrow.right"
            }
        }

        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
            }
        }
    }

    let title: String
    let trend: Trend
    let value: String
    let description: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)

                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(trend.color)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: trend.icon)
                .font(.system(size: 40))
                .foregroundColor(trend.color)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Reports View
struct ReportsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Available Reports")
                    .font(.headline)
                    .padding(.horizontal)

                ReportItem(
                    title: "Monthly Market Summary",
                    date: Date(),
                    type: "PDF"
                )

                ReportItem(
                    title: "Quarterly Trade Analysis",
                    date: Date().addingTimeInterval(-86400 * 7),
                    type: "PDF"
                )

                ReportItem(
                    title: "Annual Crop Production Report",
                    date: Date().addingTimeInterval(-86400 * 30),
                    type: "PDF"
                )

                ReportItem(
                    title: "Weather Impact Assessment",
                    date: Date().addingTimeInterval(-86400 * 14),
                    type: "PDF"
                )
            }
            .padding()
        }
    }
}

// MARK: - Report Item
struct ReportItem: View {
    let title: String
    let date: Date
    let type: String

    var body: some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(type)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(4)

            Button(action: {}) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    AnalyticsView()
}
