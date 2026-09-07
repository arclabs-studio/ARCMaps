# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2026-09-07

### Added

- **`PlaceCompletionScope`** — `all` / `addresses` / `administrativeAreas`, replacing the raw `MKLocalSearchCompleter.ResultType` parameter on `AppleMapsCompletionService`. An address *field* usually wants towns and neighbourhoods, not venues and not streets: typing "torrelodon" should offer "Torrelodones, Madrid", not "Calle Torrelodones" or a health centre on it. Expressing that needed a result-type mask *and* an `MKAddressFilter`, which is exactly the MapKit detail a caller should not have to know.

  `.administrativeAreas` requires iOS 18 / macOS 15 for the address filter; on earlier systems it degrades to `.addresses`, so venues are still excluded and streets are not.

### Changed

- `AppleMapsCompletionService.init` now takes `scope:` instead of `resultTypes:`. Source-breaking for anyone who passed `resultTypes` explicitly; the default (`.all`) matches the previous default behaviour.

## [1.1.0] - 2026-09-06

### Added

- **`PlaceCompleting`** — place autocompletion as a first-class capability, separate from `PlaceEnrichmentService`. Enrichment is request/response; completion is incremental, keeping a live query fragment that the provider republishes results for as the user types. Folding the two together would have forced every enrichment implementation to carry state it does not have.

- **`PlaceCompletion`** — a suggestion with `id`, `title` and `subtitle`, and deliberately no coordinate: the provider has not resolved the place yet. `resolve(_:)` turns a picked suggestion into a full `PlaceSearchResult`.

- **`AppleMapsCompletionService`** — the MapKit implementation, backed by `MKLocalSearchCompleter`. Debounces internally (250 ms by default), ignores fragments under three characters, biases results to a caller-supplied `MapRegion`, and deduplicates repeated title/subtitle pairs so list identity stays stable.

- **`MockPlaceCompletionService`** in `ARCMapsTestHelpers`.

### Changed

- `AppleMapsSearchService` now maps `MKMapItem` through the new internal `AppleMapsPlaceMapper` instead of its own private helpers. Both Apple-backed services must agree on the identifier and the address format, or the same place would arrive with two different ids depending on whether the user typed it or picked a suggestion. No behaviour change.

## [1.0.0] - 2026-08-20

First public release of **ARCMaps**.

ARC Labs Studio re-baselined every package at `1.0.0` for its first product launch. The pre-launch version history (0.1.0 → 1.0.0) never corresponded to a release the studio stood behind; those tags and GitHub Releases have been removed and the notes are preserved below under [Pre-1.0 history](#pre-10-history-untagged).

### Added

- **`INTERNAL-USE.md`** — documents ARC Labs Studio's self-grant for commercial use of its own products under the new licence.

- iOS 18+ native map feature selection support with `MapFeatureSelectionMode`
- `FeatureSelectionMapView` for enhanced POI interaction on iOS 18+
- Comprehensive DocC documentation for all public APIs

- `ARCUIComponents` dependency for consistent UI components across ARC packages

### Changed

- **ARCUIComponents dependency** — converted from a `branch: "develop"` pin to `from: "1.0.0"`. SPM refuses branch requirements in a versioned package, so this package could not be released until the pin was converted.

- `PlaceCalloutView`: status badge now uses `ARCTag` (filled style, semantic green/red) instead of a custom hand-rolled pill
- `PlaceCalloutView`: rating display now uses `ARCRatingView` with `.compactInline` style instead of a custom star+text `HStack`
- Extracted magic numbers to named constants (`MapDefaults`, `CacheDefaults`, `ViewDefaults`)
- Improved documentation with code examples and platform availability notes

- **License** — relicensed from MIT to [PolyForm Noncommercial 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0). Source-available and free for non-commercial use; commercial use requires a separate licence from ARC Labs Studio. ARC Labs Studio's own products are covered by an internal grant — see `INTERNAL-USE.md`.

### Fixed

- **Install URLs** — the README pointed at `github.com/carlosrasensio/ARCMaps`, a personal fork. All references now use `github.com/arclabs-studio/ARCMaps`.

---

## Pre-1.0 history (untagged)

Everything below predates the 1.0.0 baseline. The version numbers are retained for traceability only — no tag or release exists for any of them.

### [1.0.0] - 2026-01-13

#### Added
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

#### Security
- All services implemented as actors for thread safety
- `Sendable` conformance for all public types
- No external network calls without explicit configuration

---

[1.0.0]: https://github.com/arclabs-studio/ARCMaps/releases/tag/v1.0.0
