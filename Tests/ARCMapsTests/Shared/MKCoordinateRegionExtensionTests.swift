//
//  MKCoordinateRegionExtensionTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 19/03/2026.
//

import CoreLocation
import MapKit
import Testing
@testable import ARCMaps

struct MKCoordinateRegionExtensionTests {
    // MARK: - Edge Cases

    @Test("Fitting an empty coordinate array returns nil")
    func fittingEmptyArrayReturnsNil() {
        #expect(MKCoordinateRegion.fitting([]) == nil)
    }

    // MARK: - Single Coordinate

    @Test("Fitting a single coordinate produces the minimum span")
    func fittingSingleCoordinateProducesMinimumSpan() throws {
        // Given
        let coord = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)

        // When
        let region = MKCoordinateRegion.fitting([coord])

        // Then
        let result = try #require(region)
        #expect(result.center.latitude == coord.latitude)
        #expect(result.center.longitude == coord.longitude)
        // Single point span is clamped to 0.01 minimum
        #expect(result.span.latitudeDelta >= 0.01)
        #expect(result.span.longitudeDelta >= 0.01)
    }

    // MARK: - Multiple Coordinates

    @Test("Fitting multiple coordinates centers on their bounding box midpoint")
    func fittingMultipleCoordinatesCentersCorrectly() throws {
        // Given — two points with known midpoint
        let north = CLLocationCoordinate2D(latitude: 42.0, longitude: 0.0)
        let south = CLLocationCoordinate2D(latitude: 40.0, longitude: 0.0)

        // When
        let region = MKCoordinateRegion.fitting([north, south])

        // Then
        let result = try #require(region)
        #expect(abs(result.center.latitude - 41.0) < 0.0001)
        #expect(abs(result.center.longitude - 0.0) < 0.0001)
    }

    @Test("Fitting multiple coordinates spans their full extent with padding")
    func fittingMultipleCoordinatesSpansFullExtent() throws {
        // Given
        let coords = [
            CLLocationCoordinate2D(latitude: 40.0, longitude: -4.0),
            CLLocationCoordinate2D(latitude: 42.0, longitude: -2.0)
        ]

        // When
        let region = MKCoordinateRegion.fitting(coords)

        // Then
        let result = try #require(region)
        // Span should exceed the 2-degree difference (padding = 10% by default)
        #expect(result.span.latitudeDelta >= 2.0)
        #expect(result.span.longitudeDelta >= 2.0)
    }

    @Test("Custom padding factor expands span proportionally")
    func customPaddingExpandsSpan() throws {
        // Given
        let coords = [
            CLLocationCoordinate2D(latitude: 40.0, longitude: 0.0),
            CLLocationCoordinate2D(latitude: 42.0, longitude: 0.0)
        ]

        // When
        let regionNoPadding = MKCoordinateRegion.fitting(coords, padding: 0.0)
        let regionHighPadding = MKCoordinateRegion.fitting(coords, padding: 1.0) // 100% padding

        // Then
        let resultNone = try #require(regionNoPadding)
        let resultHigh = try #require(regionHighPadding)
        #expect(resultHigh.span.latitudeDelta > resultNone.span.latitudeDelta)
    }
}
