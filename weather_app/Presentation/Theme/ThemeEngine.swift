// Presentation/Theme/ThemeEngine.swift
// WeatherCast App
// Dynamic Theme Engine — reads LOCATION local time, publishes light/dark theme tokens

import SwiftUI
import Combine

// MARK: - Theme

enum AppTheme {
    case morning   // 05:00 – 17:59  →  light bg image, black text
    case evening   // 18:00 – 04:59  →  dark bg image,  white text
}

// MARK: - ThemeEngine

final class ThemeEngine: ObservableObject {

    static let shared = ThemeEngine()

    @Published private(set) var theme: AppTheme = .morning

    // The local hour at the currently displayed weather location.
    // nil = fall back to device clock (before any weather loads).
    private var locationHour: Int? = nil

    // Track when we last received a locationHour so the minute-timer
    // can advance it accurately without another network call.
    private var locationHourReceivedAt: Date = .now

    private var cancellables = Set<AnyCancellable>()

    private init() {
        updateTheme()

        // Re-evaluate every 60 s. If we have a location hour we advance it
        // by the elapsed wall-clock minutes so the theme transitions correctly
        // even if the user leaves the app open across an 18:00 boundary.
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.updateTheme() }
            .store(in: &cancellables)
    }

    // MARK: - Location-aware hour injection

    /// Call this whenever new weather data arrives with the location's local hour
    /// parsed from the API's `location.localtime` field.
    func setLocationHour(_ hour: Int) {
        locationHour = hour
        locationHourReceivedAt = .now
        updateTheme()
    }

    // MARK: - Theme evaluation

    private func updateTheme() {
        let hour: Int
        if let locationHour {
            // Advance the stored location hour by the elapsed whole minutes
            // since we received it, so the theme boundary shifts naturally.
            let elapsedMinutes = Int(Date.now.timeIntervalSince(locationHourReceivedAt) / 60)
            hour = (locationHour + elapsedMinutes / 60) % 24
        } else {
            // No weather loaded yet — use device clock as a reasonable default.
            hour = Calendar.current.component(.hour, from: Date())
        }
        // Morning : 05:00 up to 17:59
        // Evening : 18:00 through 04:59
        theme = (hour >= 5 && hour < 18) ? .morning : .evening
    }

    // MARK: - Background Image Name (Asset Catalog)

    var backgroundImageName: String {
        theme == .morning ? "morning_bg" : "evening_bg"
    }

    // MARK: - Text Colors

    var textColor: Color {
        theme == .morning ? .black : .white
    }

    var secondaryTextColor: Color {
        theme == .morning
            ? Color.black.opacity(0.6)
            : Color.white.opacity(0.7)
    }

    // MARK: - Glass Surface Tokens

    var glassBackground: Color {
        theme == .morning
            ? Color.white.opacity(0.45)
            : Color(white: 0.08).opacity(0.65)
    }

    var glassBorder: Color {
        theme == .morning
            ? Color.white.opacity(0.70)
            : Color.white.opacity(0.18)
    }

    // MARK: - Image readability overlay

    var imageOverlayColor: Color {
        theme == .morning
            ? Color.black.opacity(0.08)
            : Color.black.opacity(0.20)
    }

    // MARK: - Helpers

    var isMorning: Bool { theme == .morning }
}
