//
//  MapViewModelTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import XCTest
@testable import ARCMaps
@testable import ARCMapsTestHelpers

@MainActor
final class MapViewModelTests: XCTestCase {
    var sut: MapViewModel!
    var mockLocationService: MockLocationService!

    override func setUp() async throws {
        try await super.setUp()

        mockLocationService = MockLocationService()

        sut = MapViewModel(locationService: mockLocationService)
    }

    override func tearDown() async throws {
        sut = nil
        mockLocationService = nil

        try await super.tearDown()
    }

    func testSetPlaces() {
        // Given
        let places = MapPlaceFixtures.allSamples

        // When
        sut.setPlaces(places)

        // Then
        XCTAssertEqual(sut.places.count, places.count)
        XCTAssertEqual(sut.filteredPlaces.count, places.count)
    }

    func testApplyFilter_StatusFilter() {
        // Given
        let places = MapPlaceFixtures.allSamples
        sut.setPlaces(places)

        var filter = MapFilter()
        filter.statuses = [.wishlist]

        // When
        sut.updateFilter(filter)

        // Then
        XCTAssertEqual(sut.filteredPlaces.count, 1)
        XCTAssertTrue(sut.filteredPlaces.allSatisfy { $0.status == .wishlist })
    }

    func testSelectPlace() {
        // Given
        let place = MapPlaceFixtures.wishlistRestaurant

        // When
        sut.selectPlace(place)

        // Then
        XCTAssertEqual(sut.selectedPlace, place)
    }
}
