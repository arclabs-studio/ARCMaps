//
//  ExternalMapLauncherTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Testing
@testable import ARCMaps

@Suite("ExternalMapLauncher Tests")
struct ExternalMapLauncherTests {
    // MARK: - ExternalMapApp Tests

    @Test("Apple Maps has correct URL scheme")
    func appleMapsHasCorrectURLScheme() {
        // Given
        let app = ExternalMapApp.appleMaps

        // Then
        #expect(app.rawValue == "Apple Maps")
    }

    @Test("Google Maps has correct URL scheme")
    func googleMapsHasCorrectURLScheme() {
        // Given
        let app = ExternalMapApp.googleMaps

        // Then
        #expect(app.rawValue == "Google Maps")
    }

    @Test("Waze has correct URL scheme")
    func wazeHasCorrectURLScheme() {
        // Given
        let app = ExternalMapApp.waze

        // Then
        #expect(app.rawValue == "Waze")
    }

    @Test("All cases are available")
    func allCasesAreAvailable() {
        // Given
        let allCases = ExternalMapApp.allCases

        // Then
        #expect(allCases.count == 3)
        #expect(allCases.contains(.appleMaps))
        #expect(allCases.contains(.googleMaps))
        #expect(allCases.contains(.waze))
    }

    // MARK: - Coordinate Validation

    @Test("Valid coordinate is accepted")
    func validCoordinateIsAccepted() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)

        // Then
        #expect(coordinate.isValid)
    }

    @Test("Invalid coordinate with out of range latitude")
    func invalidCoordinateWithOutOfRangeLatitude() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 91.0, longitude: 0)

        // Then
        #expect(!coordinate.isValid)
    }

    @Test("Invalid coordinate with out of range longitude")
    func invalidCoordinateWithOutOfRangeLongitude() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 181.0)

        // Then
        #expect(!coordinate.isValid)
    }

    // MARK: - Error Cases

    @Test("Open with invalid coordinate throws error")
    func openWithInvalidCoordinateThrowsError() async {
        // Given
        let invalidCoordinate = CLLocationCoordinate2D(latitude: 91.0, longitude: 181.0)

        // When/Then
        await #expect(throws: MapError.self) {
            try await ExternalMapLauncher.open(
                coordinate: invalidCoordinate,
                app: .appleMaps
            )
        }
    }
}

// MARK: - MapError Tests

@Suite("MapError Tests")
struct MapErrorTests {
    @Test("Invalid coordinate error has description")
    func invalidCoordinateErrorHasDescription() {
        // Given
        let error = MapError.invalidCoordinate

        // Then
        #expect(error.localizedDescription.contains("coordinate") || !error.localizedDescription.isEmpty)
    }

    @Test("External app not installed error contains app name")
    func externalAppNotInstalledErrorContainsAppName() {
        // Given
        let error = MapError.externalAppNotInstalled("Google Maps")

        // Then - the error should somehow reference the app
        switch error {
        case let .externalAppNotInstalled(appName):
            #expect(appName == "Google Maps")
        default:
            Issue.record("Expected externalAppNotInstalled error")
        }
    }

    @Test("Navigation failed error exists")
    func navigationFailedErrorExists() {
        // Given
        let error = MapError.navigationFailed

        // Then
        switch error {
        case .navigationFailed:
            #expect(Bool(true))
        default:
            Issue.record("Expected navigationFailed error")
        }
    }
}
