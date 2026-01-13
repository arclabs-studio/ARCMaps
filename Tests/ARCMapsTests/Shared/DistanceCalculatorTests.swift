import XCTest
import CoreLocation
@testable import ARCMaps

final class DistanceCalculatorTests: XCTestCase {

    func testDistanceBetweenCoordinates() {
        // Given
        let madrid = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        let barcelona = CLLocationCoordinate2D(latitude: 41.3874, longitude: 2.1686)

        // When
        let distance = DistanceCalculator.distance(from: madrid, to: barcelona)

        // Then
        XCTAssertGreaterThan(distance, 0)
        XCTAssertGreaterThan(distance, 500_000) // At least 500km
    }

    func testFormatDistance_Meters() {
        // Given
        let meters: Double = 150

        // When
        let formatted = DistanceCalculator.formatDistance(meters)

        // Then
        XCTAssertTrue(formatted.contains("m"))
    }

    func testFormatDistance_Kilometers() {
        // Given
        let meters: Double = 2500

        // When
        let formatted = DistanceCalculator.formatDistance(meters)

        // Then
        XCTAssertTrue(formatted.contains("km"))
    }

    func testIsWithinRadius() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        let nearbyPoint = CLLocationCoordinate2D(latitude: 40.4170, longitude: -3.7040)
        let farPoint = CLLocationCoordinate2D(latitude: 41.3874, longitude: 2.1686)

        // When/Then
        XCTAssertTrue(DistanceCalculator.isWithinRadius(
            coordinate: nearbyPoint,
            center: center,
            radiusMeters: 1000
        ))

        XCTAssertFalse(DistanceCalculator.isWithinRadius(
            coordinate: farPoint,
            center: center,
            radiusMeters: 1000
        ))
    }
}
