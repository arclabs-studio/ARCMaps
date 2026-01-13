# 🗺️ ARCMaps

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%2B%20%7C%20macOS%2014%2B-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)](CHANGELOG.md)
[![CI](https://github.com/carlosrasensio/ARCMaps/actions/workflows/ci.yml/badge.svg)](https://github.com/carlosrasensio/ARCMaps/actions/workflows/ci.yml)

**A comprehensive Swift Package for place enrichment and map visualization in iOS and macOS apps.**

Place Search & Enrichment | Interactive Maps | Custom Markers | External Navigation | Smart Caching

---

## Overview

ARCMaps provides a complete solution for building location-based features in your apps. It combines powerful place search capabilities with rich map visualization, offering a seamless experience for users exploring and saving locations.

The package is built with Clean Architecture principles, ensuring testability, maintainability, and flexibility. It supports multiple search providers (Google Places API and Apple MapKit) with automatic fallback, and includes a sophisticated caching layer for optimal performance.

Whether you're building a restaurant tracker, travel planner, or any location-centric app, ARCMaps provides the building blocks you need with a SwiftUI-first approach.

### Key Features

- **Multi-Provider Search** - Google Places API with Apple MapKit fallback
- **Rich Place Data** - Photos, reviews, ratings, hours, and contact information
- **Interactive Maps** - Native MapKit with custom markers and filtering
- **iOS 18+ Enhancements** - Native POI selection with Apple callouts
- **External Navigation** - Launch Apple Maps, Google Maps, or Waze
- **Smart Caching** - Automatic result caching with configurable TTL
- **Swift 6 Ready** - Full async/await and strict concurrency support

---

## Requirements

| Requirement | Minimum Version |
|-------------|-----------------|
| **Swift** | 6.0+ |
| **iOS** | 17.0+ |
| **macOS** | 14.0+ |
| **Xcode** | 16.0+ |

### Optional Dependencies

- **Google Places API Key** - Required for Google provider (recommended)
- **Apple MapKit** - Built-in, no additional setup needed

---

## Installation

### Swift Package Manager

#### For Xcode Projects

1. **File > Add Package Dependencies**
2. Enter: `https://github.com/carlosrasensio/ARCMaps.git`
3. Select version: `1.0.0` or later
4. Add to your target

#### For Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/carlosrasensio/ARCMaps.git", from: "1.0.0")
]
```

Then add `ARCMaps` to your target dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: ["ARCMaps"]
)
```

### Configuration

Configure the package before using any services, typically in your app's initialization:

```swift
import ARCMaps

@main
struct MyApp: App {
    init() {
        ARCMapsConfiguration.shared = ARCMapsConfiguration(
            googlePlacesAPIKey: "YOUR_GOOGLE_PLACES_API_KEY",
            defaultProvider: .google,
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
```

---

## Usage

### Quick Start - Display a Map

```swift
import SwiftUI
import ARCMaps

struct ContentView: View {
    @State private var viewModel = MapViewModel(
        locationService: CoreLocationService()
    )

    var body: some View {
        ARCMapView(viewModel: viewModel)
            .onAppear {
                viewModel.setPlaces(myPlaces)
            }
    }
}
```

### Search for Places

```swift
import ARCMaps

struct PlaceSearchView: View {
    @State private var viewModel = PlaceEnrichmentViewModel(
        service: GooglePlacesService()
    )

    var body: some View {
        List(viewModel.searchResults, id: \.id) { result in
            Text(result.name)
        }
        .searchable(text: $viewModel.searchQuery)
        .task(id: viewModel.searchQuery) {
            await viewModel.search(query: viewModel.searchQuery)
        }
    }
}
```

### Filter Map Places

```swift
// Filter by status
viewModel.updateFilter(MapFilter(statuses: [.wishlist]))

// Filter by category and rating
viewModel.updateFilter(MapFilter(
    categories: [.restaurant, .cafe],
    minimumRating: 4.0
))

// Filter by date range
viewModel.updateFilter(MapFilter(
    dateRange: DateRange(start: lastMonth, end: today)
))
```

### iOS 18+ Native POI Selection

```swift
// Enable native Apple Maps POI interaction
ARCMapView(
    viewModel: viewModel,
    featureSelectionMode: .pointsOfInterestOnly
)
```

### External Navigation

```swift
// Open place in external maps app
try await ExternalMapLauncher.open(
    coordinate: place.coordinate,
    name: place.name,
    app: .appleMaps  // or .googleMaps, .waze
)
```

---

## Architecture

ARCMaps follows Clean Architecture with two main modules:

```
ARCMaps/
├── PlaceEnrichment/           # Place search and data enrichment
│   ├── Domain/                # Entities, protocols, business logic
│   ├── Data/                  # Services, cache, DTOs, mappers
│   └── Presentation/          # ViewModels
│
├── MapVisualization/          # Interactive map display
│   ├── Domain/                # MapPlace, MapFilter, MapRegion
│   ├── Data/                  # CoreLocationService
│   ├── Presentation/          # MapViewModel
│   └── UI/                    # ARCMapView, markers, callouts
│
└── Shared/                    # Common utilities
    └── Utilities/             # Distance, external launchers
```

For complete architecture guidelines, see [ARCKnowledge](https://github.com/arclabs-studio/ARCKnowledge).

---

## Testing

ARCMaps includes comprehensive testing infrastructure:

```bash
# Run all tests
swift test

# Run specific test file
swift test --filter GooglePlacesServiceTests
```

### Test Helpers

The `ARCMapsTestHelpers` target provides mocks and fixtures:

```swift
import ARCMapsTestHelpers

// Use mocks for testing
let mockService = MockPlaceEnrichmentService()
let mockLocation = MockLocationService()
let mockCache = MockPlaceSearchCache()

// Use fixtures for test data
let places = MapPlaceFixtures.samplePlaces
let results = PlaceSearchResultFixtures.sampleResults
```

### Coverage

- **Current:** 110 tests
- **Target:** 100% for business logic

---

## Development

### Prerequisites

```bash
# Install required tools
brew install swiftlint swiftformat
```

### Setup

```bash
# Clone with submodules
git clone --recursive https://github.com/carlosrasensio/ARCMaps.git
cd ARCMaps

# Or initialize submodules after cloning
git submodule update --init --recursive

# Build the project
swift build
```

### Available Commands

```bash
make help          # Show all available commands
make lint          # Run SwiftLint
make format        # Preview formatting changes
make fix           # Apply SwiftFormat
make test          # Run tests
make clean         # Remove build artifacts
```

---

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `feature/your-feature`
3. Follow [ARCKnowledge](https://github.com/arclabs-studio/ARCKnowledge) standards
4. Ensure tests pass: `swift test`
5. Run quality checks: `make lint && make fix`
6. Create a pull request

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new place category filter
fix: resolve crash when location permission denied
docs: update installation instructions
```

---

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** - Breaking changes
- **MINOR** - New features (backwards compatible)
- **PATCH** - Bug fixes (backwards compatible)

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🔗 Related Resources

- **[ARCKnowledge](https://github.com/arclabs-studio/ARCKnowledge)** - Development standards and guidelines
- **[ARCDevTools](https://github.com/arclabs-studio/ARCDevTools)** - Quality tooling and automation
- **[ARCLogger](https://github.com/arclabs-studio/ARCLogger)** - Structured logging framework

---

<div align="center">

**Made with love by ARC Labs Studio**

[GitHub](https://github.com/arclabs-studio) | [Issues](https://github.com/carlosrasensio/ARCMaps/issues)

</div>
