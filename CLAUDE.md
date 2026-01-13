# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Build the package
swift build

# Run all tests
swift test

# Run a single test file
swift test --filter GooglePlacesServiceTests

# Run a specific test method
swift test --filter GooglePlacesServiceTests/testSearchPlaces_Success

# Generate documentation
swift package generate-documentation
```

## Architecture

ARCMaps is a Swift Package following Clean Architecture with two main modules:

### PlaceEnrichment Module
Handles place search and data enrichment from external APIs (Google Places, Apple MapKit).

- **Domain**: `PlaceSearchQuery`, `PlaceSearchResult`, `EnrichedPlaceData`, `PlaceEnrichmentService` protocol
- **Data**: `GooglePlacesService` (actor), `AppleMapsSearchService`, `InMemoryPlaceCache`, DTOs and mappers
- **Presentation**: `PlaceEnrichmentViewModel`

### MapVisualization Module
Provides interactive map display with filtering and navigation.

- **Domain**: `MapPlace`, `MapAnnotation`, `MapFilter`, `MapRegion`, `LocationService` protocol
- **Data**: `CoreLocationService`
- **Presentation**: `MapViewModel`
- **UI**: `ARCMapView`, `PlaceCalloutView`, custom markers

### Shared Module
Common utilities: `DistanceCalculator`, `ExternalMapLauncher`, coordinate extensions.

## Key Patterns

### Swift 6 Concurrency
- All services are `actor` types for thread safety
- ViewModels use `@MainActor`
- All types conform to `Sendable`
- StrictConcurrency is enabled in Package.swift

### Dependency Injection
Services take protocols in their initializers:
- `NetworkClientProtocol` for HTTP requests
- `LoggerProtocol` for logging
- `PlaceSearchCache` for caching
- `LocationService` for location updates

### Testing
Test helpers are in `ARCMapsTestHelpers` target:
- **Mocks**: `MockNetworkClient`, `MockPlaceEnrichmentService`, `MockLocationService`, `MockPlaceSearchCache`, `MockLogger`
- **Fixtures**: `PlaceSearchResultFixtures`, `MapPlaceFixtures`, `EnrichedPlaceDataFixtures`

Tests use async setUp/tearDown with `sut` (system under test) pattern.

## Configuration

The package requires configuration before use:
```swift
ARCMapsConfiguration.shared = ARCMapsConfiguration(
    googlePlacesAPIKey: "API_KEY",
    defaultProvider: .google
)
```

## Dependencies

External packages (currently commented out in Package.swift):
- `ARCLogger` - structured logging
- `ARCNetworking` - HTTP client

Internal stubs exist in `Shared/Utilities/` (`Logger.swift`, `NetworkClient.swift`) while external packages are unavailable.
