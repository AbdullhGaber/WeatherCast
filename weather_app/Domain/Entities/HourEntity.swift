// Domain/Entities/HourEntity.swift
// WeatherCast App
// Pure Swift — no framework dependencies

import Foundation

/// Represents a single hour in the hourly forecast.
struct HourEntity: Identifiable {
    let id: UUID
    let timeLabel: String      // "Now", "3PM", "4PM", etc.
    let tempC: Double
    let conditionIconURL: String
    let conditionText: String

    init(
        id: UUID = UUID(),
        timeLabel: String,
        tempC: Double,
        conditionIconURL: String,
        conditionText: String
    ) {
        self.id = id
        self.timeLabel = timeLabel
        self.tempC = tempC
        self.conditionIconURL = conditionIconURL
        self.conditionText = conditionText
    }
}
