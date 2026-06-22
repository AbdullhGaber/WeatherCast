// Data/Local/SavedLocationModel.swift
// WeatherCast App
// SwiftData persistence model

import Foundation
import SwiftData

/// SwiftData model for a user-saved weather location.
@Model
final class SavedLocationModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var country: String
    var lat: Double
    var lon: Double
    var savedAt: Date

    init(id: UUID = UUID(), name: String, country: String, lat: Double, lon: Double) {
        self.id = id
        self.name = name
        self.country = country
        self.lat = lat
        self.lon = lon
        self.savedAt = Date()
    }

    /// Convert to the pure domain model.
    func toDomain() -> SavedLocationEntry {
        SavedLocationEntry(id: id, name: name, country: country, lat: lat, lon: lon)
    }
}
