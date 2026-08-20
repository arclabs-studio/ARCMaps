# Getting Started

Set up and configure ARCMaps in your iOS project.

## Overview

ARCMaps is a Swift Package that provides place enrichment and map visualization capabilities. This guide will help you integrate it into your project and get started with basic usage.

## Installation

### Swift Package Manager

Add ARCMaps to your project using Xcode:

1. Open your project in Xcode
2. Go to File > Add Package Dependencies...
3. Enter the repository URL: `https://github.com/yourusername/ARCMaps`
4. Select the version you want to use
5. Add the package to your target

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/ARCMaps.git", from: "1.0.0")
]
```

## Configuration

### Basic Setup — Google Places only

Before using ARCMaps, configure it with your API keys and preferences:

```swift
import ARCMaps

// Configure in your App struct initializer
ARCMapsConfiguration.shared = ARCMapsConfiguration(
    googlePlacesAPIKey: "YOUR_GOOGLE_PLACES_API_KEY",
    defaultProvider: .google,
    maxCacheSize: 100,
    cacheExpirationSeconds: 3600
)
```

### Full Setup — Google + Apple Maps Server

To also enable the Apple Maps Server API fallback, supply your Apple Developer credentials:

```swift
ARCMapsConfiguration.shared = ARCMapsConfiguration(
    googlePlacesAPIKey: "YOUR_GOOGLE_PLACES_API_KEY",
    appleMapsKeyID: "XXXXXXXXXX",          // 10-char Key ID from Apple Developer Portal
    appleMapsTeamID: "XXXXXXXXXX",         // 10-char Team ID from Membership details
    appleMapsPrivateKey: """
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByq...
        -----END PRIVATE KEY-----
        """,
    defaultProvider: .google
)
```

When all three credentials are present the search fallback chain becomes:
**Google Places → Apple Maps Server → Apple MapKit (on-device)**

### Google Places API Key

To use the Google Places enrichment features:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Places API**
4. Create an API key under "Credentials"
5. (Optional) Restrict the API key to iOS apps for security

### Apple Maps Server API Credentials

To use the Apple Maps Server API:

1. Sign in to the [Apple Developer Portal](https://developer.apple.com/account/)
2. Under **Certificates, Identifiers & Profiles → Keys**, create a new key with **Maps** capability
3. Download the `.p8` private key file (keep it safe — it can only be downloaded once)
4. Note the **Key ID** and your **Team ID** (found under Membership details)

### Privacy Permissions

Add the required privacy descriptions to your `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby places on the map</string>
```

## Quick Example

Here's a simple example showing place enrichment and map visualization:

```swift
import SwiftUI
import ARCMaps

@main
struct MyApp: App {
    init() {
        ARCMapsConfiguration.shared = ARCMapsConfiguration(
            googlePlacesAPIKey: "YOUR_API_KEY",
            defaultProvider: .google
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var viewModel = MapViewModel(
        locationService: CoreLocationService()
    )

    var body: some View {
        ARCMapView(viewModel: viewModel)
            .onAppear {
                viewModel.setPlaces(samplePlaces)
            }
    }

    private var samplePlaces: [MapPlace] {
        [
            MapPlace(
                id: "1",
                name: "La Taverna",
                coordinate: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
                address: "Calle Mayor 15, Madrid",
                category: "restaurant",
                rating: 4.5
            ),
            MapPlace(
                id: "2",
                name: "Museo del Prado",
                coordinate: CLLocationCoordinate2D(latitude: 40.4138, longitude: -3.6922),
                address: "Paseo del Prado, Madrid",
                category: "museum",
                rating: 4.9
            )
        ]
    }
}
```

## Bridging Search Results to the Map

Use ``PlaceMapper`` to convert a ``PlaceSearchResult`` (from enrichment) directly into a ``MapPlace`` (for the map):

```swift
// After a place search...
let results = try await enrichmentViewModel.searchPlaces(query: query)

// Convert the selected result and add it to the map
let mapPlace = PlaceMapper.toMapPlace(results[0])
mapViewModel.setPlaces([mapPlace])
```

## Next Steps

- Read the <doc:PlaceEnrichmentGuide> to learn about searching and enriching places
- Explore the <doc:MapVisualizationGuide> for advanced map features including custom markers and filtering
- Check out the example project in the repository

## See Also

- ``ARCMapsConfiguration``
- ``PlaceEnrichmentService``
- ``PlaceMapper``
- ``ARCMapView``
