// Presentation/Dashboard/Components/ForecastListView.swift
// WeatherCast App
// Glassmorphism card containing the 3-day forecast rows

import SwiftUI

struct ForecastListView: View {

    let forecast: [ForecastDayEntity]
    @ObservedObject var theme: ThemeEngine
    let onRowTap: (ForecastDayEntity) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Section Header
            Text("3-DAY FORECAST")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(1.5)
                .foregroundColor(theme.secondaryTextColor)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 4)

            Divider()
                .overlay(theme.glassBorder)

            // MARK: Forecast Rows
            ForEach(Array(forecast.enumerated()), id: \.element.id) { index, day in
                Button {
                    onRowTap(day)
                } label: {
                    ForecastRowView(day: day, theme: theme, index: index)
                }
                .buttonStyle(.plain)

                if index < forecast.count - 1 {
                    Divider()
                        .overlay(theme.glassBorder)
                        .padding(.horizontal, 16)
                }
            }
        }
        // Single clean background — no nested .background() calls
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(theme.glassBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(theme.glassBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 20)
    }
}
