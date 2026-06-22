// Presentation/Theme/ThemeBackground.swift
// WeatherCast App
// Reusable full-screen background: time-based photo + subtle readability overlay

import SwiftUI

/// Drop this behind any screen that needs the time-aware sky background.
/// Usage:
///   ZStack {
///       ThemeBackground(theme: theme)
///       // … your content …
///   }
struct ThemeBackground: View {

    @ObservedObject var theme: ThemeEngine

    var body: some View {
        ZStack {
            // MARK: Background photo (from asset catalog)
            Image(theme.backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                // Animate a cross-fade whenever the theme changes
                .animation(.easeInOut(duration: 1.2), value: theme.backgroundImageName)

            // MARK: Readability overlay
            // A very thin tint so text always wins over the image detail.
            theme.imageOverlayColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.2), value: theme.isMorning)
        }
    }
}
