# Map Visualization Guide

Display places on an interactive map with customizable markers, filters, and navigation.

## Overview

The Map Visualization module provides SwiftUI components to display places on a map. Markers and the detail sheet are fully customizable via `@ViewBuilder` — the package ships with sensible defaults and you can override either or both.

## Basic Map Display

### Simple Map View

```swift
import SwiftUI
import MapKit
import ARCMaps

struct PlaceMapView: View {
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
                name: "Café Luna",
                coordinate: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
                address: "Calle Mayor 15, Madrid",
                category: "cafe",
                rating: 4.5
            ),
            MapPlace(
                id: "2",
                name: "Museo del Prado",
                coordinate: CLLocationCoordinate2D(latitude: 40.4138, longitude: -3.6922),
                address: "Paseo del Prado, Madrid",
                category: "museum",
                rating: 4.9
            )
        ]
    }
}
```

## Custom Markers

By default, `ARCMapView` uses ``PlaceMarker`` — a simple red circle pin. Inject a `@ViewBuilder` to render your own marker per place:

```swift
ARCMapView(viewModel: viewModel) { place in
    MyMarker(place: place)
}
```

Your `MyMarker` view receives the `MapPlace` and can render any SwiftUI view — different colors per category, icons, badges, etc.

## Custom Detail Sheet

By default, tapping a marker presents ``PlaceCalloutView`` with name, category, rating, address, distance, and "Open in" options. Inject a `@ViewBuilder` to replace it entirely:

```swift
ARCMapView(viewModel: viewModel) { place in
    MyMarker(place: place)
} sheet: { place, userLocation in
    MyPlaceDetailView(place: place, userLocation: userLocation)
}
```

The `sheet` closure receives the selected `MapPlace` and the user's current `CLLocationCoordinate2D?` (if location permission is granted).

## Clustering

At city zoom every pin is legible. At country or world zoom they pile into an unreadable stack, and it gets worse linearly with collection size. `ARCMapView` therefore groups nearby places into clusters, and dissolves them back into individual pins as you zoom in.

Clustering is on by default — there is nothing to enable:

```swift
ARCMapView(viewModel: viewModel)
```

Tapping a cluster zooms the camera to fit its members rather than opening a sheet.

### Custom Cluster Bubbles

By default clusters render as ``ClusterMarker`` — a red circle showing the member count, growing with cluster size. Inject a `@ViewBuilder` to replace it:

```swift
ARCMapView(viewModel: viewModel) { place in
    MyMarker(place: place)
} cluster: { cluster in
    MyClusterBubble(count: cluster.count,
                    topRating: cluster.places.compactMap(\.rating).max())
}
```

The closure receives a ``MapCluster`` carrying its `count` and the full `places` array, so the bubble can reflect whatever its members have in common.

### Opting Out

Collections small enough to stay legible unclustered can turn it off:

```swift
viewModel.clusteringEnabled = false
```

### Annotation Titles

Place names are hidden by default: SwiftUI's `Annotation` always draws a label, and those labels are a large part of what makes dense areas unreadable. Turn them back on when your dataset is sparse:

```swift
viewModel.showsAnnotationTitles = true
```

### Tuning Cluster Density

Three places per grid cell is the default threshold — clustering a pair usually hides more than it helps. Pass a differently configured ``PlaceClusterer`` to change it:

```swift
let viewModel = MapViewModel(locationService: CoreLocationService(),
                             clusterer: PlaceClusterer(minimumClusterSize: 5))
```

> Note: Clusters spanning the antimeridian (±180° longitude) are not supported. Grid cell indices do not wrap and the cluster centroid is a plain arithmetic mean.

## Filtering Places

### Category Filter

```swift
var filter = MapFilter(categories: ["cafe", "restaurant"])
viewModel.updateFilter(filter)
```

### Rating Filter

```swift
var filter = MapFilter(minRating: 4.0)
viewModel.updateFilter(filter)
```

### Combining Filters

All conditions are combined with AND logic:

```swift
let filter = MapFilter(
    categories: ["cafe"],
    minRating: 4.0
)
viewModel.updateFilter(filter)
```

### Resetting Filters

```swift
viewModel.updateFilter(.all)
```

## Adding Places from Search Results

Use ``PlaceMapper`` to bridge a ``PlaceSearchResult`` from the enrichment module directly to the map:

```swift
// User picks a search result → convert and pin it on the map
let mapPlace = PlaceMapper.toMapPlace(searchResult)
mapViewModel.setPlaces([mapPlace])
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

## iOS 18+ Native POI Selection

Enable native Apple Maps point-of-interest selection:

```swift
ARCMapView(
    viewModel: viewModel,
    featureSelectionMode: .pointsOfInterestOnly
)
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
        break
    case .locationUnavailable:
        break
    case .externalAppNotInstalled(let app):
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

## See Also

- ``ARCMapView``
- ``MapViewModel``
- ``MapPlace``
- ``MapFilter``
- ``PlaceMarker``
- ``PlaceCalloutView``
- ``PlaceMapper``
- ``LocationService``
- ``ExternalMapLauncher``
- ``MapError``
