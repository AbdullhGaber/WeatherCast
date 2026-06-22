// DI/AppContainer.swift
// WeatherCast App
// Single Swinject container — the one and only source of dependency registration.

import Foundation
import Swinject
import SwiftData

/// The application-wide Swinject container.
/// All services, repositories, use-cases, and view-models are registered here.
/// Consumers resolve dependencies via `AppContainer.shared.resolve(...)`.
final class AppContainer {

    // MARK: - Singleton

    static let shared = AppContainer()

    // MARK: - Swinject Container

    let container: Container

    // MARK: - Init

    private init() {
        container = Container()
        registerAll()
    }

    // MARK: - Registration

    private func registerAll() {
        registerInfrastructure()
        registerRemote()
        registerRepositories()
        registerUseCases()
        registerViewModels()
    }

    // MARK: Infrastructure (ModelContext — injected after the container is created)

    /// Call this once at app startup, after the SwiftData ModelContainer is ready.
    func registerModelContext(_ context: ModelContext) {
        container.register(ModelContext.self) { _ in context }
            .inObjectScope(.container)   // singleton — one ModelContext for the whole app
    }

    // MARK: Remote Services

    private func registerRemote() {
        container.register(WeatherAPIService.self) { _ in
            WeatherAPIService()
        }
        .inObjectScope(.container)
    }

    // MARK: Repositories

    private func registerRepositories() {
        container.register(WeatherRepository.self) { resolver in
            let apiService  = resolver.resolve(WeatherAPIService.self)!
            let modelContext = resolver.resolve(ModelContext.self)!
            return WeatherRepositoryImpl(apiService: apiService, modelContext: modelContext)
        }
        .inObjectScope(.container)
    }

    // MARK: Use Cases

    private func registerUseCases() {
        container.register(FetchWeatherUseCaseProtocol.self) { resolver in
            let repo = resolver.resolve(WeatherRepository.self)!
            return FetchWeatherUseCase(repository: repo)
        }

        container.register(SavedLocationsUseCaseProtocol.self) { resolver in
            let repo = resolver.resolve(WeatherRepository.self)!
            return SavedLocationsUseCase(repository: repo)
        }
    }

    // MARK: View Models

    private func registerViewModels() {
        // Transient scope: a new DashboardViewModel is created each time it's resolved.
        // This is intentional — if the user navigates back and re-enters the dashboard,
        // a fresh ViewModel should be provided rather than a stale cached one.
        container.register(DashboardViewModel.self) { resolver in
            let repo = resolver.resolve(WeatherRepository.self)!
            return DashboardViewModel(repository: repo)
        }
        .inObjectScope(.transient)
    }

    // MARK: - Convenience Resolver

    /// Resolve a dependency. Crashes early (in DEBUG) if a registration is missing,
    /// so mis-wiring is caught at launch rather than silently at runtime.
    func resolve<T>(_ type: T.Type) -> T {
        guard let service = container.resolve(type) else {
            fatalError("AppContainer: no registration found for \(type). Check registerAll().")
        }
        return service
    }
}

// MARK: - Infrastructure (no ModelContext needed here)
private extension AppContainer {
    func registerInfrastructure() {
        // ThemeEngine is its own singleton managed outside Swinject
        // (it relies on Combine and a Timer; no benefit from container scope).
        // Registered here only so consumers can resolve it uniformly if needed.
        container.register(ThemeEngine.self) { _ in ThemeEngine.shared }
            .inObjectScope(.container)
    }
}
