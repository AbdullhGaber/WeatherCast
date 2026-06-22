// Presentation/Dashboard/Components/ForecastRowView.swift
// WeatherCast App
// Single row in the 3-day forecast list

import SwiftUI

struct ForecastRowView: View {

    let day: ForecastDayEntity
    @ObservedObject var theme: ThemeEngine
    let index: Int

    @State private var appeared = false

    var body: some View {
        HStack(spacing: 0) {

            // MARK: Day Label
            Text(day.dayLabel)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(theme.textColor)
                .frame(width: 90, alignment: .leading)

            Spacer()

            // MARK: Condition Icon
            AsyncImage(url: URL(string: day.conditionIconURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                case .failure:
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 22))
                        .foregroundColor(theme.textColor.opacity(0.6))
                default:
                    ProgressView()
                        .frame(width: 32, height: 32)
                        .tint(theme.textColor)
                }
            }
            .frame(width: 36, height: 36)

            Spacer()

            // MARK: Min – Max Temp
            Text("\(Int(day.minTemp))°  –  \(Int(day.maxTemp))°")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(theme.secondaryTextColor)
                .frame(width: 100, alignment: .trailing)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -30)
        .animation(
            .spring(response: 0.55, dampingFraction: 0.72)
            .delay(Double(index) * 0.12),
            value: appeared
        )
        .onAppear { appeared = true }
    }
}
