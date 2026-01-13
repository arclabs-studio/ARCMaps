# Place Enrichment Guide

Learn how to search for places and enrich them with detailed information.

## Overview

The Place Enrichment module allows you to search for places and retrieve detailed information including photos, reviews, ratings, and business hours from Google Places API or Apple MapKit.

## Searching for Places

### Basic Search

Search for places by name and location:

```swift
import ARCMaps

// Create services
let networkClient = DefaultNetworkClient()
let logger = DefaultLogger()
let cache = InMemoryPlaceCache()

let googleService = GooglePlacesService(
    apiKey: "YOUR_API_KEY",
    networkClient: networkClient,
    logger: logger,
    cache: cache
)

// Create a search query
let query = PlaceSearchQuery(
    name: "La Taverna",
    address: "Madrid",
    city: "Madrid",
    countryCode: "ES"
)

// Search for places
let results = try await googleService.searchPlaces(query: query)

for result in results {
    print("\(result.name) - Rating: \(result.rating ?? 0)")
}
```

### Proximity Search

Search for places near a specific location:

```swift
let query = PlaceSearchQuery(
    name: "Restaurant",
    coordinate: (latitude: 40.4168, longitude: -3.7038),
    radiusMeters: 1000 // 1km radius
)

let results = try await googleService.searchPlaces(query: query)
```

## Getting Detailed Information

### Place Details

Retrieve comprehensive information about a specific place:

```swift
// Get the first search result
if let firstResult = results.first {
    let details = try await googleService.getPlaceDetails(placeId: firstResult.id)

    print("Name: \(details.name)")
    print("Address: \(details.formattedAddress ?? "N/A")")
    print("Rating: \(details.rating ?? 0)/5")
    print("Phone: \(details.phoneNumber ?? "N/A")")
    print("Website: \(details.website?.absoluteString ?? "N/A")")

    // Opening hours
    if let hours = details.openingHours {
        print("Open now: \(hours.isOpen ?? false)")
        for day in hours.weekdayText {
            print(day)
        }
    }

    // Photos
    print("Photos: \(details.photos.count)")

    // Reviews
    for review in details.reviews {
        print("\(review.authorName): \(review.rating)/5 - \(review.text)")
    }
}
```

### Photo URLs

Get URLs for place photos:

```swift
for photo in details.photos {
    let photoURL = try await googleService.getPhotoURL(
        photoReference: photo.photoReference,
        maxWidth: 800
    )

    // Use the URL to load the image
    // e.g., with AsyncImage in SwiftUI
}
```

## Using the ViewModel

### Place Enrichment ViewModel

The `PlaceEnrichmentViewModel` provides a higher-level interface with state management:

```swift
import SwiftUI
import ARCMaps

@MainActor
class MyViewModel: ObservableObject {
    let enrichmentVM: PlaceEnrichmentViewModel

    init() {
        let logger = DefaultLogger()
        let networkClient = DefaultNetworkClient()
        let cache = InMemoryPlaceCache()

        let googleService = GooglePlacesService(
            apiKey: "YOUR_KEY",
            networkClient: networkClient,
            logger: logger,
            cache: cache
        )

        let appleService = AppleMapsSearchService(
            logger: logger,
            cache: cache
        )

        enrichmentVM = PlaceEnrichmentViewModel(
            googleService: googleService,
            appleService: appleService,
            logger: logger
        )
    }
}

struct SearchView: View {
    @StateObject private var viewModel = MyViewModel()

    var body: some View {
        VStack {
            if viewModel.enrichmentVM.isSearching {
                ProgressView("Searching...")
            } else {
                List(viewModel.enrichmentVM.searchResults) { result in
                    Button {
                        Task {
                            await viewModel.enrichmentVM.selectResult(result)
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(result.name)
                            Text(result.address ?? "")
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .task {
            let query = PlaceSearchQuery(name: "Restaurant", city: "Madrid")
            await viewModel.enrichmentVM.searchPlaces(query: query)
        }
    }
}
```

## Provider Fallback

ARCMaps automatically falls back to the alternative provider if the primary one fails:

```swift
// Set Google as primary
viewModel.selectedProvider = .google

// Search will try Google first
await viewModel.searchPlaces(query: query)

// If Google fails, it automatically tries Apple Maps
// The viewModel.selectedProvider will be updated to .apple
```

## Caching

Search results are automatically cached to improve performance and reduce API calls:

```swift
// First search - hits the API
let results1 = try await service.searchPlaces(query: query)

// Second search with same query - returns cached results
let results2 = try await service.searchPlaces(query: query)

// Clear cache if needed
await cache.clearCache()
```

## Error Handling

Handle errors gracefully:

```swift
do {
    let results = try await service.searchPlaces(query: query)
    // Process results
} catch PlaceEnrichmentError.noResultsFound {
    print("No places found")
} catch PlaceEnrichmentError.invalidAPIKey {
    print("Invalid API key - check your configuration")
} catch PlaceEnrichmentError.rateLimitExceeded {
    print("Rate limit exceeded - try again later")
} catch {
    print("Error: \(error.localizedDescription)")
}
```

## See Also

- ``PlaceEnrichmentService``
- ``PlaceSearchQuery``
- ``PlaceSearchResult``
- ``EnrichedPlaceData``
- ``PlaceEnrichmentViewModel``
- ``PlaceEnrichmentError``
