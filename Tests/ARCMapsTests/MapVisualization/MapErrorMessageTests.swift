//
//  MapErrorMessageTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 16/09/2026.
//

import Foundation
import Testing
@testable import ARCMaps

/// FVRS-324 — `MapError` carries a `LocalizedStringResource` so the host app's
/// String Catalog can translate it. The package ships no catalog of its own, so
/// resolving here must fall back to the English default: that fallback is what
/// guarantees the change cannot regress an app that has not added the keys yet.
struct MapErrorMessageTests {
    @Test("Each case resolves to its English default",
          arguments: [(MapError.locationPermissionDenied,
                       "Location permission denied. Please enable in Settings"),
                      (MapError.locationUnavailable, "Unable to determine your location"),
                      (MapError.invalidCoordinate, "Invalid coordinate provided"),
                      (MapError.noPlacesFound, "No places found to display"),
                      (MapError.externalAppNotInstalled("Google Maps"), "Google Maps is not installed"),
                      (MapError.navigationFailed, "Failed to open navigation")])
    func messageResolvesToEnglishDefault(error: MapError, expected: String) {
        // Then
        #expect(String(localized: error.message) == expected)
    }

    @Test("errorDescription still matches the resolved message") func errorDescriptionMatchesMessage() {
        // Given
        let sut = MapError.locationPermissionDenied

        // Then — system contexts that read `localizedDescription` keep working
        #expect(sut.errorDescription == "Location permission denied. Please enable in Settings")
        #expect(sut.localizedDescription == sut.errorDescription)
    }
}
