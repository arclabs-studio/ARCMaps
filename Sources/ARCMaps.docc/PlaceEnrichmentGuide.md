# Place Enrichment Guide

Learn how to search for places and enrich them with detailed information.

## Overview

The Place Enrichment module allows you to search for places and retrieve detailed information including photos, reviews, ratings, and business hours. ARCMaps supports three providers with an automatic fallback chain:

1. **Google Places API** — full detail: photos, ratings, opening hours, phone, reviews
2. **Apple Maps Server API** — structured address, category, place ID, coordinates (no photos/ratings)
3. **Apple MapKit (on-device)** — basic name, coordinate, address; no API key required

## Searching for Places

### Basic Search

```swift
import ARCMaps

let networkClient = DefaultNetworkClient()
let cache = InMemoryPlaceCache()

let googleService = GooglePlacesService(
    apiKey: "YOUR_API_KEY",
    networkClient: networkClient,
    cache: cache
)

let query = PlaceSearchQuery(
    name: "La Taverna",
    address: "Madrid",
    city: "Madrid",
    countryCode: "ES"
)

let results = try await googleService.searchPlaces(query: query)

for result in results {
    print("\(result.name) - Rating: \(result.rating ?? 0)")
}
```

### Proximity Search

```swift
let query = PlaceSearchQuery(
    name: "Restaurant",
    coordinate: (latitude: 40.4168, longitude: -3.7038),
    radiusMeters: 1000
)

let results = try await googleService.searchPlaces(query: query)
```

## Getting Detailed Information

### Place Details

```swift
if let firstResult = results.first {
    let details = try await googleService.getPlaceDetails(placeId: firstResult.id)

    print("Name: \(details.name)")
    print("Address: \(details.formattedAddress ?? "N/A")")
    print("Rating: \(details.rating ?? 0)/5")
    print("Phone: \(details.phoneNumber ?? "N/A")")
    print("Website: \(details.website?.absoluteString ?? "N/A")")

    if let hours = details.openingHours {
        print("Open now: \(hours.isOpen ?? false)")
        for day in hours.weekdayText { print(day) }
    }

    print("Photos: \(details.photos.count)")

    for review in details.reviews {
        print("\(review.authorName): \(review.rating)/5 - \(review.text)")
    }
}
```

### Photo URLs

```swift
for photo in details.photos {
    let photoURL = try await googleService.getPhotoURL(
        photoReference: photo.photoReference,
        maxWidth: 800
    )
    // Use with AsyncImage in SwiftUI
}
```

## Apple Maps Server API

`AppleMapsServerService` uses the Apple Maps Server REST API authenticated with a short-lived JWT (ES256). It returns structured address data and place categories without requiring any on-device MapKit usage.

### When to Use It

- You want a server-side provider that doesn't depend on Google
- You need structured place data (address components, place category)
- Your app already targets developers who have an Apple Developer account

### Limitations vs Google Places

| Feature | Google Places | Apple Maps Server | Apple MapKit |
|---------|:---:|:---:|:---:|
| Photos | ✓ | ✗ | ✗ |
| Ratings | ✓ | ✗ | ✗ |
| Opening hours | ✓ | ✗ | ✗ |
| Phone number | ✓ | ✗ | ✗ |
| Structured address | ✓ | ✓ | partial |
| Place category | ✓ | ✓ | ✓ |
| No API key needed | ✗ | ✗ | ✓ |

### Configuration

```swift
ARCMapsConfiguration.shared = ARCMapsConfiguration(
    googlePlacesAPIKey: "YOUR_GOOGLE_KEY",
    appleMapsKeyID: "XXXXXXXXXX",
    appleMapsTeamID: "XXXXXXXXXX",
    appleMapsPrivateKey: """
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByq...
        -----END PRIVATE KEY-----
        """
)
```

## Using the ViewModel

`PlaceEnrichmentViewModel` manages state and orchestrates the three-tier provider chain automatically.

```swift
import SwiftUI
import ARCMaps

@Observable
@MainActor
final class SearchDemoViewModel {
    let enrichmentVM: PlaceEnrichmentViewModel

    init() {
        let networkClient = DefaultNetworkClient()
        let cache = InMemoryPlaceCache()

        let googleService = GooglePlacesService(
            apiKey: "YOUR_KEY",
            networkClient: networkClient,
            cache: cache
        )

        // Apple Maps Server — pass nil if credentials are not configured
        let appleServerService = AppleMapsServerService(
            tokenProvider: AppleMapsTokenProvider(
                keyID: "XXXXXXXXXX",
                teamID: "XXXXXXXXXX",
                privateKey: "-----BEGIN PRIVATE KEY-----\n..."
            ),
            networkClient: networkClient,
            cache: cache
        )

        let appleService = AppleMapsSearchService(cache: cache)

        enrichmentVM = PlaceEnrichmentViewModel(
            googleService: googleService,
            appleServerService: appleServerService,
            appleService: appleService
        )
    }
}

struct SearchView: View {
    @State private var viewModel = SearchDemoViewModel()

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

## Provider Fallback Chain

ARCMaps automatically falls back through the provider chain when the primary provider fails:

```
Google Places  →  Apple Maps Server  →  Apple MapKit (on-device)
   (primary)          (fallback 1)           (fallback 2)
```

- If Google is unavailable (network error, quota exceeded), the search retries with Apple Maps Server.
- If Apple Maps Server is also unavailable (or not configured), it falls back to on-device MapKit.
- `PlaceEnrichmentViewModel.selectedProvider` updates automatically to reflect the active provider.

```swift
// Observe which provider is currently active
Text("Provider: \(viewModel.enrichmentVM.selectedProvider.displayName)")

// Manually switch provider
viewModel.enrichmentVM.changeProvider(.appleServer)
```

## Bridging Search Results to the Map

Use ``PlaceMapper`` to convert a ``PlaceSearchResult`` into a ``MapPlace`` for display on the map. This bridges the PlaceEnrichment and MapVisualization modules without coupling them.

```swift
// Convert a search result to a pending map place
let mapPlace = PlaceMapper.toMapPlace(searchResult, status: .pending)
mapViewModel.addPlace(mapPlace)

// The resulting MapPlace uses:
// - result.id, result.name, result.coordinate, result.address
// - result.types.first as the category
// - result.rating (if available)
// - isFavorite: false (default for new places)
```

## Caching

Search results are automatically cached to reduce API calls:

```swift
// First search — hits the API
let results1 = try await service.searchPlaces(query: query)

// Same query again — returns cached results instantly
let results2 = try await service.searchPlaces(query: query)

// Clear cache explicitly if needed
await cache.clearCache()
```

## Error Handling

```swift
do {
    let results = try await service.searchPlaces(query: query)
} catch PlaceEnrichmentError.noResultsFound {
    print("No places found")
} catch PlaceEnrichmentError.invalidAPIKey {
    print("Invalid API key — check your configuration")
} catch PlaceEnrichmentError.rateLimitExceeded {
    print("Rate limit exceeded — try again later")
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
- ``PlaceProvider``
- ``PlaceMapper``
- ``AppleMapsServerService``
