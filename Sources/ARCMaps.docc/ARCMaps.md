# ``ARCMaps``

Comprehensive mapping and place enrichment solution for iOS apps.

## Overview

ARCMaps provides two main functionalities that work seamlessly together:

1. **Place Enrichment**: Enrich place data with rich information from external providers (Google Places, Apple Maps Server)
2. **Map Visualization**: Display places on an interactive map with customizable markers, filters, and navigation capabilities

The package follows Clean Architecture principles with a modular, testable design that supports Swift 6 strict concurrency.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:PlaceEnrichmentGuide>
- <doc:MapVisualizationGuide>

### Place Enrichment

- ``PlaceEnrichmentService``
- ``PlaceSearchQuery``
- ``PlaceSearchResult``
- ``EnrichedPlaceData``
- ``GooglePlacesService``
- ``AppleMapsSearchService``
- ``PlaceSearchCache``
- ``InMemoryPlaceCache``

### Map Visualization

- ``ARCMapView``
- ``MapViewModel``
- ``MapPlace``
- ``MapFilter``
- ``MapRegion``
- ``MapStyle``
- ``LocationService``
- ``CoreLocationService``

### UI Components

- ``PlaceMarker``
- ``PlaceCalloutView``
- ``MapControlsView``

### Presentation Layer

- ``PlaceEnrichmentViewModel``
- ``MapViewModel``

### Configuration

- ``ARCMapsConfiguration``
- ``PlaceProvider``

### Shared Utilities

- ``DistanceCalculator``
- ``ExternalMapLauncher``
- ``ExternalMapApp``
- ``PlaceMapper``

### Error Handling

- ``PlaceEnrichmentError``
- ``MapError``
