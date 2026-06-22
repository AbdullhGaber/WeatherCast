// weather_appApp.swift
// WeatherCast App
// App entry point — boots SwiftData and registers ModelContext into the Swinject container.

import SwiftUI
import SwiftData

@main
struct weather_appApp: App {

    // MARK: - SwiftData Container

    let modelContainer: ModelContainer

    // MARK: - Init
    // Critical: ModelContext MUST be registered into the DI container here,
    // before any Scene or View body is evaluated. Doing it in .onAppear is too
    // late — ContentView.body runs synchronously before .onAppear fires,
    // causing Swinject to force-unwrap a nil ModelContext → crash.

    init() {
        let schema = Schema([SavedLocationModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("WeatherCast: Failed to create ModelContainer: \(error)")
        }

        // Register the ModelContext BEFORE any view is created.
        AppContainer.shared.registerModelContext(modelContainer.mainContext)
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
