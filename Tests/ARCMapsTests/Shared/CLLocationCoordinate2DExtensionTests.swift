//
//  CLLocationCoordinate2DExtensionTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 19/03/2026.
//

import CoreLocation
import Testing
@testable import ARCMaps

struct CLLocationCoordinate2DExtensionTests {
    // MARK: - Equatable

    @Test("Equal coordinates compare as equal") func equalCoordinatesAreEqual() {
        // Given
        let coordA = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        let coordB = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)

        // Then
        #expect(coordA == coordB)
    }

    @Test("Coordinates with different latitude compare as not equal") func differentLatitudeNotEqual() {
        let coordA = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        let coordB = CLLocationCoordinate2D(latitude: 41.3874, longitude: -3.7038)
        #expect(coordA != coordB)
    }

    @Test("Coordinates with different longitude compare as not equal") func differentLongitudeNotEqual() {
        let coordA = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        let coordB = CLLocationCoordinate2D(latitude: 40.4168, longitude: 2.1686)
        #expect(coordA != coordB)
    }

    // MARK: - Hashable

    @Test("Equal coordinates produce the same hash value") func equalCoordinatesHaveSameHash() {
        // Given
        let coordA = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        let coordB = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)

        // Then
        #expect(coordA.hashValue == coordB.hashValue)
    }

    @Test("Coordinates can be used as dictionary keys") func coordinateCanBeUsedAsDictionaryKey() {
        // Given
        let coord = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        var dict = [CLLocationCoordinate2D: String]()

        // When
        dict[coord] = "Madrid"

        // Then
        #expect(dict[coord] == "Madrid")
    }

    // MARK: - isValid

    @Test("Valid coordinate within bounds is marked valid") func validCoordinateIsValid() {
        let coord = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        #expect(coord.isValid)
    }

    @Test("Coordinate with out-of-range latitude is marked invalid") func outOfRangeLatitudeIsInvalid() {
        let coord = CLLocationCoordinate2D(latitude: 200.0, longitude: 0.0)
        #expect(!coord.isValid)
    }

    @Test("Coordinate with out-of-range longitude is marked invalid") func outOfRangeLongitudeIsInvalid() {
        let coord = CLLocationCoordinate2D(latitude: 0.0, longitude: 400.0)
        #expect(!coord.isValid)
    }

    // MARK: - distance(to:)

    @Test("Distance between Madrid and Barcelona is approximately 505 km") func distanceBetweenMadridAndBarcelona() {
        // Given
        let madrid = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        let barcelona = CLLocationCoordinate2D(latitude: 41.3874, longitude: 2.1686)

        // When
        let distance = madrid.distance(to: barcelona)

        // Then — great-circle distance is ~505 km
        #expect(distance > 500_000)
        #expect(distance < 510_000)
    }

    @Test("Distance from a coordinate to itself is zero") func distanceToSelfIsZero() {
        let coord = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        #expect(coord.distance(to: coord) == 0)
    }
}
