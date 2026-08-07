//
//  ARCMapView.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import MapKit
import SwiftUI

// MARK: - Constants

private enum ViewDefaults {
    /// Initial height for the place detail sheet.
    static let sheetInitialHeight: CGFloat = 300
    /// Corner radius for the loading indicator background.
    static let loadingIndicatorCornerRadius: CGFloat = 12
}

// MARK: - Feature Selection Configuration

/// Configuration for native map feature selection behavior.
///
/// Controls how users can interact with native Apple Maps points of interest
/// that appear on the map alongside your custom markers.
///
/// ## Overview
///
/// When using iOS 18+, users can tap on native Apple Maps POIs (restaurants, shops,
/// landmarks, etc.) to see detailed information in a callout. This enum configures
/// which features are selectable.
///
/// ## Platform Availability
///
/// - **iOS 18+**: Full feature selection support with callouts
/// - **iOS 17**: Falls back to legacy view (this setting has no effect)
/// - **macOS**: Always uses legacy view (feature selection APIs are iOS-only)
///
/// ## Example
///
/// ```swift
/// // Allow users to tap on POIs
/// ARCMapView(
///     viewModel: mapViewModel,
///     featureSelectionMode: .pointsOfInterestOnly
/// )
///
/// // Disable all native POI interaction for a cleaner experience
/// ARCMapView(
///     viewModel: mapViewModel,
///     featureSelectionMode: .disabled
/// )
/// ```
public enum MapFeatureSelectionMode: Sendable {
    /// Disable selection of all native map features.
    ///
    /// Users can only interact with your custom markers.
    /// This provides a cleaner, more focused experience.
    case disabled

    /// Allow selection of native points of interest only.
    ///
    /// Users can tap on shops, landmarks, parks, and other POIs
    /// to see Apple's native detail callout.
    case pointsOfInterestOnly

    /// Allow selection of all native map features.
    ///
    /// Users can tap on any label or feature on the map.
    case all
}

// MARK: - ARCMapView

/// A SwiftUI view displaying an interactive map with place markers and controls.
///
/// `ARCMapView` provides a full-featured map interface with:
/// - Customizable place markers via `@ViewBuilder`
/// - Customizable place detail sheet via `@ViewBuilder`
/// - Map controls (fit all, style selector)
/// - User location display
/// - Optional native POI selection (iOS 18+)
///
/// ## Basic Usage
///
/// ```swift
/// struct ContentView: View {
///     @State private var viewModel = MapViewModel(locationService: CoreLocationService())
///
///     var body: some View {
///         ARCMapView(viewModel: viewModel)
///             .onAppear {
///                 viewModel.setPlaces(myPlaces)
///             }
///     }
/// }
/// ```
///
/// ## Custom Markers and Sheet
///
/// ```swift
/// ARCMapView(viewModel: viewModel) { place in
///     MyMarker(place: place)
/// } sheet: { place, userLocation in
///     MyPlaceDetailView(place: place, userLocation: userLocation)
/// }
/// ```
///
/// ## iOS 18+ Feature Selection
///
/// ```swift
/// ARCMapView(
///     viewModel: viewModel,
///     featureSelectionMode: .pointsOfInterestOnly
/// )
/// ```
public struct ARCMapView<MarkerContent: View, SheetContent: View, ClusterContent: View>: View {
    /// The view model managing map state and place data.
    @Bindable var viewModel: MapViewModel

    /// Controls native map feature selection behavior (iOS 18+ only).
    private let featureSelectionMode: MapFeatureSelectionMode

    private let markerContent: (MapPlace) -> MarkerContent
    private let sheetContent: (MapPlace, CLLocationCoordinate2D?) -> SheetContent
    private let clusterContent: (MapCluster) -> ClusterContent

    // MARK: - Initializers

    /// Creates a map view with default ``PlaceMarker``, ``PlaceCalloutView``, and ``ClusterMarker``.
    ///
    /// - Parameters:
    ///   - viewModel: The view model managing map state, places, and user location.
    ///   - featureSelectionMode: Controls native POI selection behavior on iOS 18+.
    public init(viewModel: MapViewModel,
                featureSelectionMode: MapFeatureSelectionMode = .disabled)
        where MarkerContent == PlaceMarker,
        SheetContent == PlaceCalloutView,
        ClusterContent == ClusterMarker {
        self.viewModel = viewModel
        self.featureSelectionMode = featureSelectionMode
        markerContent = { PlaceMarker(place: $0) }
        clusterContent = { ClusterMarker(count: $0.count) }
        let vm = viewModel
        sheetContent = { place, userLocation in
            PlaceCalloutView(place: place,
                             userLocation: userLocation,
                             onOpenInMaps: { app in
                                 await vm.openInExternalMaps(place, app: app)
                             })
        }
    }

    /// Creates a map view with a custom marker builder and default ``PlaceCalloutView``.
    ///
    /// - Parameters:
    ///   - viewModel: The view model managing map state, places, and user location.
    ///   - featureSelectionMode: Controls native POI selection behavior on iOS 18+.
    ///   - marker: A `@ViewBuilder` closure that builds the marker view for each place.
    public init(viewModel: MapViewModel,
                featureSelectionMode: MapFeatureSelectionMode = .disabled,
                @ViewBuilder marker: @escaping (MapPlace) -> MarkerContent)
        where SheetContent == PlaceCalloutView, ClusterContent == ClusterMarker {
        self.viewModel = viewModel
        self.featureSelectionMode = featureSelectionMode
        markerContent = marker
        clusterContent = { ClusterMarker(count: $0.count) }
        let vm = viewModel
        sheetContent = { place, userLocation in
            PlaceCalloutView(place: place,
                             userLocation: userLocation,
                             onOpenInMaps: { app in
                                 await vm.openInExternalMaps(place, app: app)
                             })
        }
    }

    /// Creates a map view with custom marker and cluster builders and default ``PlaceCalloutView``.
    ///
    /// - Parameters:
    ///   - viewModel: The view model managing map state, places, and user location.
    ///   - featureSelectionMode: Controls native POI selection behavior on iOS 18+.
    ///   - marker: A `@ViewBuilder` closure that builds the marker view for each place.
    ///   - cluster: A `@ViewBuilder` closure that builds the bubble for a group of nearby places.
    ///     Tapping it zooms to fit the cluster's members.
    public init(viewModel: MapViewModel,
                featureSelectionMode: MapFeatureSelectionMode = .disabled,
                @ViewBuilder marker: @escaping (MapPlace) -> MarkerContent,
                @ViewBuilder cluster: @escaping (MapCluster) -> ClusterContent)
        where SheetContent == PlaceCalloutView {
        self.viewModel = viewModel
        self.featureSelectionMode = featureSelectionMode
        markerContent = marker
        clusterContent = cluster
        let vm = viewModel
        sheetContent = { place, userLocation in
            PlaceCalloutView(place: place,
                             userLocation: userLocation,
                             onOpenInMaps: { app in
                                 await vm.openInExternalMaps(place, app: app)
                             })
        }
    }

    /// Creates a map view with custom marker and sheet builders.
    ///
    /// - Parameters:
    ///   - viewModel: The view model managing map state, places, and user location.
    ///   - featureSelectionMode: Controls native POI selection behavior on iOS 18+.
    ///   - marker: A `@ViewBuilder` closure that builds the marker view for each place.
    ///   - sheet: A `@ViewBuilder` closure that builds the detail sheet for a selected place.
    ///     Receives the place and the user's current location (if available).
    public init(viewModel: MapViewModel,
                featureSelectionMode: MapFeatureSelectionMode = .disabled,
                @ViewBuilder marker: @escaping (MapPlace) -> MarkerContent,
                @ViewBuilder sheet: @escaping (MapPlace, CLLocationCoordinate2D?) -> SheetContent)
        where ClusterContent == ClusterMarker {
        self.viewModel = viewModel
        self.featureSelectionMode = featureSelectionMode
        markerContent = marker
        sheetContent = sheet
        clusterContent = { ClusterMarker(count: $0.count) }
    }

    /// Creates a map view with custom marker, sheet, and cluster builders.
    ///
    /// - Parameters:
    ///   - viewModel: The view model managing map state, places, and user location.
    ///   - featureSelectionMode: Controls native POI selection behavior on iOS 18+.
    ///   - marker: A `@ViewBuilder` closure that builds the marker view for each place.
    ///   - sheet: A `@ViewBuilder` closure that builds the detail sheet for a selected place.
    ///     Receives the place and the user's current location (if available).
    ///   - cluster: A `@ViewBuilder` closure that builds the bubble for a group of nearby places.
    ///     Tapping it zooms to fit the cluster's members.
    public init(viewModel: MapViewModel,
                featureSelectionMode: MapFeatureSelectionMode = .disabled,
                @ViewBuilder marker: @escaping (MapPlace) -> MarkerContent,
                @ViewBuilder sheet: @escaping (MapPlace, CLLocationCoordinate2D?) -> SheetContent,
                @ViewBuilder cluster: @escaping (MapCluster) -> ClusterContent) {
        self.viewModel = viewModel
        self.featureSelectionMode = featureSelectionMode
        markerContent = marker
        sheetContent = sheet
        clusterContent = cluster
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            mapView

            VStack {
                HStack {
                    Spacer()
                    MapControlsView(onFitAll: {
                                        viewModel.fitAllPlaces()
                                    },
                                    onChangeStyle: { style in
                                        viewModel.changeMapStyle(style)
                                    },
                                    currentStyle: viewModel.mapStyle)
                }
                .padding()

                Spacer()
            }

            if viewModel.isLoadingLocation {
                ProgressView("Getting location...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(ViewDefaults.loadingIndicatorCornerRadius)
            }
        }
        .task {
            await viewModel.requestLocationPermission()
        }
        .alert("Map Error",
               isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }

    // MARK: - Private

    /// Map view with shared controls and place detail sheet applied once for both iOS variants.
    private var mapView: some View {
        coreMap
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            // Applied once here rather than at each of the four `Map` sites below.
            // `.onEnd` keeps reclustering off the pan path; the view model additionally
            // ignores changes that stay within the same zoom bucket.
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.updateCameraSpan(context.region.span)
            }
            .sheet(item: $viewModel.selectedPlace) { place in
                placeCalloutSheet(for: place)
            }
    }

    /// Platform-appropriate core map, without shared modifiers.
    @ViewBuilder private var coreMap: some View {
        #if os(iOS)
        if #available(iOS 18.0, *) {
            FeatureSelectionMapView(viewModel: viewModel,
                                    featureSelectionMode: featureSelectionMode,
                                    content: mapContent)
        } else {
            legacyMap
        }
        #else
        // macOS always uses the legacy view (feature selection APIs are iOS-only)
        legacyMap
        #endif
    }

    /// Map view for iOS 17 / macOS 14 (no native feature selection support).
    private var legacyMap: some View {
        Map(position: $viewModel.cameraPosition) {
            mapContent
        }
    }

    /// Shared map content (annotations) used by both iOS 17 and iOS 18 views.
    ///
    /// Draws ``MapViewModel/annotationItems`` rather than the raw filtered places, so
    /// dense areas collapse into clusters instead of stacking unreadably.
    @MapContentBuilder private var mapContent: some MapContent {
        // User location
        if viewModel.userLocation != nil {
            UserAnnotation()
        }

        ForEach(viewModel.annotationItems) { item in
            Annotation(annotationTitle(for: item), coordinate: item.coordinate) {
                annotationBody(for: item)
            }
        }
        // Applied as a value rather than an `if`/`else`, which would make this
        // property a `_ConditionalContent` and change the type flowing into
        // `FeatureSelectionMapView`.
        .annotationTitles(viewModel.showsAnnotationTitles ? .automatic : .hidden)
    }

    /// The label SwiftUI renders beneath an annotation when titles are visible.
    private func annotationTitle(for item: MapAnnotationItem) -> String {
        switch item {
        case let .place(place):
            place.name
        case let .cluster(cluster):
            "\(cluster.count)"
        }
    }

    /// The marker or cluster bubble drawn for an annotation, with its tap behaviour.
    @ViewBuilder private func annotationBody(for item: MapAnnotationItem) -> some View {
        switch item {
        case let .place(place):
            markerContent(place)
                .onTapGesture {
                    viewModel.selectPlace(place)
                }
        case let .cluster(cluster):
            clusterContent(cluster)
                .onTapGesture {
                    viewModel.selectCluster(cluster)
                }
        }
    }

    /// Shared place callout sheet.
    private func placeCalloutSheet(for place: MapPlace) -> some View {
        sheetContent(place, viewModel.userLocation)
            .presentationDetents([.height(ViewDefaults.sheetInitialHeight), .medium])
    }
}

// MARK: - iOS 18+ Feature Selection Map View

#if os(iOS)
/// Internal map view that leverages iOS 18+ native feature selection APIs.
@available(iOS 18.0, *) private struct FeatureSelectionMapView<Content: MapContent>: View {
    @Bindable var viewModel: MapViewModel
    let featureSelectionMode: MapFeatureSelectionMode
    let content: Content

    @State private var nativeSelection: MapSelection<MKMapItem>?

    var body: some View {
        switch featureSelectionMode {
        case .disabled:
            mapWithSelectionDisabled
        case .pointsOfInterestOnly:
            mapWithPOISelection
        case .all:
            mapWithAllSelection
        }
    }

    private var mapWithSelectionDisabled: some View {
        Map(position: $viewModel.cameraPosition) {
            content
        }
        .mapFeatureSelectionDisabled { _ in true }
    }

    private var mapWithPOISelection: some View {
        Map(position: $viewModel.cameraPosition, selection: $nativeSelection) {
            content
        }
        .mapFeatureSelectionDisabled { feature in
            feature.kind != .pointOfInterest
        }
        .mapFeatureSelectionAccessory(.callout)
    }

    private var mapWithAllSelection: some View {
        Map(position: $viewModel.cameraPosition, selection: $nativeSelection) {
            content
        }
        .mapFeatureSelectionAccessory(.callout)
    }
}
#endif
