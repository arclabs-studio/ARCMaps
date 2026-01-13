import ARCLogger
import CoreLocation
import Foundation
import MapKit
import SwiftUI

/// ViewModel for map visualization
@MainActor
public final class MapViewModel: ObservableObject {

    // MARK: - Published State

    @Published public var places: [MapPlace] = []
    @Published public var filteredPlaces: [MapPlace] = []
    @Published public var selectedPlace: MapPlace?
    @Published public var userLocation: CLLocationCoordinate2D?
    @Published public var cameraPosition: MapCameraPosition = .automatic
    @Published public var filter: MapFilter = .all
    @Published public var mapStyle: MapStyle = .standard
    @Published public var isLoadingLocation = false
    @Published public var error: MapError?

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
    public func centerOnPlace(_ place: MapPlace, animated: Bool = true) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: place.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }

    /// Fit all filtered places in view
    public func fitAllPlaces() {
        guard !filteredPlaces.isEmpty else {
            logger.warning("No places to fit")
            return
        }

        let coordinates = filteredPlaces.map { $0.coordinate }

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
        guard let userLocation = userLocation else { return nil }
        return place.distance(from: userLocation)
    }

    /// Format distance for display
    public func formattedDistance(_ place: MapPlace) -> String? {
        guard let distance = distanceToPlace(place) else { return nil }
        return DistanceCalculator.formatDistance(distance)
    }
}
