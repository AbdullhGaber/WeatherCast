# WeatherCast 🌤️

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9-F05138?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/SwiftUI-4.0-0073CF?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/iOS-17.0+-black?style=for-the-badge&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/Xcode-16.0+-1575F9?style=for-the-badge&logo=xcode&logoColor=white" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Alamofire-5.x-EE4E4E?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/Swinject-2.9-7B68EE?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/SwiftData-1.0-34C759?style=for-the-badge&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/Combine-Built--in-FF6B35?style=for-the-badge&logo=apple&logoColor=white" />
</p>

<p align="center">
  A production-ready iOS weather application with glassmorphism UI, time-aware theming, and clean architecture.
</p>

---

## ✨ Features

- **Real-time Weather** — Current conditions, temperature, humidity, visibility, pressure, and feels-like for any city worldwide
- **3-Day Forecast** — Scrollable forecast cards with daily high/low and condition icons
- **Hourly Breakdown** — Tap any forecast day to drill into its 24-hour timeline
- **City Search** — Debounced live search powered by WeatherAPI's autocomplete endpoint
- **Saved Locations** — Persist favourite cities locally with SwiftData; swipe-to-delete
- **Time-Aware Theming** — Background and text colours change based on the **weather location's** local clock, not the device clock:
  - ☀️ **Morning** (05:00–17:59 local) → bright sky photo · black text
  - 🌙 **Evening** (18:00–04:59 local) → night sky photo · white text
- **Glassmorphism Cards** — All metric and forecast cards use frosted-glass styling that adapts to the background photo
- **Smooth Animations** — Spring-based staggered entrance animations on every card and row

---

## 🏗️ Architecture

WeatherCast follows **Clean Architecture + MVVM** with a strict unidirectional data flow:

```
View  ──▶  ViewModel  ──▶  UseCase (Domain)  ──▶  Repository  ──▶  Service / SwiftData
  ◀──────────────────────────────────────────────────────────────────────────────────
                              Published State / Combine Pipelines
```

### Layer breakdown

| Layer | Responsibility | Key files |
|---|---|---|
| **Domain** | Pure Swift entities & use-case protocols | `WeatherEntity`, `FetchWeatherUseCase`, `SavedLocationsUseCase` |
| **Data** | Repository implementations, DTOs, networking | `WeatherRepositoryImpl`, `WeatherAPIService`, `WeatherResponseDTO` |
| **Presentation** | SwiftUI views, ViewModels, ThemeEngine | `DashboardView`, `DashboardViewModel`, `ThemeEngine` |
| **DI** | Single Swinject container | `AppContainer` |

### Folder structure

```
weather_app/
├── DI/
│   └── AppContainer.swift          # Swinject container — all registrations
├── Domain/
│   ├── Entities/
│   │   ├── WeatherEntity.swift
│   │   ├── ForecastDayEntity.swift
│   │   └── HourEntity.swift
│   └── UseCases/
│       ├── FetchWeatherUseCase.swift
│       └── SavedLocationsUseCase.swift
├── Data/
│   ├── Remote/
│   │   ├── WeatherAPIService.swift  # Alamofire + Combine
│   │   └── DTOs/
│   │       └── WeatherResponseDTO.swift
│   ├── Local/
│   │   └── SavedLocationModel.swift # SwiftData @Model
│   └── Repositories/
│       └── WeatherRepositoryImpl.swift
└── Presentation/
    ├── Theme/
    │   ├── ThemeEngine.swift        # Location-aware time engine
    │   └── ThemeBackground.swift
    ├── Dashboard/
    │   ├── DashboardView.swift
    │   ├── DashboardViewModel.swift
    │   └── Components/
    │       ├── CurrentWeatherHeaderView.swift
    │       ├── ForecastListView.swift
    │       ├── ForecastRowView.swift
    │       └── MetricsGridView.swift
    └── HourlyForecast/
        └── HourlyForecastView.swift
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| [Alamofire](https://github.com/Alamofire/Alamofire) | 5.x | HTTP networking with Combine support |
| [Swinject](https://github.com/Swinject/Swinject) | 2.9.1 | Dependency injection container |
| **SwiftData** *(Apple)* | iOS 17+ | Local persistence for saved locations |
| **Combine** *(Apple)* | Built-in | Reactive data-binding and async pipelines |

All dependencies are managed via **Swift Package Manager (SPM)**.

---

## 🔑 API

WeatherCast uses the **[WeatherAPI](https://www.weatherapi.com/)** (free tier).

| Endpoint | Used for |
|---|---|
| `/v1/forecast.json` | Current weather + 3-day forecast + hourly data |
| `/v1/search.json` | City autocomplete search |

> The API key is embedded in `WeatherAPIService.swift` for development convenience. For production, move it to a `.xcconfig` / environment variable or a secrets manager.

---

## 🚀 Getting Started

### Prerequisites

- macOS 14+
- Xcode 16+
- iOS 17+ simulator or device

### Setup

```bash
# Clone the repo
git clone https://github.com/AbdullhGaber/WeatherCast.git
cd WeatherCast

# Open in Xcode (SPM packages resolve automatically)
open weather_app.xcodeproj
```

Then press **⌘R** to build and run on the iPhone 16 simulator.

> **No extra configuration needed.** SwiftData creates its store automatically on first launch. The Swinject container boots in `weather_appApp.init()` before any view renders.

---

## 🧩 Dependency Injection

A single `AppContainer.shared` (Swinject) owns all object graph wiring:

```swift
// Resolved from anywhere — zero manual construction
let vm = AppContainer.shared.resolve(DashboardViewModel.self)
```

Registration order: **Infrastructure → Remote → Repository → UseCases → ViewModels**

Object scopes:

| Type | Scope | Rationale |
|---|---|---|
| `WeatherAPIService` | `.container` | One shared Alamofire session |
| `WeatherRepositoryImpl` | `.container` | Stateless — no benefit duplicating |
| `ModelContext` | `.container` | SwiftData requires a single shared context |
| `DashboardViewModel` | `.transient` | Fresh state on each navigation entry |

---

## 🎨 Theme Engine

`ThemeEngine` is a `@MainActor` singleton that reads the **weather location's** local time (not the device clock):

```
WeatherAPI response → location.localtime → WeatherEntity.localHour
    → ThemeEngine.setLocationHour(_:) → .morning / .evening
```

This means searching **San Salvador** at 7 AM Cairo time correctly shows the **night theme**, because San Salvador is at 10 PM.

---

## 📄 License

```
MIT License — Copyright (c) 2026 AbdullhGaber
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files, to deal in the Software
without restriction.
```
