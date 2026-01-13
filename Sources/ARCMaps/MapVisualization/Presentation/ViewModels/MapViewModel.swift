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
import SwiftUI

// MARK: - Constants

private enum MapDefaults {
    /// Default latitude delta for single place view (approximately 1km visible area).
    static let defaultSpanLatitudeDelta: CLLocationDegrees = 0.01
    /// Default longitude delta for single place view (approximately 1km visible area).
    static let defaultSpanLongitudeDelta: CLLocationDegrees = 0.01
}

/// ViewModel for map visualization
@Observable
@MainActor
public final class MapViewModel {
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

    // MARK: - Dependencies

    private let locationService: LocationService
    private let logger = ARCLogger(category: "MapViewModel")

    // MARK: - Initialization

    public init(locationService: LocationService) {
        self.locationService = locationService
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
        cameraPosition = .region(
            MKCoordinateRegion(
                center: place.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: MapDefaults.defaultSpanLatitudeDelta,
                    longitudeDelta: MapDefaults.defaultSpanLongitudeDelta
                )
            )
        )
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
            try await ExternalMapLauncher.open(
                coordinate: place.coordinate,
                name: place.name,
                address: place.address,
                app: app
            )
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
}
