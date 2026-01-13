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

### Basic Setup

Before using ARCMaps, configure it with your API keys and preferences:

```swift
import ARCMaps

// Configure in your AppDelegate or App struct
ARCMapsConfiguration.shared = ARCMapsConfiguration(
    googlePlacesAPIKey: "YOUR_GOOGLE_PLACES_API_KEY",
    defaultProvider: .google,
    maxCacheSize: 100,
    cacheExpirationSeconds: 3600
)
```

### Google Places API Key

To use the Google Places enrichment features:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Places API**
4. Create an API key under "Credentials"
5. (Optional) Restrict the API key to iOS apps for security

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
        // Configure ARCMaps
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
    @StateObject private var mapViewModel: MapViewModel

    init() {
        let logger = DefaultLogger()
        let locationService = CoreLocationService(logger: logger)

        _mapViewModel = StateObject(wrappedValue: MapViewModel(
            locationService: locationService,
            logger: logger
        ))
    }

    var body: some View {
        ARCMapView(viewModel: mapViewModel)
            .onAppear {
                mapViewModel.setPlaces(samplePlaces)
            }
    }

    private var samplePlaces: [MapPlace] {
        [
            MapPlace(
                id: "1",
                name: "La Taverna",
                coordinate: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
                address: "Calle Mayor 15, Madrid",
                status: .wishlist
            )
        ]
    }
}
```

## Next Steps

- Read the <doc:PlaceEnrichmentGuide> to learn about searching and enriching places
- Explore the <doc:MapVisualizationGuide> for advanced map features
- Check out the example project in the repository

## See Also

- ``ARCMapsConfiguration``
- ``PlaceEnrichmentService``
- ``ARCMapView``
