// Data/Repositories/WeatherRepositoryImpl.swift
// WeatherCast App
// Concrete repository — bridges Remote Service ↔ Domain + SwiftData local storage

import Foundation
import Combine
import SwiftData

final class WeatherRepositoryImpl: WeatherRepository {

    // MARK: - Dependencies

    private let apiService: WeatherAPIService
    private let modelContext: ModelContext

    // MARK: - Init

    init(apiService: WeatherAPIService, modelContext: ModelContext) {
        self.apiService = apiService
        self.modelContext = modelContext
    }

    // MARK: - WeatherRepository — Remote

    func fetchWeather(query: String) -> AnyPublisher<WeatherEntity, Error> {
        let currentHour = Calendar.current.component(.hour, from: Date())
        return apiService
            .fetchWeather(query: query)
            .map { dto in dto.toDomain(currentHour: currentHour) }
            .eraseToAnyPublisher()
    }

    func searchCities(query: String) -> AnyPublisher<[CitySearchResult], Error> {
        apiService
            .searchCities(query: query)
            .map { dtos in dtos.map { $0.toDomain() } }
            .eraseToAnyPublisher()
    }

    // MARK: - WeatherRepository — Local (SwiftData)

    func fetchSavedLocations() -> [SavedLocationEntry] {
        let descriptor = FetchDescriptor<SavedLocationModel>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        let models = (try? modelContext.fetch(descriptor)) ?? []
        return models.map { $0.toDomain() }
    }

    func saveLocation(_ location: SavedLocationEntry) throws {
        // Prevent duplicate entries by checking existing id
        let existingID = location.id
        let descriptor = FetchDescriptor<SavedLocationModel>(
            predicate: #Predicate { $0.id == existingID }
        )
        if let existing = try? modelContext.fetch(descriptor), !existing.isEmpty {
            return  // already saved
        }

        let model = SavedLocationModel(
            id: location.id,
            name: location.name,
            country: location.country,
            lat: location.lat,
            lon: location.lon
        )
        modelContext.insert(model)
        try modelContext.save()
    }

    func deleteLocation(_ location: SavedLocationEntry) throws {
        let targetID = location.id
        let descriptor = FetchDescriptor<SavedLocationModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        if let models = try? modelContext.fetch(descriptor) {
            for model in models {
                modelContext.delete(model)
            }
            try modelContext.save()
        }
    }
}
