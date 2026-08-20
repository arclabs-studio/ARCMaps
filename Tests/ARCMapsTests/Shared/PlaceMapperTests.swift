//
//  PlaceMapperTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 18/03/2026.
//

import CoreLocation
import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

struct PlaceMapperTests {
    // MARK: - toMapPlace

    @Test("toMapPlace preserves id from search result") func toMapPlacePreservesID() {
        // Given
        let result = PlaceSearchResultFixtures.sampleRestaurant

        // When
        let place = PlaceMapper.toMapPlace(result)

        // Then
        #expect(place.id == result.id)
    }

    @Test("toMapPlace preserves name from search result") func toMapPlacePreservesName() {
        // Given
        let result = PlaceSearchResultFixtures.sampleRestaurant

        // When
        let place = PlaceMapper.toMapPlace(result)

        // Then
        #expect(place.name == result.name)
    }

    @Test("toMapPlace preserves coordinate from search result") func toMapPlacePreservesCoordinate() {
        // Given
        let result = PlaceSearchResultFixtures.sampleRestaurant

        // When
        let place = PlaceMapper.toMapPlace(result)

        // Then
        #expect(place.coordinate.latitude == result.coordinate.latitude)
        #expect(place.coordinate.longitude == result.coordinate.longitude)
    }

    @Test("toMapPlace preserves address from search result") func toMapPlacePreservesAddress() {
        // Given
        let result = PlaceSearchResultFixtures.sampleRestaurant

        // When
        let place = PlaceMapper.toMapPlace(result)

        // Then
        #expect(place.address == result.address)
    }

    @Test("toMapPlace uses first type as category") func toMapPlaceUsesFirstTypeAsCategory() {
        // Given
        let result = PlaceSearchResultFixtures.sampleRestaurant // types: ["restaurant", "food"]

        // When
        let place = PlaceMapper.toMapPlace(result)

        // Then
        #expect(place.category == "restaurant")
    }

    @Test("toMapPlace sets nil category when types is empty") func toMapPlaceSetNilCategoryWhenTypesEmpty() {
        // Given
        let result = PlaceSearchResultFixtures.sampleBar

        // When
        let place = PlaceMapper.toMapPlace(result)

        // Then
        #expect(place.category == result.types.first)
    }

    @Test("toMapPlace preserves rating from search result") func toMapPlacePreservesRating() {
        // Given
        let result = PlaceSearchResultFixtures.sampleRestaurant // rating: 4.5

        // When
        let place = PlaceMapper.toMapPlace(result)

        // Then
        #expect(place.rating == result.rating)
    }

    @Test("toMapPlace sets imageURL to nil") func toMapPlaceSetsImageURLNil() {
        // Given
        let result = PlaceSearchResultFixtures.sampleRestaurant

        // When
        let place = PlaceMapper.toMapPlace(result)

        // Then
        #expect(place.imageURL == nil)
    }

    @Test("toMapPlace handles result with no rating") func toMapPlaceHandlesResultWithNoRating() {
        // Given
        let appleResult = PlaceSearchResultFixtures.sampleBar

        // When
        let place = PlaceMapper.toMapPlace(appleResult)

        // Then
        #expect(place.rating == appleResult.rating)
    }
}
