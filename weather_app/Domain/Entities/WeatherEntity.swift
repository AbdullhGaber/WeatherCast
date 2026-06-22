// Domain/Entities/WeatherEntity.swift
// WeatherCast App
// Pure Swift — no framework dependencies

import Foundation

/// Top-level weather entity representing the full weather state for a location.
struct WeatherEntity {
    let locationName: String
    let country: String
    let currentTemp: Double
    let feelsLike: Double
    let conditionText: String
    let conditionIconURL: String
    let humidity: Int
    let visibilityKm: Double
    let pressureMb: Double
    let todayMaxTemp: Double
    let todayMinTemp: Double
    let forecast: [ForecastDayEntity]

    /// The location's local time string from the API, e.g. "2026-06-22 22:15".
    let localtime: String

    /// The local hour (0–23) at the weather location, parsed from `localtime`.
    /// Used by ThemeEngine to pick morning vs. evening based on the location's
    /// clock, not the user's device clock.
    var localHour: Int {
        // localtime format: "yyyy-MM-dd HH:mm"
        let parts = localtime.split(separator: " ")
        guard parts.count >= 2 else { return Calendar.current.component(.hour, from: Date()) }
        let timePart = String(parts[1])                      // "22:15"
        let hm = timePart.split(separator: ":")
        return hm.first.flatMap { Int($0) }
            ?? Calendar.current.component(.hour, from: Date())
    }
}

