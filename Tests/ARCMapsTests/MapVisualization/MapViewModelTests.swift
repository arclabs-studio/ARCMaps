//
//  MapViewModelTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

@Suite(.serialized)
@MainActor struct MapViewModelTests {
    let mockLocationService: MockLocationService
    let sut: MapViewModel

    init() async throws {
        mockLocationService = MockLocationService()
        sut = MapViewModel(locationService: mockLocationService)
    }

    // MARK: - Places Management

    @Test("Set places updates both places and filtered places") func setPlacesUpdatesBothCollections() {
        // Given
        let places = MapPlaceFixtures.allSamples

        // When
        sut.setPlaces(places)

        // Then
        #expect(sut.places.count == places.count)
        #expect(sut.filteredPlaces.count == places.count)
    }

    @Test("Set places replaces existing places") func setPlacesReplacesExisting() {
        // Given
        sut.setPlaces(MapPlaceFixtures.allSamples)
        let newPlaces = [MapPlaceFixtures.restaurant]

        // When
        sut.setPlaces(newPlaces)

        // Then
        #expect(sut.places.count == newPlaces.count)
    }

    // MARK: - Filtering

    @Test("Apply category filter shows only matching places") func applyCategoryFilterShowsOnlyMatching() {
        // Given
        let places = MapPlaceFixtures.allSamples
        sut.setPlaces(places)

        let filter = MapFilter(categories: ["Cafe"])

        // When
        sut.updateFilter(filter)

        // Then
        #expect(sut.filteredPlaces.count == 1)
        #expect(sut.filteredPlaces.allSatisfy { $0.category == "Cafe" })
    }

    @Test("Clear filter shows all places") func clearFilterShowsAllPlaces() {
        // Given
        let places = MapPlaceFixtures.allSamples
        sut.setPlaces(places)

        sut.updateFilter(MapFilter(categories: ["Cafe"]))

        // When
        sut.updateFilter(.all)

        // Then
        #expect(sut.filteredPlaces.count == places.count)
    }

    // MARK: - Selection

    @Test("Select place updates selected place") func selectPlaceUpdatesSelectedPlace() {
        // Given
        let place = MapPlaceFixtures.restaurant

        // When
        sut.selectPlace(place)

        // Then
        #expect(sut.selectedPlace == place)
    }

    @Test("Clear selection sets selected place to nil") func clearSelectionSetsSelectedPlaceToNil() {
        // Given
        let place = MapPlaceFixtures.restaurant
        sut.selectPlace(place)

        // When
        sut.selectedPlace = nil

        // Then
        #expect(sut.selectedPlace == nil)
    }

    // MARK: - Location Permission

    @Test("A denied permission surfaces the error once") func deniedPermissionSetsError() async {
        // Given
        await mockLocationService.setMockPermissionGranted(false)
        await mockLocationService.setMockAuthorizationStatus(.denied)

        // When
        await sut.requestLocationPermission()

        // Then
        #expect(sut.error == .locationPermissionDenied)
        #expect(sut.isLoadingLocation == false)
    }

    /// FVRS-324 — `ARCMapView`'s `.task` re-runs on every appearance of the map,
    /// so without this guard the alert came back on every visit to the tab.
    @Test("A second request after a reported denial is skipped") func deniedPermissionDoesNotRenag() async {
        // Given — a denial has already been surfaced and the user dismissed the alert
        await mockLocationService.setMockPermissionGranted(false)
        await mockLocationService.setMockAuthorizationStatus(.denied)
        await sut.requestLocationPermission()
        #expect(sut.error == .locationPermissionDenied)
        sut.error = nil
        await mockLocationService.reset()

        // When — the map appears again
        await sut.requestLocationPermission()

        // Then — nothing was asked and no alert was re-armed
        #expect(await mockLocationService.requestPermissionCalled == false)
        #expect(sut.error == nil)
    }

    @Test("A still-undetermined status is requested even after an earlier denial")
    func notDeterminedStatusStillRequests() async {
        // Given — a denial was reported, then the status moved back to undetermined
        await mockLocationService.setMockPermissionGranted(false)
        await mockLocationService.setMockAuthorizationStatus(.denied)
        await sut.requestLocationPermission()
        sut.error = nil
        await mockLocationService.reset()
        await mockLocationService.setMockAuthorizationStatus(.notDetermined)
        await mockLocationService.setMockPermissionGranted(true)
        await mockLocationService.setMockCurrentLocation(CLLocationCoordinate2D(latitude: 40.41, longitude: -3.70))

        // When
        await sut.requestLocationPermission()

        // Then — the guard only short-circuits a denied/restricted status
        #expect(await mockLocationService.requestPermissionCalled == true)
        #expect(sut.error == nil)
        #expect(sut.userLocation != nil)
    }

    // MARK: - Camera Position

    @Test("Initial camera position is automatic") func initialCameraPositionIsAutomatic() {
        // Then
        switch sut.cameraPosition {
        case .automatic:
            #expect(Bool(true))
        default:
            Issue.record("Expected automatic camera position")
        }
    }

    @Test("Selecting place updates camera position") func selectingPlaceUpdatesCameraPosition() {
        // Given
        let place = MapPlaceFixtures.restaurant

        // When
        sut.selectPlace(place)

        // Then - camera should be region-based after selection
        #expect(sut.cameraPosition.region != nil)
    }
}
