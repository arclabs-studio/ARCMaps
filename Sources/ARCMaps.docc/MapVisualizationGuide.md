# Map Visualization Guide

Display places on an interactive map with custom markers and filters.

## Overview

The Map Visualization module provides SwiftUI components to display places on a map with distinctive markers for wishlist vs. visited places, along with filtering and navigation capabilities.

## Basic Map Display

### Simple Map View

Display places on a map:

```swift
import SwiftUI
import MapKit
import ARCMaps

struct RestaurantMapView: View {
    @StateObject private var viewModel: MapViewModel

    init() {
        let logger = DefaultLogger()
        let locationService = CoreLocationService(logger: logger)

        _viewModel = StateObject(wrappedValue: MapViewModel(
            locationService: locationService,
            logger: logger
        ))
    }

    var body: some View {
        ARCMapView(viewModel: viewModel)
            .onAppear {
                viewModel.setPlaces(myPlaces)
                viewModel.fitAllPlaces()
            }
    }

    private var myPlaces: [MapPlace] {
        [
            MapPlace(
                id: "1",
                name: "La Taverna",
                coordinate: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
                address: "Calle Mayor 15, Madrid",
                category: "Restaurant",
                rating: 4.5,
                status: .wishlist
            ),
            MapPlace(
                id: "2",
                name: "El Café",
                coordinate: CLLocationCoordinate2D(latitude: 40.4200, longitude: -3.7050),
                address: "Gran Vía 20, Madrid",
                category: "Cafe",
                rating: 4.2,
                status: .visited,
                visitDate: Date()
            )
        ]
    }
}
```

## Filtering Places

### Status Filter

Filter places by status (wishlist/visited):

```swift
// Show only wishlist places
var filter = MapFilter()
filter.statuses = [.wishlist]
viewModel.updateFilter(filter)

// Show only visited places
filter.statuses = [.visited]
viewModel.updateFilter(filter)

// Show all
viewModel.updateFilter(.all)
```

### Category Filter

Filter by category:

```swift
var filter = MapFilter()
filter.categories = ["Restaurant", "Cafe"]
viewModel.updateFilter(filter)
```

### Rating Filter

Show only highly-rated places:

```swift
var filter = MapFilter()
filter.minRating = 4.0
viewModel.updateFilter(filter)
```

### Date Range Filter

Filter visited places by date:

```swift
let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
var filter = MapFilter()
filter.dateRange = DateRange(start: lastMonth, end: Date())
viewModel.updateFilter(filter)
```

## Map Interaction

### Selecting Places

Handle place selection:

```swift
// The place callout is shown automatically when tapping a marker
// Access the selected place:
if let selected = viewModel.selectedPlace {
    print("Selected: \(selected.name)")
}

// Programmatically select a place:
viewModel.selectPlace(myPlace)
```

### Camera Control

Control the map camera:

```swift
// Center on a specific place
viewModel.centerOnPlace(place, animated: true)

// Fit all places in view
viewModel.fitAllPlaces()

// Change map style
viewModel.changeMapStyle(.satellite)
```

## Location Services

### Request Permission

Request user location permission:

```swift
Task {
    await viewModel.requestLocationPermission()
}

// Check if permission was granted
if viewModel.userLocation != nil {
    print("Location: \(viewModel.userLocation!)")
}
```

### Distance to Places

Calculate distance from user to places:

```swift
for place in viewModel.filteredPlaces {
    if let distance = viewModel.distanceToPlace(place) {
        print("\(place.name): \(distance)m away")
    }

    // Or get formatted distance
    if let formatted = viewModel.formattedDistance(place) {
        print("\(place.name): \(formatted)")
    }
}
```

## External Navigation

### Open in Maps Apps

Launch navigation in external apps:

```swift
// In the place callout view, or custom UI:
Button("Navigate") {
    Task {
        await viewModel.openInExternalMaps(place, app: .appleMaps)
    }
}

// Available apps:
// - .appleMaps (always available)
// - .googleMaps (if installed)
// - .waze (if installed)
```

### Check App Availability

```swift
// Check if an external app is installed
// (This is handled automatically by ExternalMapLauncher)
do {
    try await ExternalMapLauncher.open(
        coordinate: place.coordinate,
        name: place.name,
        app: .googleMaps
    )
} catch MapError.externalAppNotInstalled(let appName) {
    print("\(appName) is not installed")
}
```

## Custom Markers

### Using Built-in Markers

ARCMaps provides two built-in marker styles:

- ``WishlistMarker``: Red heart icon for wishlist places
- ``VisitedMarker``: Green checkmark for visited places

These are automatically used based on the `MapPlace.status` property.

### Custom Marker Colors

The markers use system colors that adapt to light/dark mode automatically.

## Error Handling

Handle map-related errors:

```swift
// Observe errors in the ViewModel
if let error = viewModel.error {
    switch error {
    case .locationPermissionDenied:
        // Show settings alert
        break
    case .locationUnavailable:
        // Show error message
        break
    case .externalAppNotInstalled(let app):
        // Suggest alternative
        break
    default:
        // Handle other errors
        break
    }

    // Clear the error
    viewModel.error = nil
}
```

## Performance Tips

### Large Number of Places

For best performance with many places:

1. Use filtering to reduce visible markers
2. Implement clustering (future feature)
3. Only load places in visible region

### Memory Management

The map view automatically handles memory management, but you can help by:

- Clearing unused places: `viewModel.setPlaces([])`
- Limiting photo sizes when loading images

## See Also

- ``ARCMapView``
- ``MapViewModel``
- ``MapPlace``
- ``MapFilter``
- ``LocationService``
- ``ExternalMapLauncher``
- ``MapError``
