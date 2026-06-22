// Domain/Entities/ForecastDayEntity.swift
// WeatherCast App
// Pure Swift — no framework dependencies

import Foundation

/// Represents a single day in the 3-day forecast.
struct ForecastDayEntity: Identifiable {
    let id: UUID
    let dateString: String     // e.g. "2026-06-22"
    let dayLabel: String       // e.g. "Today", "Tomorrow", "Thu"
    let maxTemp: Double
    let minTemp: Double
    let conditionText: String
    let conditionIconURL: String
    let hours: [HourEntity]

    init(
        id: UUID = UUID(),
        dateString: String,
        dayLabel: String,
        maxTemp: Double,
        minTemp: Double,
        conditionText: String,
        conditionIconURL: String,
        hours: [HourEntity]
    ) {
        self.id = id
        self.dateString = dateString
        self.dayLabel = dayLabel
        self.maxTemp = maxTemp
        self.minTemp = minTemp
        self.conditionText = conditionText
        self.conditionIconURL = conditionIconURL
        self.hours = hours
    }
}
