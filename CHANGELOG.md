# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Annotation clustering** — nearby places collapse into a single bubble as the map zooms out, replacing the unreadable pin stacks that appeared at country and world zoom
  - `MapCluster` and `MapAnnotationItem` domain models
  - `PlaceClusterer`, a pure `Sendable` grid clusterer, and `ZoomBucket`, which snaps the camera span to discrete rungs so clusters only re-form on meaningful zoom changes
  - `MapViewModel.annotationItems`, `updateCameraSpan(_:)`, and `selectCluster(_:)`; tapping a cluster zooms to fit its members
  - `ClusterMarker`, the default cluster bubble, plus a `cluster:` `@ViewBuilder` on `ARCMapView` for custom bubbles
  - `MapViewModel.clusteringEnabled` and `showsAnnotationTitles` toggles
- iOS 18+ native map feature selection support with `MapFeatureSelectionMode`
- `FeatureSelectionMapView` for enhanced POI interaction on iOS 18+
- Comprehensive DocC documentation for all public APIs

### Added
- `ARCUIComponents` dependency for consistent UI components across ARC packages

### Changed
- **`ARCMapView` gained a third generic parameter**, `ClusterContent`. Existing initialisers pin it to `ClusterMarker`, so call sites keep compiling — but code that spells the type explicitly (`ARCMapView<Marker, Sheet>`) must add the third argument
- **Clustering is enabled by default.** Maps that previously drew every pin will now group them when zoomed out. Set `MapViewModel.clusteringEnabled = false` to restore the old behaviour
- **Annotation titles are hidden by default.** Place names no longer render beneath markers, since the labels are a large part of what makes dense areas unreadable. Set `MapViewModel.showsAnnotationTitles = true` to restore them
- `PlaceCalloutView`: status badge now uses `ARCTag` (filled style, semantic green/red) instead of a custom hand-rolled pill
- `PlaceCalloutView`: rating display now uses `ARCRatingView` with `.compactInline` style instead of a custom star+text `HStack`
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
