//
//  MapViewModel.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import ARCLogger
import CoreLocation
import Foundation
import MapKit
import Observation
import SwiftUI // Required: MapCameraPosition is a MapKit+SwiftUI bridge type

// MARK: - Constants

private enum MapDefaults {
    /// Default latitude delta for single place view (approximately 1km visible area).
    static let defaultSpanLatitudeDelta: CLLocationDegrees = 0.01
    /// Default longitude delta for single place view (approximately 1km visible area).
    static let defaultSpanLongitudeDelta: CLLocationDegrees = 0.01
}

/// ViewModel for map visualization
@Observable
@MainActor public final class MapViewModel {
    // MARK: - State

    public var places: [MapPlace] = []
    public var filteredPlaces: [MapPlace] = []
    public var selectedPlace: MapPlace?
    public var userLocation: CLLocationCoordinate2D?
    public var cameraPosition: MapCameraPosition = .automatic
    public var filter: MapFilter = .all
    public var mapStyle: MapStyle = .standard
    public var isLoadingLocation = false
    public var error: MapError?

    // MARK: - Clustering

    /// The items the map draws: standalone places and clusters of nearby places.
    ///
    /// Recomputed when the filtered places change, when clustering is toggled, or
    /// when the camera crosses into a different ``ZoomBucket``. When
    /// ``clusteringEnabled`` is `false` this is one ``MapAnnotationItem/place(_:)``
    /// per filtered place.
    public private(set) var annotationItems: [MapAnnotationItem] = []

    /// Whether nearby places collapse into clusters as the map zooms out.
    ///
    /// Enabled by default. Disable it for collections small enough that every pin
    /// stays legible at any zoom.
    /// Backing storage for ``clusteringEnabled``.
    ///
    /// Split from its public accessor because `@Observable` rewrites stored properties
    /// into tracked computed ones, which does not compose with `didSet`.
    private var isClusteringEnabled = true

    public var clusteringEnabled: Bool {
        get { isClusteringEnabled }
        set {
            guard newValue != isClusteringEnabled else { return }
            isClusteringEnabled = newValue
            rebuildAnnotationItems()
        }
    }

    /// Whether each annotation renders its place name beneath the marker.
    ///
    /// Disabled by default: name labels are a large part of what makes dense areas
    /// unreadable, and SwiftUI's `Annotation` always draws them unless suppressed
    /// from inside the package.
    public var showsAnnotationTitles = false

    // MARK: - Dependencies

    private let locationService: LocationService
    private let clusterer: PlaceClusterer
    private let logger = ARCLogger(category: "MapViewModel")

    /// The zoom bucket the current ``annotationItems`` were computed for.
    private var currentZoomBucket = ZoomBucket(latitudeDelta: MapDefaults.defaultSpanLatitudeDelta)

    // MARK: - Initialization

    /// Creates a map view model.
    ///
    /// - Parameters:
    ///   - locationService: Supplies permission state and user location updates.
    ///   - clusterer: Collapses nearby places into clusters. Pass a clusterer with a
    ///     different `minimumClusterSize` to tune how eagerly pins group.
    public init(locationService: LocationService,
                clusterer: PlaceClusterer = PlaceClusterer()) {
        self.locationService = locationService
        self.clusterer = clusterer
    }

    // MARK: - Public Methods

    /// Set places to display on map
    public func setPlaces(_ places: [MapPlace]) {
        logger.info("Setting \(places.count) places on map")
        self.places = places
        applyFilter()
    }

    /// Request location permission and get user location
    public func requestLocationPermission() async {
        logger.info("Requesting location permission")

        isLoadingLocation = true
        defer { isLoadingLocation = false }

        let granted = await locationService.requestPermission()

        if granted {
            await updateUserLocation()
        } else {
            error = .locationPermissionDenied
            logger.warning("Location permission denied")
        }
    }

    /// Update user's current location
    public func updateUserLocation() async {
        do {
            userLocation = try await locationService.getCurrentLocation()
            logger.debug("User location updated")
        } catch {
            logger.error("Failed to get user location: \(error.localizedDescription)")
        }
    }

    /// Apply current filter
    public func applyFilter() {
        filteredPlaces = places.filter { filter.matches($0) }
        logger.debug("Filtered to \(filteredPlaces.count) places")
        rebuildAnnotationItems()
    }

    /// Update the clustering grid to match the map camera.
    ///
    /// Called from `onMapCameraChange`. The span is snapped to a discrete
    /// ``ZoomBucket`` and clusters are rebuilt only when that bucket changes —
    /// otherwise selecting a place, which recenters the camera, would rebuild every
    /// annotation mid-selection and visibly churn the map.
    ///
    /// - Parameter span: The camera's current visible span.
    public func updateCameraSpan(_ span: MKCoordinateSpan) {
        let bucket = ZoomBucket(latitudeDelta: span.latitudeDelta)

        guard bucket != currentZoomBucket else { return }

        currentZoomBucket = bucket
        logger.debug("Zoom bucket changed to level \(bucket.level)")
        rebuildAnnotationItems()
    }

    /// Zoom the camera to fit every place in a cluster.
    ///
    /// This is the tap behaviour for cluster markers: rather than opening a sheet for
    /// an ambiguous group, the map zooms in until the members separate.
    ///
    /// - Parameter cluster: The tapped cluster.
    public func selectCluster(_ cluster: MapCluster) {
        logger.info("Selected cluster of \(cluster.count) places")

        guard let region = MKCoordinateRegion.fitting(cluster.places.map(\.coordinate)) else {
            logger.warning("Cluster has no fittable region")
            return
        }

        cameraPosition = .region(region)
    }

    /// Update filter and reapply
    public func updateFilter(_ newFilter: MapFilter) {
        filter = newFilter
        applyFilter()
    }

    /// Select a place
    public func selectPlace(_ place: MapPlace) {
        logger.info("Selected place: \(place.name)")
        selectedPlace = place

        // Center map on selected place
        centerOnPlace(place, animated: true)
    }

    /// Center map on a place
    public func centerOnPlace(_ place: MapPlace, animated _: Bool = true) {
        cameraPosition = .region(MKCoordinateRegion(center: place.coordinate,
                                                    span: MKCoordinateSpan(latitudeDelta: MapDefaults
                                                        .defaultSpanLatitudeDelta,
                                                        longitudeDelta: MapDefaults
                                                            .defaultSpanLongitudeDelta)))
    }

    /// Fit all filtered places in view
    public func fitAllPlaces() {
        guard !filteredPlaces.isEmpty else {
            logger.warning("No places to fit")
            return
        }

        let coordinates = filteredPlaces.map(\.coordinate)

        if let region = MKCoordinateRegion.fitting(coordinates) {
            cameraPosition = .region(region)
            logger.debug("Fitted \(filteredPlaces.count) places in view")
        }
    }

    /// Open place in external maps app
    public func openInExternalMaps(_ place: MapPlace, app: ExternalMapApp) async {
        logger.info("Opening \(place.name) in \(app.rawValue)")

        do {
            try await ExternalMapLauncher.open(coordinate: place.coordinate,
                                               name: place.name,
                                               address: place.address,
                                               app: app)
        } catch let mapError as MapError {
            error = mapError
            logger.error("Failed to open external map: \(mapError)")
        } catch {
            logger.error("Failed to open external map: \(error.localizedDescription)")
        }
    }

    /// Change map style
    public func changeMapStyle(_ style: MapStyle) {
        logger.info("Changing map style to: \(style.rawValue)")
        mapStyle = style
    }

    /// Get distance from user to place
    public func distanceToPlace(_ place: MapPlace) -> Double? {
        guard let userLocation else { return nil }
        return place.distance(from: userLocation)
    }

    /// Format distance for display
    public func formattedDistance(_ place: MapPlace) -> String? {
        guard let distance = distanceToPlace(place) else { return nil }
        return DistanceCalculator.formatDistance(distance)
    }

    // MARK: - Private Methods

    /// Recomputes ``annotationItems`` from the filtered places at the current zoom.
    private func rebuildAnnotationItems() {
        guard clusteringEnabled else {
            annotationItems = filteredPlaces.map(MapAnnotationItem.place)
            return
        }

        annotationItems = clusterer.cluster(filteredPlaces, bucket: currentZoomBucket)
    }
}
