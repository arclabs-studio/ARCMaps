//
//  PlaceSearchQueryTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Testing
@testable import ARCMaps

@Suite("PlaceSearchQuery Tests")
struct PlaceSearchQueryTests {
    // MARK: - Full Text Query

    @Test("Full text query contains only name when no other fields")
    func fullTextQueryContainsOnlyName() {
        // Given
        let query = PlaceSearchQuery(name: "La Taverna")

        // When/Then
        #expect(query.fullTextQuery == "La Taverna")
    }

    @Test("Full text query combines name and address")
    func fullTextQueryCombinesNameAndAddress() {
        // Given
        let query = PlaceSearchQuery(name: "La Taverna", address: "Calle Mayor 15")

        // When/Then
        #expect(query.fullTextQuery == "La Taverna, Calle Mayor 15")
    }

    @Test("Full text query combines all fields")
    func fullTextQueryCombinesAllFields() {
        // Given
        let query = PlaceSearchQuery(
            name: "La Taverna",
            address: "Calle Mayor 15",
            city: "Madrid"
        )

        // When/Then
        #expect(query.fullTextQuery == "La Taverna, Calle Mayor 15, Madrid")
    }

    @Test("Full text query skips nil fields")
    func fullTextQuerySkipsNilFields() {
        // Given
        let query = PlaceSearchQuery(name: "La Taverna", city: "Madrid")

        // When/Then
        #expect(query.fullTextQuery == "La Taverna, Madrid")
    }

    // MARK: - Equality

    @Test("Queries with same values are equal")
    func queriesWithSameValuesAreEqual() {
        // Given
        let query1 = PlaceSearchQuery(name: "Test", address: "Address", city: "City")
        let query2 = PlaceSearchQuery(name: "Test", address: "Address", city: "City")

        // When/Then
        #expect(query1 == query2)
    }

    @Test("Queries with different names are not equal")
    func queriesWithDifferentNamesAreNotEqual() {
        // Given
        let query1 = PlaceSearchQuery(name: "Test1")
        let query2 = PlaceSearchQuery(name: "Test2")

        // When/Then
        #expect(query1 != query2)
    }

    @Test("Queries with different coordinates are not equal")
    func queriesWithDifferentCoordinatesAreNotEqual() {
        // Given
        let query1 = PlaceSearchQuery(name: "Test", coordinate: (40.0, -3.0))
        let query2 = PlaceSearchQuery(name: "Test", coordinate: (41.0, -4.0))

        // When/Then
        #expect(query1 != query2)
    }

    // MARK: - Hashable

    @Test("Equal queries have same hash")
    func equalQueriesHaveSameHash() {
        // Given
        let query1 = PlaceSearchQuery(name: "Test", address: "Address")
        let query2 = PlaceSearchQuery(name: "Test", address: "Address")

        // When/Then
        #expect(query1.hashValue == query2.hashValue)
    }

    @Test("Queries can be used as dictionary keys")
    func queriesCanBeUsedAsDictionaryKeys() {
        // Given
        let query1 = PlaceSearchQuery(name: "Test1")
        let query2 = PlaceSearchQuery(name: "Test2")
        var dict: [PlaceSearchQuery: String] = [:]

        // When
        dict[query1] = "Value1"
        dict[query2] = "Value2"

        // Then
        #expect(dict[query1] == "Value1")
        #expect(dict[query2] == "Value2")
    }

    // MARK: - Coordinate and Radius

    @Test("Query with coordinate includes latitude and longitude")
    func queryWithCoordinateIncludesLatLong() {
        // Given
        let query = PlaceSearchQuery(
            name: "Test",
            coordinate: (latitude: 40.4168, longitude: -3.7038),
            radiusMeters: 1000
        )

        // Then
        #expect(query.coordinate?.latitude == 40.4168)
        #expect(query.coordinate?.longitude == -3.7038)
        #expect(query.radiusMeters == 1000)
    }

    @Test("Query without coordinate has nil values")
    func queryWithoutCoordinateHasNilValues() {
        // Given
        let query = PlaceSearchQuery(name: "Test")

        // Then
        #expect(query.coordinate == nil)
        #expect(query.radiusMeters == nil)
    }
}
