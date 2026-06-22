// Domain/UseCases/SavedLocationsUseCase.swift
// WeatherCast App
// Pure Swift — no framework dependencies

import Foundation

// MARK: - Protocol

protocol SavedLocationsUseCaseProtocol {
    func fetchAll() -> [SavedLocationEntry]
    func save(_ location: SavedLocationEntry) throws
    func delete(_ location: SavedLocationEntry) throws
}

// MARK: - Implementation

final class SavedLocationsUseCase: SavedLocationsUseCaseProtocol {
    private let repository: WeatherRepository

    init(repository: WeatherRepository) {
        self.repository = repository
    }

    func fetchAll() -> [SavedLocationEntry] {
        repository.fetchSavedLocations()
    }

    func save(_ location: SavedLocationEntry) throws {
        try repository.saveLocation(location)
    }

    func delete(_ location: SavedLocationEntry) throws {
        try repository.deleteLocation(location)
    }
}
