// Presentation/Dashboard/DashboardView.swift
// WeatherCast App
// Screen 1 — The main Dashboard: header, forecast, metrics, search, saved locations

import SwiftUI

struct DashboardView: View {

    @StateObject private var viewModel: DashboardViewModel
    @ObservedObject var theme: ThemeEngine = ThemeEngine.shared

    @State private var selectedDay: ForecastDayEntity?
    @State private var showHourly: Bool = false

    init(viewModel: DashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {

                    // MARK: Search Bar
                    SearchBarView(
                        query: $viewModel.searchQuery,
                        isSearching: viewModel.isSearching,
                        theme: theme,
                        onClear: { viewModel.clearSearch() }
                    )
                    .padding(.top, 56)
                    .padding(.horizontal, 20)

                    // MARK: Search Results
                    if !viewModel.searchResults.isEmpty {
                        SearchResultsView(
                            results: viewModel.searchResults,
                            theme: theme,
                            onSelect: { viewModel.select(searchResult: $0) },
                            onSave:   { viewModel.saveCurrentSearchResult($0) }
                        )
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // MARK: Saved Locations
                    if !viewModel.savedLocations.isEmpty && viewModel.searchResults.isEmpty {
                        SavedLocationsView(
                            locations: viewModel.savedLocations,
                            theme: theme,
                            onSelect: { viewModel.select(savedLocation: $0) },
                            onDelete: { viewModel.deleteLocation($0) }
                        )
                        .padding(.horizontal, 20)
                    }

                    // MARK: Loading
                    if viewModel.isLoading && viewModel.weather == nil {
                        LoadingView(theme: theme)
                    }

                    // MARK: Error
                    if let error = viewModel.errorMessage {
                        ErrorBannerView(message: error, theme: theme) {
                            viewModel.loadWeather(query: viewModel.activeLocationQuery)
                        }
                        .padding(.horizontal, 20)
                    }

                    // MARK: Weather Content
                    if let weather = viewModel.weather {
                        CurrentWeatherHeaderView(weather: weather, theme: theme)

                        ForecastListView(
                            forecast: weather.forecast,
                            theme: theme
                        ) { day in
                            selectedDay = day
                            showHourly = true
                        }

                        MetricsGridView(weather: weather, theme: theme)
                            .padding(.bottom, 34)
                    }
                }
            }
            // ─────────────────────────────────────────────────────────────
            // KEY: Attach the background to the ScrollView (the direct child
            // of NavigationStack). SwiftUI propagates this background through
            // the NavigationStack chrome correctly — any other placement does
            // not work (outer ZStack, .background(.clear) on NavigationStack).
            // ─────────────────────────────────────────────────────────────
            .background(alignment: .center) {
                ZStack {
                    Image(theme.backgroundImageName)
                        .resizable()
                        .scaledToFill()
                    theme.imageOverlayColor
                }
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.2), value: theme.backgroundImageName)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showHourly) {
                if let day = selectedDay {
                    HourlyForecastView(day: day, theme: theme)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.searchResults.isEmpty)
            .task { viewModel.start() }
        }
    }
}

// MARK: - Search Bar

private struct SearchBarView: View {

    @Binding var query: String
    let isSearching: Bool
    @ObservedObject var theme: ThemeEngine
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(theme.secondaryTextColor)

            TextField("Search city...", text: $query)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(theme.textColor)
                .tint(theme.textColor)
                .submitLabel(.search)
                .autocorrectionDisabled()

            if isSearching {
                ProgressView().tint(theme.textColor).scaleEffect(0.85)
            } else if !query.isEmpty {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(theme.secondaryTextColor)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard(radius: 14, theme: theme)
        .animation(.easeInOut(duration: 0.2), value: query.isEmpty)
        .animation(.easeInOut(duration: 0.2), value: isSearching)
    }
}

// MARK: - Search Results

private struct SearchResultsView: View {

    let results: [CitySearchResult]
    @ObservedObject var theme: ThemeEngine
    let onSelect: (CitySearchResult) -> Void
    let onSave: (CitySearchResult) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.name)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.textColor)
                        Text("\(result.region), \(result.country)")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    Spacer()
                    Button { onSave(result) } label: {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 14))
                            .foregroundColor(theme.secondaryTextColor)
                            .padding(8)
                            .background(Circle().fill(theme.glassBackground))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .onTapGesture { onSelect(result) }

                if index < results.count - 1 {
                    Divider().overlay(theme.glassBorder).padding(.horizontal, 12)
                }
            }
        }
        .glassCard(radius: 16, theme: theme)
    }
}

// MARK: - Saved Locations

private struct SavedLocationsView: View {

    let locations: [SavedLocationEntry]
    @ObservedObject var theme: ThemeEngine
    let onSelect: (SavedLocationEntry) -> Void
    let onDelete: (SavedLocationEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SAVED LOCATIONS")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(1.5)
                .foregroundColor(theme.secondaryTextColor)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)

            ForEach(locations) { location in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(location.name)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.textColor)
                        Text(location.country)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.secondaryTextColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
                .onTapGesture { onSelect(location) }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation { onDelete(location) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }

                if location.id != locations.last?.id {
                    Divider().overlay(theme.glassBorder).padding(.horizontal, 12)
                }
            }
        }
        .glassCard(radius: 20, theme: theme)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Loading

private struct LoadingView: View {
    @ObservedObject var theme: ThemeEngine
    var body: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.5).tint(theme.textColor)
            Text("Fetching weather…")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(theme.secondaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Error Banner

private struct ErrorBannerView: View {
    let message: String
    @ObservedObject var theme: ThemeEngine
    let onRetry: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
            Text(message)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(theme.textColor)
                .lineLimit(2)
            Spacer()
            Button("Retry", action: onRetry)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.orange)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.orange.opacity(0.15)))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(.orange.opacity(0.4), lineWidth: 1))
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Glass card helper

private extension View {
    func glassCard(radius: CGFloat, theme: ThemeEngine) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(theme.glassBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(theme.glassBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
