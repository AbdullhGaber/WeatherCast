// Presentation/Dashboard/Components/CurrentWeatherHeaderView.swift
// WeatherCast App
// Top section: city, temperature, condition, H/L, condition icon + save/unsave bookmark

import SwiftUI

struct CurrentWeatherHeaderView: View {

    let weather: WeatherEntity
    @ObservedObject var theme: ThemeEngine

    // Save / unsave callback wired from DashboardView
    let isSaved: Bool
    let onToggleSave: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .topTrailing) {

            // MARK: Weather info column
            VStack(spacing: 6) {

                // City Name
                Text(weather.locationName)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.05), value: appeared)

                // Temperature
                Text("\(Int(weather.currentTemp))°")
                    .font(.system(size: 80, weight: .thin, design: .rounded))
                    .foregroundColor(theme.textColor)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.7)
                    .animation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.10), value: appeared)

                // Condition Text
                Text(weather.conditionText)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(theme.secondaryTextColor)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.15), value: appeared)

                // High / Low
                Text(hiLoString)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(theme.secondaryTextColor)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeIn(duration: 0.4).delay(0.20), value: appeared)

                // Condition Icon
                AsyncImage(url: URL(string: weather.conditionIconURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .scaleEffect(appeared ? 1 : 0.5)
                            .opacity(appeared ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.25), value: appeared)
                    case .failure:
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 60))
                            .foregroundColor(theme.textColor.opacity(0.6))
                    default:
                        ProgressView().tint(theme.textColor)
                    }
                }
                .frame(width: 80, height: 80)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)

            // MARK: Save / Unsave bookmark button (top-right)
            Button(action: onToggleSave) {
                ZStack {
                    Circle()
                        .fill(theme.glassBackground)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle().strokeBorder(theme.glassBorder, lineWidth: 1)
                        )

                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSaved ? .yellow : theme.textColor)
                        .scaleEffect(appeared ? 1 : 0.5)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3), value: appeared)
                }
            }
            .padding(.top, 24)
            .padding(.trailing, 20)
            // Bounce the icon whenever the saved state flips
            .symbolEffect(.bounce, value: isSaved)
        }
        .onAppear { appeared = true }
        .onChange(of: weather.locationName) {
            appeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { appeared = true }
        }
    }

    private var hiLoString: String {
        "H:\(Int(weather.todayMaxTemp))°  L:\(Int(weather.todayMinTemp))°"
    }
}
