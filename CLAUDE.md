# ARCMaps - Claude Code Development Guide

## 📋 Project Overview

ARCMaps is a comprehensive Swift Package for iOS and macOS that provides advanced mapping and place enrichment capabilities. This package is designed following Clean Architecture principles with a modular, testable, and extensible structure.

## 🎯 Main Features

### 1. Place Enrichment
Automatically enrich manually-created restaurant entries with external data from:
- **Google Places API**: Comprehensive place data including photos, reviews, ratings, and business hours
- **Apple MapKit Search**: Native iOS search capabilities as a fallback option

The enrichment service allows apps to:
- Search for places by name and location
- Retrieve detailed information (photos, ratings, reviews, hours)
- Download and cache place photos
- Provide automatic fallback between providers

### 2. Map Visualization
Interactive map display with:
- **Custom Markers**: Distinctive markers for wishlist vs. visited places
- **Smart Filtering**: Filter by status, category, rating, and date range
- **User Location**: Integration with CoreLocation for proximity features
- **External Navigation**: Launch navigation in Apple Maps, Google Maps, or Waze
- **Multiple Map Styles**: Standard, Satellite, and Hybrid views

## 🏗️ Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (ViewModels + SwiftUI Views)       │
├─────────────────────────────────────┤
│         Domain Layer                │
│   (Models + Protocols)              │
├─────────────────────────────────────┤
│          Data Layer                 │
│  (Services + DTOs + Mappers)        │
└─────────────────────────────────────┘
```

### Module Structure

1. **PlaceEnrichment Module**
   - Domain: Models and protocols for place search and enrichment
   - Data: Google Places and Apple Maps service implementations
   - Presentation: ViewModels for search and selection flows

2. **MapVisualization Module**
   - Domain: Map-specific models and protocols
   - Data: MapKit provider and location services
   - Presentation: ViewModels for map state
   - UI: SwiftUI views for map display

3. **Shared Module**
   - Common extensions and utilities
   - Distance calculations
   - External map launching

## 🔧 Technical Specifications

### Swift Version & Concurrency
- **Swift 6.0** with strict concurrency checking enabled
- Full async/await support
- Actor-based services for thread safety
- Sendable protocol conformance

### Platform Support
- iOS 17.0+
- macOS 14.0+

### Key Technologies
- SwiftUI for all UI components
- MapKit for native map rendering
- CoreLocation for location services
- Structured concurrency (async/await, actors)

## 📁 Package Structure

```
ARCMaps/
├── Sources/
│   ├── ARCMaps/                    # Main library target
│   │   ├── PlaceEnrichment/        # Place search & enrichment
│   │   ├── MapVisualization/       # Map display & interaction
│   │   ├── Shared/                 # Common utilities
│   │   └── Configuration/          # Package configuration
│   └── ARCMapsTestHelpers/         # Test support library
│       ├── Mocks/                  # Mock implementations
│       └── Fixtures/               # Test data
├── Tests/
│   └── ARCMapsTests/               # Unit tests
└── ARCMaps.docc/                   # DocC documentation
```

## 🔌 Dependencies

### External Packages
- **ARCLogger**: Structured logging (assumed local package)
- **ARCNetworking**: HTTP client abstraction (assumed local package)

### Apple Frameworks
- Foundation
- SwiftUI
- MapKit
- CoreLocation

## 🧪 Testing Strategy

### Coverage Goals
- Minimum 95% code coverage
- 100% coverage for business logic

### Test Types
1. **Unit Tests**: All services, mappers, and view models
2. **Integration Tests**: Service interactions with mocked networking
3. **Concurrency Tests**: Actor isolation and async flows

### Test Helpers
- `MockPlaceEnrichmentService`: Simulates API responses
- `MockLocationService`: Simulates location updates
- `Fixtures`: Pre-defined test data for consistent testing

## 📝 Code Style & Best Practices

### Naming Conventions
- Protocols: Descriptive names ending with `Service`, `Provider`, or `Protocol`
- Actors: End with `Service` for thread-safe service actors
- Models: Clear, descriptive nouns (e.g., `PlaceSearchResult`, `MapPlace`)
- ViewModels: End with `ViewModel`, marked `@MainActor`

### Error Handling
- Custom error types: `PlaceEnrichmentError`, `MapError`
- Localized error messages
- Graceful fallbacks where appropriate

### Async/Await Guidelines
- All network operations use async/await
- Actors for services with mutable state
- `@MainActor` for ViewModels and UI code

### Documentation
- DocC comments for all public APIs
- Code examples in documentation
- Inline comments for complex logic only

## 🚀 Getting Started (for Developers)

### Initial Setup
1. Clone the repository
2. Open `Package.swift` in Xcode
3. Resolve package dependencies
4. Build and run tests

### Building
```bash
swift build
```

### Running Tests
```bash
swift test
```

### Generating Documentation
```bash
swift package generate-documentation
```

## 🔐 API Keys Configuration

### Google Places API
Users must provide their own API key:

```swift
import ARCMaps

// Configure before using place enrichment
ARCMapsConfiguration.shared = ARCMapsConfiguration(
    googlePlacesAPIKey: "YOUR_API_KEY_HERE",
    defaultProvider: .google
)
```

### Privacy Requirements
Apps using ARCMaps must include in `Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby places on the map</string>
```

## 🎨 Usage Examples

### Place Enrichment Flow
```swift
import ARCMaps

// Create services
let service = GooglePlacesService(
    apiKey: "YOUR_KEY",
    networkClient: networkClient,
    logger: logger,
    cache: cache
)

// Search for places
let query = PlaceSearchQuery(
    name: "La Taverna",
    address: "Madrid"
)

let results = try await service.searchPlaces(query: query)

// Get detailed information
if let firstResult = results.first {
    let details = try await service.getPlaceDetails(placeId: firstResult.id)
    print("Rating: \(details.rating ?? 0)")
}
```

### Map Visualization
```swift
import ARCMaps
import SwiftUI

struct RestaurantMapView: View {
    @StateObject private var viewModel: MapViewModel
    let restaurants: [MapPlace]

    var body: some View {
        ARCMapView(viewModel: viewModel)
            .onAppear {
                viewModel.setPlaces(restaurants)
                viewModel.fitAllPlaces()
            }
    }
}
```

## 🐛 Known Limitations

1. **Google Maps SDK**: Not available via SPM; only MapKit is used for rendering
2. **Photo Caching**: In-memory only; no persistent cache
3. **Rate Limiting**: Google Places API limits apply; implement client-side throttling
4. **Offline Mode**: No offline support; requires network connectivity

## 🔮 Future Enhancements

- [ ] Persistent cache for place data and photos
- [ ] Support for Google Maps SDK rendering
- [ ] Clustering for large numbers of markers
- [ ] Route planning and directions
- [ ] Offline mode with pre-downloaded data
- [ ] Additional providers (Yelp, Foursquare)

## 📚 Additional Resources

- [Apple MapKit Documentation](https://developer.apple.com/documentation/mapkit/)
- [Google Places API Documentation](https://developers.google.com/maps/documentation/places/web-service)
- [Swift Concurrency Guide](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)

## 🤝 Contributing

This package follows semantic versioning and maintains backward compatibility within major versions.

### Development Workflow
1. Create a feature branch from `main`
2. Implement changes with full test coverage
3. Update documentation
4. Submit pull request with detailed description

## 📄 License

MIT License - See LICENSE file for details

---

**Maintained by ARC Labs Studio**
