// Presentation/Dashboard/Components/MetricsGridView.swift
// WeatherCast App
// 2×2 grid of weather metric cards (Visibility, Humidity, Feels Like, Pressure)

import SwiftUI

struct MetricsGridView: View {

    let weather: WeatherEntity
    @ObservedObject var theme: ThemeEngine

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            MetricCardView(
                title: "VISIBILITY",
                value: String(format: "%.0f km", weather.visibilityKm),
                systemIcon: "eye.fill",
                theme: theme,
                animationDelay: 0.0
            )
            MetricCardView(
                title: "HUMIDITY",
                value: "\(weather.humidity)%",
                systemIcon: "humidity.fill",
                theme: theme,
                animationDelay: 0.08
            )
            MetricCardView(
                title: "FEELS LIKE",
                value: "\(Int(weather.feelsLike))°",
                systemIcon: "thermometer.medium",
                theme: theme,
                animationDelay: 0.16
            )
            MetricCardView(
                title: "PRESSURE",
                value: String(format: "%.0f mb", weather.pressureMb),
                systemIcon: "gauge.with.needle.fill",
                theme: theme,
                animationDelay: 0.24
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Metric Card

private struct MetricCardView: View {

    let title: String
    let value: String
    let systemIcon: String
    @ObservedObject var theme: ThemeEngine
    let animationDelay: Double

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Icon + Label row
            HStack(spacing: 6) {
                Image(systemName: systemIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.secondaryTextColor)

                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(theme.secondaryTextColor)
            }

            // Value
            Text(value)
                .font(.system(size: 28, weight: .light, design: .rounded))
                .foregroundColor(theme.textColor)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        // Single clean background — no nested .background() calls
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.glassBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(theme.glassBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.88)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.7)
            .delay(animationDelay),
            value: appeared
        )
        .onAppear { appeared = true }
    }
}
