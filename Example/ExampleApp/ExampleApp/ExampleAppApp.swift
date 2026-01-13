//
//  ExampleAppApp.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import ARCMaps
import SwiftUI

/// Main entry point for the ARCMaps Example App.
///
/// This demo app showcases the main features of ARCMaps:
/// - Map visualization with custom markers
/// - Place filtering by status, category, and rating
/// - Native Apple Maps POI selection (iOS 18+)
@main
struct ExampleAppApp: App {
    init() {
        // Configure ARCMaps with default settings
        // Note: For Google Places API, provide your API key here
        ARCMapsConfiguration.shared = ARCMapsConfiguration(
            googlePlacesAPIKey: nil, // Add your Google Places API key here
            defaultProvider: .apple,
            maxCacheSize: 100,
            cacheExpirationSeconds: 3600
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
