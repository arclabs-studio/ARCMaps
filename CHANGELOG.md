# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- iOS 18+ native map feature selection support with `MapFeatureSelectionMode`
- `FeatureSelectionMapView` for enhanced POI interaction on iOS 18+
- Comprehensive DocC documentation for all public APIs

### Changed
- Extracted magic numbers to named constants (`MapDefaults`, `CacheDefaults`, `ViewDefaults`)
- Improved documentation with code examples and platform availability notes

## [1.0.0] - 2026-01-13

### Added
- **PlaceEnrichment Module**
  - `GooglePlacesService` actor for Google Places API integration
  - `AppleMapsSearchService` for Apple MapKit search fallback
  - `InMemoryPlaceCache` actor for search result caching
  - `PlaceEnrichmentViewModel` for managing search state
  - Support for photos, reviews, ratings, hours, and contact info

- **MapVisualization Module**
  - `ARCMapView` SwiftUI component for interactive maps
  - `MapViewModel` with `@Observable` for reactive state management
  - `WishlistMarker` and `VisitedMarker` custom annotations
  - `PlaceCalloutView` for place detail sheets
  - `MapControlsView` for map style and fit controls
  - `MapFilter` with status, category, rating, and date filtering
  - `CoreLocationService` for user location handling

- **Shared Utilities**
  - `ExternalMapLauncher` for Apple Maps, Google Maps, and Waze integration
  - `DistanceCalculator` for coordinate distance calculations
  - `ARCMapsConfiguration` for package-wide settings
  - `CLLocationCoordinate2D` extensions for validation and distance

- **Testing Infrastructure**
  - `ARCMapsTestHelpers` target with mocks and fixtures
  - `MockNetworkClient`, `MockLocationService`, `MockPlaceSearchCache`
  - `PlaceSearchResultFixtures`, `MapPlaceFixtures`, `EnrichedPlaceDataFixtures`
  - 110 tests with Swift Testing framework

- **Developer Experience**
  - ARCDevTools integration with SwiftLint and SwiftFormat
  - Pre-commit hooks for code quality
  - Swift 6 strict concurrency compliance
  - DocC documentation catalog

### Security
- All services implemented as actors for thread safety
- `Sendable` conformance for all public types
- No external network calls without explicit configuration

[Unreleased]: https://github.com/carlosrasensio/ARCMaps/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/carlosrasensio/ARCMaps/releases/tag/v1.0.0
