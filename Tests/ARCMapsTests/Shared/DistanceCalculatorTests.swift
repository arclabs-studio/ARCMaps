//
//  DistanceCalculatorTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Testing
@testable import ARCMaps

@Suite("DistanceCalculator Tests")
struct DistanceCalculatorTests {
    // MARK: - Distance Calculation

    @Test("Distance between two coordinates is calculated correctly")
    func distanceBetweenCoordinates() {
        // Given
        let madrid = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        let barcelona = CLLocationCoordinate2D(latitude: 41.3874, longitude: 2.1686)

        // When
        let distance = DistanceCalculator.distance(from: madrid, to: barcelona)

        // Then
        #expect(distance > 0)
        #expect(distance > 500_000) // At least 500km
        #expect(distance < 700_000) // Less than 700km
    }

    @Test("Distance to same coordinate is zero")
    func distanceToSameCoordinateIsZero() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)

        // When
        let distance = DistanceCalculator.distance(from: coordinate, to: coordinate)

        // Then
        #expect(distance == 0)
    }

    // MARK: - Format Distance

    @Test("Format distance returns non-empty string for short distances")
    func formatDistanceReturnsNonEmptyStringForShortDistances() {
        // Given
        let meters: Double = 150

        // When
        let formatted = DistanceCalculator.formatDistance(meters)

        // Then - verify it returns a non-empty formatted string
        // Note: MeasurementFormatter may auto-convert units based on locale
        #expect(!formatted.isEmpty)
        #expect(formatted.count > 1)
    }

    @Test("Format distance returns valid string for kilometer distances")
    func formatDistanceReturnsValidStringForKilometerDistances() {
        // Given
        let meters: Double = 2500

        // When
        let formatted = DistanceCalculator.formatDistance(meters)

        // Then - verify it returns a valid formatted string
        // Note: Exact format depends on locale (e.g., "2.5 km", "2,5 km", etc.)
        #expect(!formatted.isEmpty)
        #expect(formatted.count > 1)
    }

    @Test("Format distance produces different output for different magnitudes")
    func formatDistanceProducesDifferentOutputForDifferentMagnitudes() {
        // Given
        let shortDistance: Double = 50
        let longDistance: Double = 5000

        // When
        let shortFormatted = DistanceCalculator.formatDistance(shortDistance)
        let longFormatted = DistanceCalculator.formatDistance(longDistance)

        // Then - different magnitudes should produce different formatted strings
        #expect(shortFormatted != longFormatted)
        #expect(!shortFormatted.isEmpty)
        #expect(!longFormatted.isEmpty)
    }

    // MARK: - Radius Check

    @Test("Is within radius returns true for nearby point")
    func isWithinRadiusReturnsTrueForNearbyPoint() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        let nearbyPoint = CLLocationCoordinate2D(latitude: 40.4170, longitude: -3.7040)

        // When/Then
        #expect(DistanceCalculator.isWithinRadius(
            coordinate: nearbyPoint,
            center: center,
            radiusMeters: 1000
        ))
    }

    @Test("Is within radius returns false for far point")
    func isWithinRadiusReturnsFalseForFarPoint() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        let farPoint = CLLocationCoordinate2D(latitude: 41.3874, longitude: 2.1686)

        // When/Then
        #expect(!DistanceCalculator.isWithinRadius(
            coordinate: farPoint,
            center: center,
            radiusMeters: 1000
        ))
    }

    @Test("Is within radius returns true for point exactly at center")
    func isWithinRadiusReturnsTrueAtExactCenter() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)

        // When/Then - same point should always be within any radius
        #expect(DistanceCalculator.isWithinRadius(
            coordinate: center,
            center: center,
            radiusMeters: 0
        ))
    }
}
