// Presentation/HourlyForecast/HourlyForecastView.swift
// WeatherCast App
// Screen 2 — Hourly detail view for a selected forecast day

import SwiftUI

struct HourlyForecastView: View {

    let day: ForecastDayEntity
    @ObservedObject var theme: ThemeEngine
    @Environment(\.dismiss) private var dismiss

    private var visibleHours: [HourEntity] {
        if day.dayLabel == "Today" {
            let currentHour = Calendar.current.component(.hour, from: Date())
            return Array(day.hours.dropFirst(currentHour))
        }
        return day.hours
    }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Custom Nav Bar
            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(theme.textColor)
                    .padding(12)
                    .background(Capsule().fill(theme.glassBackground))
                    .overlay(Capsule().strokeBorder(theme.glassBorder, lineWidth: 1))
                }

                Spacer()

                Text(day.dayLabel)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.textColor)

                Spacer()

                Color.clear.frame(width: 80, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // MARK: Hourly List
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(visibleHours.enumerated()), id: \.element.id) { index, hour in
                        HourlyRowView(
                            hour: hour,
                            theme: theme,
                            index: index,
                            isFirst: index == 0 && day.dayLabel == "Today"
                        )
                        if index < visibleHours.count - 1 {
                            Divider()
                                .overlay(theme.glassBorder)
                                .padding(.horizontal, 30)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(theme.glassBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(theme.glassBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
        }
        // KEY: Same pattern as DashboardView — .background { } on the outermost
        // view returned from body. NavigationStack destination views work the same
        // way as the root view when it comes to background propagation.
        .background(alignment: .center) {
            ZStack {
                Image(theme.backgroundImageName)
                    .resizable()
                    .scaledToFill()
                theme.imageOverlayColor
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.2), value: theme.backgroundImageName)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Hourly Row

private struct HourlyRowView: View {

    let hour: HourEntity
    @ObservedObject var theme: ThemeEngine
    let index: Int
    let isFirst: Bool

    @State private var appeared = false

    var body: some View {
        HStack(spacing: 0) {
            Text(hour.timeLabel)
                .font(.system(size: 18, weight: isFirst ? .semibold : .regular, design: .rounded))
                .foregroundColor(theme.textColor)
                .frame(width: 70, alignment: .leading)
                .padding(.leading, 24)

            Spacer()

            AsyncImage(url: URL(string: hour.conditionIconURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit().frame(width: 38, height: 38)
                case .failure:
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 26))
                        .foregroundColor(theme.secondaryTextColor)
                default:
                    ProgressView().frame(width: 38, height: 38).tint(theme.textColor)
                }
            }
            .frame(width: 44, height: 44)

            Spacer()

            Text("\(Int(hour.tempC))°")
                .font(.system(size: 28, weight: .thin, design: .rounded))
                .foregroundColor(theme.textColor)
                .frame(width: 70, alignment: .trailing)
                .padding(.trailing, 24)
        }
        .padding(.vertical, 14)
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : 40)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.06),
            value: appeared
        )
        .onAppear { appeared = true }
    }
}
