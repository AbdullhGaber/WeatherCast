// Presentation/Dashboard/DashboardViewModel.swift
// WeatherCast App
// @MainActor ObservableObject — drives the entire Dashboard + Search + Saved Locations

import Foundation
import SwiftUI
import Combine
import SwiftData

@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: - Published State

    @Published var weather: WeatherEntity?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var searchQuery: String = ""
    @Published var searchResults: [CitySearchResult] = []
    @Published var isSearching: Bool = false

    @Published var savedLocations: [SavedLocationEntry] = []
    @Published var activeLocationQuery: String = "30.0715495,31.0215953"  // Default: Cairo

    // MARK: - Dependencies
    // Grouped into a nonisolated value-type so the nonisolated init can store them
    // without touching any @MainActor-isolated stored properties.

    private struct Dependencies {
        let fetchWeatherUseCase: FetchWeatherUseCaseProtocol
        let savedLocationsUseCase: SavedLocationsUseCaseProtocol
        let repository: WeatherRepository
    }

    nonisolated(unsafe) private var deps: Dependencies!

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    // `nonisolated` so Swinject's synchronous resolver closure can call this
    // without a @MainActor dispatch hop. All @MainActor work is deferred to start().

    nonisolated init(repository: WeatherRepository) {
        self.deps = Dependencies(
            fetchWeatherUseCase: FetchWeatherUseCase(repository: repository),
            savedLocationsUseCase: SavedLocationsUseCase(repository: repository),
            repository: repository
        )
    }

    // MARK: - Startup (called once from DashboardView via .task — always on main actor)

    func start() {
        bindSearch()
        loadSavedLocations()
        loadWeather(query: activeLocationQuery)
    }

    // Convenience accessors (main-actor only)
    private var fetchWeatherUseCase: FetchWeatherUseCaseProtocol { deps.fetchWeatherUseCase }
    private var savedLocationsUseCase: SavedLocationsUseCaseProtocol { deps.savedLocationsUseCase }
    private var repository: WeatherRepository { deps.repository }

    // MARK: - Load Weather

    func loadWeather(query: String) {
        isLoading = true
        errorMessage = nil
        activeLocationQuery = query

        fetchWeatherUseCase
            .execute(query: query)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] entity in
                    self?.weather = entity
                    // Update the theme engine with the location's local hour so the
                    // background reflects El Salvador night, Cairo morning, etc.
                    ThemeEngine.shared.setLocationHour(entity.localHour)
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Search (debounced)

    private func bindSearch() {
        $searchQuery
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)

        $searchQuery
            .filter { $0.trimmingCharacters(in: .whitespaces).isEmpty }
            .sink { [weak self] _ in
                self?.searchResults = []
                self?.isSearching = false
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        isSearching = true
        repository
            .searchCities(query: query)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in self?.isSearching = false },
                receiveValue: { [weak self] results in
                    self?.searchResults = results
                    self?.isSearching = false
                }
            )
            .store(in: &cancellables)
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = []
    }

    // MARK: - Select a Search Result (load weather for it)

    func select(searchResult: CitySearchResult) {
        clearSearch()
        loadWeather(query: searchResult.query)
    }

    // MARK: - Select a Saved Location

    func select(savedLocation: SavedLocationEntry) {
        loadWeather(query: savedLocation.query)
    }

    // MARK: - Saved Locations CRUD

    func loadSavedLocations() {
        savedLocations = savedLocationsUseCase.fetchAll()
    }

    func saveCurrentSearchResult(_ result: CitySearchResult) {
        let entry = SavedLocationEntry(
            name: result.name,
            country: result.country,
            lat: result.lat,
            lon: result.lon
        )
        try? savedLocationsUseCase.save(entry)
        loadSavedLocations()
    }

    func deleteLocation(_ location: SavedLocationEntry) {
        try? savedLocationsUseCase.delete(location)
        loadSavedLocations()
    }

    // MARK: - Helpers

    var formattedTemp: String {
        guard let w = weather else { return "--" }
        return "\(Int(w.currentTemp))°"
    }

    var formattedHighLow: String {
        guard let w = weather else { return "" }
        return "H:\(Int(w.todayMaxTemp))° L:\(Int(w.todayMinTemp))°"
    }
}
