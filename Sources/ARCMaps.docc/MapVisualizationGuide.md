# Map Visualization Guide

Display places on an interactive map with custom markers, favorites, and filters.

## Overview

The Map Visualization module provides SwiftUI components to display places on a map with distinctive markers for pending vs. visited vs. favorite places, along with filtering and navigation capabilities.

## Basic Map Display

### Simple Map View

```swift
import SwiftUI
import MapKit
import ARCMaps

struct RestaurantMapView: View {
    @State private var viewModel = MapViewModel(
        locationService: CoreLocationService()
    )

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
                status: .pending           // red clock marker — wants to visit
            ),
            MapPlace(
                id: "2",
                name: "El Café",
                coordinate: CLLocationCoordinate2D(latitude: 40.4200, longitude: -3.7050),
                address: "Gran Vía 20, Madrid",
                category: "Cafe",
                rating: 4.2,
                status: .visited,
                visitDate: Date()           // green checkmark marker — visited
            ),
            MapPlace(
                id: "3",
                name: "Sobrino de Botin",
                coordinate: CLLocationCoordinate2D(latitude: 40.4133, longitude: -3.7080),
                address: "Calle Cuchilleros 17, Madrid",
                category: "Restaurant",
                rating: 4.9,
                status: .visited,
                isFavorite: true,          // gold star marker — visited and favorited
                visitDate: Date()
            )
        ]
    }
}
```

## Place Status and Favorites

### PlaceStatus

`PlaceStatus` has two cases:

- `.pending` — the user wants to visit this place in the future
- `.visited` — the user has already been there

### isFavorite

`MapPlace.isFavorite` is a `Bool` flag that is only meaningful when `status == .visited`. It lets you distinguish between places you visited and places you truly loved.

```swift
let favoriteCafe = MapPlace(
    id: "cafe-1",
    name: "Toma Cafe",
    coordinate: CLLocationCoordinate2D(latitude: 40.4280, longitude: -3.7050),
    status: .visited,
    isFavorite: true,
    visitDate: Date()
)
```

## Custom Markers

ARCMaps provides three built-in marker styles that are resolved automatically from `MapPlace.status` and `MapPlace.isFavorite`:

| Marker | Condition | Icon | Color |
|--------|-----------|------|-------|
| ``PendingMarker`` | `status == .pending` | clock | Red |
| ``VisitedMarker`` | `status == .visited && !isFavorite` | checkmark | Green |
| ``FavoriteMarker`` | `status == .visited && isFavorite` | star | Gold |

The `ARCMapView` resolves the correct marker automatically — no manual configuration required.

## Filtering Places

### Status Filter

```swift
// Show only pending places
var filter = MapFilter(statuses: [.pending])
viewModel.updateFilter(filter)

// Show only visited places
var filter = MapFilter(statuses: [.visited])
viewModel.updateFilter(filter)

// Show all
viewModel.updateFilter(.all)
```

### Favorites Filter

Use `filterByFavorites` to show only places marked as a favorite:

```swift
// Show only favorites (must also include .visited in statuses)
let favoritesFilter = MapFilter(
    statuses: [.visited],
    filterByFavorites: true
)
viewModel.updateFilter(favoritesFilter)
```

### Category Filter

```swift
var filter = MapFilter()
filter.categories = ["Restaurant", "Cafe"]
viewModel.updateFilter(filter)
```

### Rating Filter

```swift
var filter = MapFilter()
filter.minRating = 4.0
viewModel.updateFilter(filter)
```

### Date Range Filter

```swift
let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
let filter = MapFilter(dateRange: DateRange(start: lastMonth, end: Date()))
viewModel.updateFilter(filter)
```

### Combining Filters

All filter conditions are combined with AND logic:

```swift
// Highly-rated favorite restaurants visited in the last 30 days
let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
let filter = MapFilter(
    statuses: [.visited],
    categories: ["Restaurant"],
    minRating: 4.0,
    dateRange: DateRange(start: thirtyDaysAgo, end: Date()),
    filterByFavorites: true
)
viewModel.updateFilter(filter)
```

## Adding Places from Search Results

Use ``PlaceMapper`` to bridge a ``PlaceSearchResult`` from the enrichment module directly to the map:

```swift
// User picks a search result → convert and pin it on the map
let mapPlace = PlaceMapper.toMapPlace(searchResult, status: .pending)
mapViewModel.addPlace(mapPlace)
```

## Map Interaction

### Selecting Places

```swift
// Callout is shown automatically on marker tap
if let selected = viewModel.selectedPlace {
    print("Selected: \(selected.name)")
}

// Programmatic selection
viewModel.selectPlace(myPlace)
```

### Camera Control

```swift
viewModel.centerOnPlace(place, animated: true)
viewModel.fitAllPlaces()
viewModel.changeMapStyle(.satellite)
```

## Location Services

```swift
Task {
    await viewModel.requestLocationPermission()
}

if viewModel.userLocation != nil {
    print("Location available")
}
```

### Distance to Places

```swift
for place in viewModel.filteredPlaces {
    if let formatted = viewModel.formattedDistance(place) {
        print("\(place.name): \(formatted)")
    }
}
```

## External Navigation

```swift
Button("Navigate") {
    Task {
        await viewModel.openInExternalMaps(place, app: .appleMaps)
    }
}
// Available: .appleMaps, .googleMaps, .waze
```

## Error Handling

```swift
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
        break
    }
    viewModel.error = nil
}
```

## Performance Tips

For best performance with many places:

1. Use filtering to reduce visible markers
2. Clear places when no longer needed: `viewModel.setPlaces([])`
3. Limit photo sizes when loading images

## See Also

- ``ARCMapView``
- ``MapViewModel``
- ``MapPlace``
- ``PlaceStatus``
- ``MapFilter``
- ``PlaceMapper``
- ``PendingMarker``
- ``VisitedMarker``
- ``FavoriteMarker``
- ``LocationService``
- ``ExternalMapLauncher``
- ``MapError``
