# ARCMaps Examples

This directory contains example code demonstrating how to use ARCMaps in your iOS apps.

## Examples

### 1. Basic Map View

Shows how to display places on a map with custom markers.

```swift
import SwiftUI
import ARCMaps
import CoreLocation

struct BasicMapExample: View {
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
                viewModel.setPlaces(samplePlaces)
                viewModel.fitAllPlaces()
            }
    }

    private var samplePlaces: [MapPlace] {
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
                name: "El Café Central",
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

### 2. Place Search

Demonstrates searching for places using Google Places API.

```swift
import SwiftUI
import ARCMaps

struct PlaceSearchExample: View {
    @StateObject private var viewModel: SearchViewModel
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search for a place", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()

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
                                    .font(.headline)

                                if let address = result.address {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                if let rating = result.rating {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                        Text(String(format: "%.1f", rating))
                                    }
                                    .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search Places")
            .searchable(text: $searchText)
            .onSubmit(of: .search) {
                Task {
                    let query = PlaceSearchQuery(
                        name: searchText,
                        city: "Madrid"
                    )
                    await viewModel.enrichmentVM.searchPlaces(query: query)
                }
            }
        }
    }
}

@MainActor
class SearchViewModel: ObservableObject {
    let enrichmentVM: PlaceEnrichmentViewModel

    init() {
        let logger = DefaultLogger()
        let networkClient = DefaultNetworkClient()
        let cache = InMemoryPlaceCache()

        let googleService = GooglePlacesService(
            apiKey: ARCMapsConfiguration.shared.googlePlacesAPIKey ?? "",
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
```

### 3. Map with Filtering

Shows how to filter places by status, category, or rating.

```swift
import SwiftUI
import ARCMaps

struct FilteredMapExample: View {
    @StateObject private var viewModel: MapViewModel
    @State private var selectedStatus: Set<PlaceStatus> = Set(PlaceStatus.allCases)
    @State private var minRating: Double = 0

    var body: some View {
        VStack {
            // Filter controls
            VStack(spacing: 12) {
                Picker("Status", selection: $selectedStatus) {
                    Text("All").tag(Set(PlaceStatus.allCases))
                    Text("Wishlist").tag(Set([PlaceStatus.wishlist]))
                    Text("Visited").tag(Set([PlaceStatus.visited]))
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading) {
                    Text("Minimum Rating: \(minRating, specifier: "%.1f")")
                        .font(.caption)

                    Slider(value: $minRating, in: 0...5, step: 0.5)
                }
            }
            .padding()
            .background(.regularMaterial)
            .onChange(of: selectedStatus) { _, newValue in
                updateFilter()
            }
            .onChange(of: minRating) { _, _ in
                updateFilter()
            }

            // Map
            ARCMapView(viewModel: viewModel)
        }
    }

    private func updateFilter() {
        var filter = MapFilter()
        filter.statuses = selectedStatus
        filter.minRating = minRating > 0 ? minRating : nil
        viewModel.updateFilter(filter)
    }
}
```

### 4. Complete App Example

A complete example showing both search and map views.

```swift
import SwiftUI
import ARCMaps

@main
struct ARCMapsExampleApp: App {
    init() {
        // Configure ARCMaps with your API key
        ARCMapsConfiguration.shared = ARCMapsConfiguration(
            googlePlacesAPIKey: "YOUR_GOOGLE_PLACES_API_KEY",
            defaultProvider: .google,
            maxCacheSize: 100,
            cacheExpirationSeconds: 3600
        )
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct MainView: View {
    @State private var selectedTab = 0
    @StateObject private var placeStore = PlaceStore()

    var body: some View {
        TabView(selection: $selectedTab) {
            PlaceSearchView(placeStore: placeStore)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(0)

            PlaceMapView(placeStore: placeStore)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(1)
        }
    }
}

@MainActor
class PlaceStore: ObservableObject {
    @Published var places: [MapPlace] = []

    func addPlace(_ place: MapPlace) {
        places.append(place)
    }

    func updatePlace(_ place: MapPlace) {
        if let index = places.firstIndex(where: { $0.id == place.id }) {
            places[index] = place
        }
    }
}
```

## Running the Examples

1. Copy the example code into your Xcode project
2. Configure your Google Places API key in `ARCMapsConfiguration`
3. Add the required privacy permissions to Info.plist
4. Build and run

## See Also

- [Getting Started Guide](../Sources/ARCMaps.docc/GettingStarted.md)
- [Place Enrichment Guide](../Sources/ARCMaps.docc/PlaceEnrichmentGuide.md)
- [Map Visualization Guide](../Sources/ARCMaps.docc/MapVisualizationGuide.md)
