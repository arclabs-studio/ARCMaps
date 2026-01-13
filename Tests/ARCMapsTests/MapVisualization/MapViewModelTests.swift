//
//  MapViewModelTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

@Suite("MapViewModel Tests", .serialized)
@MainActor
struct MapViewModelTests {
    let mockLocationService: MockLocationService
    let sut: MapViewModel

    init() async throws {
        mockLocationService = MockLocationService()
        sut = MapViewModel(locationService: mockLocationService)
    }

    // MARK: - Places Management

    @Test("Set places updates both places and filtered places")
    func setPlacesUpdatesBothCollections() {
        // Given
        let places = MapPlaceFixtures.allSamples

        // When
        sut.setPlaces(places)

        // Then
        #expect(sut.places.count == places.count)
        #expect(sut.filteredPlaces.count == places.count)
    }

    @Test("Set places replaces existing places")
    func setPlacesReplacesExisting() {
        // Given
        sut.setPlaces(MapPlaceFixtures.allSamples)
        let newPlaces = MapPlaceFixtures.wishlistOnly

        // When
        sut.setPlaces(newPlaces)

        // Then
        #expect(sut.places.count == newPlaces.count)
    }

    // MARK: - Filtering

    @Test("Apply status filter shows only matching places")
    func applyStatusFilterShowsOnlyMatching() {
        // Given
        let places = MapPlaceFixtures.allSamples
        sut.setPlaces(places)

        var filter = MapFilter()
        filter.statuses = [.wishlist]

        // When
        sut.updateFilter(filter)

        // Then
        #expect(sut.filteredPlaces.count == 1)
        #expect(sut.filteredPlaces.allSatisfy { $0.status == .wishlist })
    }

    @Test("Apply visited status filter shows only visited places")
    func applyVisitedStatusFilter() {
        // Given
        let places = MapPlaceFixtures.allSamples
        sut.setPlaces(places)

        var filter = MapFilter()
        filter.statuses = [.visited]

        // When
        sut.updateFilter(filter)

        // Then
        #expect(sut.filteredPlaces.count == 2)
        #expect(sut.filteredPlaces.allSatisfy { $0.status == .visited })
    }

    @Test("Clear filter shows all places")
    func clearFilterShowsAllPlaces() {
        // Given
        let places = MapPlaceFixtures.allSamples
        sut.setPlaces(places)

        var filter = MapFilter()
        filter.statuses = [.wishlist]
        sut.updateFilter(filter)

        // When
        sut.updateFilter(.all)

        // Then
        #expect(sut.filteredPlaces.count == places.count)
    }

    // MARK: - Selection

    @Test("Select place updates selected place")
    func selectPlaceUpdatesSelectedPlace() {
        // Given
        let place = MapPlaceFixtures.wishlistRestaurant

        // When
        sut.selectPlace(place)

        // Then
        #expect(sut.selectedPlace == place)
    }

    @Test("Clear selection sets selected place to nil")
    func clearSelectionSetsSelectedPlaceToNil() {
        // Given
        let place = MapPlaceFixtures.wishlistRestaurant
        sut.selectPlace(place)

        // When
        sut.selectedPlace = nil

        // Then
        #expect(sut.selectedPlace == nil)
    }

    // MARK: - Camera Position

    @Test("Initial camera position is automatic")
    func initialCameraPositionIsAutomatic() {
        // Then
        switch sut.cameraPosition {
        case .automatic:
            #expect(Bool(true))
        default:
            Issue.record("Expected automatic camera position")
        }
    }

    @Test("Selecting place updates camera position")
    func selectingPlaceUpdatesCameraPosition() {
        // Given
        let place = MapPlaceFixtures.wishlistRestaurant

        // When
        sut.selectPlace(place)

        // Then - camera should be region-based after selection
        // MapCameraPosition.region returns an MKCoordinateRegion?, so we check if it's not nil
        #expect(sut.cameraPosition.region != nil)
    }
}
