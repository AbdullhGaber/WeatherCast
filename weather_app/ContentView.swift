// ContentView.swift
// WeatherCast App
// Root view — resolves the root ViewModel from the Swinject container.

import SwiftUI

struct ContentView: View {
    var body: some View {
        DashboardView(viewModel: AppContainer.shared.resolve(DashboardViewModel.self))
    }
}

