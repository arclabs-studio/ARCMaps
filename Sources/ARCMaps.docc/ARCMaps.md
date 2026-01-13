# ``ARCMaps``

Comprehensive mapping and place enrichment solution for iOS apps.

## Overview

ARCMaps provides two main functionalities that work seamlessly together:

1. **Place Enrichment**: Automatically enrich manually-created restaurant entries with rich data from external providers
2. **Map Visualization**: Display places on an interactive map with custom markers, filters, and navigation capabilities

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
- ``PlaceStatus``
- ``MapFilter``
- ``MapRegion``
- ``MapStyle``
- ``LocationService``
- ``CoreLocationService``

### UI Components

- ``WishlistMarker``
- ``VisitedMarker``
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

### Error Handling

- ``PlaceEnrichmentError``
- ``MapError``
