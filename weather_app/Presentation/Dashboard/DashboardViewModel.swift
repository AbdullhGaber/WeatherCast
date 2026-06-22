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

    // MARK: - Toast State

    @Published var toastMessage: String = ""
    @Published var isToastVisible: Bool = false
    private var toastDismissTask: Task<Void, Never>?

    // MARK: - Dependencies

    private struct Dependencies {
        let fetchWeatherUseCase: FetchWeatherUseCaseProtocol
        let savedLocationsUseCase: SavedLocationsUseCaseProtocol
        let repository: WeatherRepository
    }

    nonisolated(unsafe) private var deps: Dependencies!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    nonisolated init(repository: WeatherRepository) {
        self.deps = Dependencies(
            fetchWeatherUseCase: FetchWeatherUseCase(repository: repository),
            savedLocationsUseCase: SavedLocationsUseCase(repository: repository),
            repository: repository
        )
    }

    // MARK: - Startup

    func start() {
        bindSearch()
        loadSavedLocations()
        loadWeather(query: activeLocationQuery)
    }

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
            .sink { [weak self] query in self?.performSearch(query: query) }
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

    // MARK: - Navigation

    func select(searchResult: CitySearchResult) {
        clearSearch()
        loadWeather(query: searchResult.query)
    }

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

    // MARK: - Save / Unsave Current Location

    /// True when the currently displayed weather location is already in saved locations.
    var isCurrentLocationSaved: Bool {
        guard let weather else { return false }
        return savedLocations.contains {
            $0.name == weather.locationName && $0.country == weather.country
        }
    }

    /// Toggles save/unsave for the currently displayed weather location.
    func toggleSaveCurrentLocation() {
        guard let weather else { return }

        if isCurrentLocationSaved {
            // Find and delete the matching saved entry
            if let existing = savedLocations.first(where: {
                $0.name == weather.locationName && $0.country == weather.country
            }) {
                deleteLocation(existing)
                showToast("📍 \(weather.locationName) removed from saved locations")
            }
        } else {
            // Save using the coordinates returned by the API
            let entry = SavedLocationEntry(
                name: weather.locationName,
                country: weather.country,
                lat: weather.lat,
                lon: weather.lon
            )
            try? savedLocationsUseCase.save(entry)
            loadSavedLocations()
            showToast("⭐ \(weather.locationName) saved to your locations")
        }
    }

    // MARK: - Toast

    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isToastVisible = true
        }
        // Cancel any pending dismiss and schedule a new one
        toastDismissTask?.cancel()
        toastDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.35)) {
                    self?.isToastVisible = false
                }
            }
        }
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
