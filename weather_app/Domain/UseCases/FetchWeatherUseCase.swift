// Domain/UseCases/FetchWeatherUseCase.swift
// WeatherCast App
// Pure Swift — no framework dependencies

import Combine
import Foundation

// MARK: - Repository Protocol (defined here, implemented in Data layer)

protocol WeatherRepository {
    /// Fetch full weather + 3-day forecast for a given query (city name or "lat,lon").
    func fetchWeather(query: String) -> AnyPublisher<WeatherEntity, Error>

    /// Search cities by partial name for the search bar.
    func searchCities(query: String) -> AnyPublisher<[CitySearchResult], Error>

    /// Fetch all locally saved locations.
    func fetchSavedLocations() -> [SavedLocationEntry]

    /// Persist a location to local storage.
    func saveLocation(_ location: SavedLocationEntry) throws

    /// Remove a location from local storage.
    func deleteLocation(_ location: SavedLocationEntry) throws
}

// MARK: - City Search Result (Domain Model)

struct CitySearchResult: Identifiable {
    let id: UUID
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    var query: String { "\(name), \(country)" }

    init(id: UUID = UUID(), name: String, region: String, country: String, lat: Double, lon: Double) {
        self.id = id
        self.name = name
        self.region = region
        self.country = country
        self.lat = lat
        self.lon = lon
    }
}

// MARK: - Saved Location Entry (Domain Model)

struct SavedLocationEntry: Identifiable, Hashable {
    let id: UUID
    let name: String
    let country: String
    let lat: Double
    let lon: Double
    var query: String { "\(name), \(country)" }

    init(id: UUID = UUID(), name: String, country: String, lat: Double, lon: Double) {
        self.id = id
        self.name = name
        self.country = country
        self.lat = lat
        self.lon = lon
    }
}

// MARK: - UseCase Protocol

protocol FetchWeatherUseCaseProtocol {
    func execute(query: String) -> AnyPublisher<WeatherEntity, Error>
}

// MARK: - UseCase Implementation

final class FetchWeatherUseCase: FetchWeatherUseCaseProtocol {
    private let repository: WeatherRepository

    init(repository: WeatherRepository) {
        self.repository = repository
    }

    func execute(query: String) -> AnyPublisher<WeatherEntity, Error> {
        repository.fetchWeather(query: query)
    }
}
