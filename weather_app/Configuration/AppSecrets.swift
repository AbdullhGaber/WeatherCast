// Configuration/AppSecrets.swift
// WeatherCast App
// Reads secrets that were injected into Info.plist from Secrets.xcconfig at build time.
// ⚠️  This file IS committed — it contains no real secrets, only the Bundle lookup logic.

import Foundation

enum AppSecrets {

    /// WeatherAPI key — injected from `Configuration/Secrets.xcconfig` → Info.plist at build time.
    /// To set up: copy `Secrets.xcconfig.example` → `Secrets.xcconfig` and fill in your key.
    static var weatherAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "WeatherAPIKey") as? String,
              !key.isEmpty,
              key != "YOUR_WEATHERAPI_KEY_HERE"
        else {
            assertionFailure(
                "⚠️ WeatherAPIKey not set. Copy Configuration/Secrets.xcconfig.example " +
                "→ Configuration/Secrets.xcconfig and fill in your API key."
            )
            return ""
        }
        return key
    }
}
