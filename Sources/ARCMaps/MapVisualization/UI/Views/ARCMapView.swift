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
/// // Allow users to tap on restaurants, shops, etc.
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
    /// Users can only interact with your custom markers (``WishlistMarker``, ``VisitedMarker``).
    /// This provides a cleaner, more focused experience when you don't want users
    /// distracted by native Apple Maps POIs.
    case disabled

    /// Allow selection of native points of interest only.
    ///
    /// Users can tap on restaurants, shops, landmarks, parks, and other POIs
    /// to see Apple's native detail callout with:
    /// - Business hours
    /// - Phone number
    /// - Directions button
    /// - Website link
    /// - Photos and reviews
    ///
    /// City names, street labels, and other non-POI features remain non-selectable.
    case pointsOfInterestOnly

    /// Allow selection of all native map features.
    ///
    /// Users can tap on any label or feature on the map, including:
    /// - Points of interest (restaurants, shops, etc.)
    /// - City and neighborhood names
    /// - Street labels
    /// - Transit stations
    case all
}

// MARK: - Marker Resolution Helper

extension MapPlace {
    /// Resolves the appropriate marker view type for this place.
    ///
    /// - `.pending` → `PendingMarker`
    /// - `.visited && isFavorite` → `FavoriteMarker`
    /// - `.visited && !isFavorite` → `VisitedMarker`
    @MainActor @ViewBuilder fileprivate var markerView: some View {
        switch status {
        case .pending:
            PendingMarker(place: self)
        case .visited:
            if isFavorite {
                FavoriteMarker(place: self)
            } else {
                VisitedMarker(place: self)
            }
        }
    }
}

/// A SwiftUI view displaying an interactive map with place markers and controls.
///
/// `ARCMapView` provides a full-featured map interface with:
/// - Custom place markers for wishlist and visited locations
/// - Map controls (fit all, style selector)
/// - User location display
/// - Place detail sheets
/// - Optional native POI selection (iOS 18+)
///
/// ## Example
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
/// ## iOS 18+ Feature Selection
///
/// On iOS 18 and later, you can enable native POI selection:
///
/// ```swift
/// ARCMapView(
///     viewModel: viewModel,
///     featureSelectionMode: .pointsOfInterestOnly
/// )
/// ```
///
/// This allows users to tap on native Apple Maps POIs (restaurants, shops, etc.)
/// and see detailed callouts with business hours, directions, and more.
public struct ARCMapView: View {
    /// The view model managing map state and place data.
    @Bindable var viewModel: MapViewModel

    /// Controls native map feature selection behavior (iOS 18+ only).
    ///
    /// On iOS 17 and macOS, this setting has no effect and the legacy view is used.
    private let featureSelectionMode: MapFeatureSelectionMode

    /// Creates a new map view with the specified configuration.
    ///
    /// - Parameters:
    ///   - viewModel: The view model managing map state, places, and user location.
    ///   - featureSelectionMode: Controls native POI selection behavior on iOS 18+.
    ///     Default is `.disabled`, which provides a cleaner experience focused on your custom markers.
    public init(viewModel: MapViewModel,
                featureSelectionMode: MapFeatureSelectionMode = .disabled) {
        self.viewModel = viewModel
        self.featureSelectionMode = featureSelectionMode
    }

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
    @MapContentBuilder private var mapContent: some MapContent {
        // User location
        if viewModel.userLocation != nil {
            UserAnnotation()
        }

        ForEach(viewModel.filteredPlaces) { place in
            Annotation(place.name, coordinate: place.coordinate) {
                place.markerView
                    .onTapGesture {
                        viewModel.selectPlace(place)
                    }
            }
        }
    }

    /// Shared place callout sheet.
    private func placeCalloutSheet(for place: MapPlace) -> some View {
        PlaceCalloutView(place: place,
                         userLocation: viewModel.userLocation,
                         onOpenInMaps: { app in
                             await viewModel.openInExternalMaps(place, app: app)
                         })
                         .presentationDetents([.height(ViewDefaults.sheetInitialHeight), .medium])
    }
}

// MARK: - iOS 18+ Feature Selection Map View

#if os(iOS)
/// Internal map view that leverages iOS 18+ native feature selection APIs.
///
/// This view provides enhanced map interaction by allowing users to tap on
/// native Apple Maps features (POIs, labels, etc.) and see detailed callouts
/// with business information, directions, and more.
///
/// ## Implementation Details
///
/// Uses the following iOS 18+ MapKit APIs:
/// - `mapFeatureSelectionDisabled(_:)`: Controls which features can be selected
/// - `mapFeatureSelectionAccessory(_:)`: Configures the callout style for selected features
/// - `MapSelection<MKMapItem>`: Binding for tracking the selected map feature
///
/// - Note: This view is only compiled for iOS. macOS uses the legacy view
///   because feature selection APIs are not available on that platform.
@available(iOS 18.0, *) private struct FeatureSelectionMapView<Content: MapContent>: View {
    /// The view model managing map state and place data.
    @Bindable var viewModel: MapViewModel

    /// The configured feature selection mode.
    let featureSelectionMode: MapFeatureSelectionMode

    /// The map annotations content passed in from the parent view.
    let content: Content

    /// Tracks the currently selected native map feature (POI).
    ///
    /// When a user taps a native POI, this binding is updated with the
    /// corresponding `MKMapItem`, which triggers the callout display.
    @State private var nativeSelection: MapSelection<MKMapItem>?

    var body: some View {
        Group {
            switch featureSelectionMode {
            case .disabled:
                mapWithSelectionDisabled
            case .pointsOfInterestOnly:
                mapWithPOISelection
            case .all:
                mapWithAllSelection
            }
        }
    }

    // MARK: - Map Configurations

    /// Map with all native feature selection disabled.
    private var mapWithSelectionDisabled: some View {
        Map(position: $viewModel.cameraPosition) {
            content
        }
        .mapFeatureSelectionDisabled { _ in true }
    }

    /// Map with only POI selection enabled.
    ///
    /// Allows selection of restaurants, shops, landmarks, etc.
    /// Disables selection of city labels, street names, and other non-POI features.
    private var mapWithPOISelection: some View {
        Map(position: $viewModel.cameraPosition, selection: $nativeSelection) {
            content
        }
        .mapFeatureSelectionDisabled { feature in
            feature.kind != .pointOfInterest
        }
        .mapFeatureSelectionAccessory(.callout)
    }

    /// Map with all native feature selection enabled.
    private var mapWithAllSelection: some View {
        Map(position: $viewModel.cameraPosition, selection: $nativeSelection) {
            content
        }
        .mapFeatureSelectionAccessory(.callout)
    }
}
#endif
