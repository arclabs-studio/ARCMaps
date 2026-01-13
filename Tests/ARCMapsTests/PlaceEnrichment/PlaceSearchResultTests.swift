//
//  PlaceSearchResultTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

@Suite("PlaceSearchResult Tests")
struct PlaceSearchResultTests {
    // MARK: - Match Score Calculation

    @Test("Match score is 1.0 for complete result")
    func matchScoreIsOneForCompleteResult() {
        // Given
        let result = PlaceSearchResultFixtures.sampleRestaurant
        // Has: rating (0.3) + userRatingsTotal > 0 (0.2) + photos (0.3) + address (0.2) = 1.0

        // When/Then
        #expect(result.matchScore == 1.0)
    }

    @Test("Match score is 0 for minimal result")
    func matchScoreIsZeroForMinimalResult() {
        // Given
        let result = PlaceSearchResult(
            id: "test",
            provider: .google,
            name: "Test",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
        )

        // When/Then
        #expect(result.matchScore == 0.0)
    }

    @Test("Match score includes rating contribution")
    func matchScoreIncludesRatingContribution() {
        // Given
        let result = PlaceSearchResult(
            id: "test",
            provider: .google,
            name: "Test",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            rating: 4.5
        )

        // When/Then
        #expect(result.matchScore >= 0.3)
    }

    @Test("Match score includes photos contribution")
    func matchScoreIncludesPhotosContribution() {
        // Given
        let result = PlaceSearchResult(
            id: "test",
            provider: .google,
            name: "Test",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            photoReferences: ["photo1"]
        )

        // When/Then
        #expect(result.matchScore >= 0.3)
    }

    @Test("Match score includes address contribution")
    func matchScoreIncludesAddressContribution() {
        // Given
        let result = PlaceSearchResult(
            id: "test",
            provider: .google,
            name: "Test",
            address: "123 Main St",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
        )

        // When/Then
        #expect(result.matchScore >= 0.2)
    }

    // MARK: - Equality

    @Test("Results with same ID and provider are equal")
    func resultsWithSameIdAndProviderAreEqual() {
        // Given
        let result1 = PlaceSearchResult(
            id: "test",
            provider: .google,
            name: "Test",
            coordinate: CLLocationCoordinate2D(latitude: 40.0, longitude: -3.0)
        )
        let result2 = PlaceSearchResult(
            id: "test",
            provider: .google,
            name: "Test",
            coordinate: CLLocationCoordinate2D(latitude: 40.0, longitude: -3.0)
        )

        // When/Then
        #expect(result1 == result2)
    }

    @Test("Results with different IDs are not equal")
    func resultsWithDifferentIdsAreNotEqual() {
        // Given
        let result1 = PlaceSearchResult(
            id: "test1",
            provider: .google,
            name: "Test",
            coordinate: CLLocationCoordinate2D(latitude: 40.0, longitude: -3.0)
        )
        let result2 = PlaceSearchResult(
            id: "test2",
            provider: .google,
            name: "Test",
            coordinate: CLLocationCoordinate2D(latitude: 40.0, longitude: -3.0)
        )

        // When/Then
        #expect(result1 != result2)
    }

    // MARK: - Provider

    @Test("Google provider is correctly assigned")
    func googleProviderIsCorrectlyAssigned() {
        // Given
        let result = PlaceSearchResultFixtures.sampleRestaurant

        // When/Then
        #expect(result.provider == .google)
    }

    @Test("Apple provider is correctly assigned")
    func appleProviderIsCorrectlyAssigned() {
        // Given
        let result = PlaceSearchResultFixtures.sampleBar

        // When/Then
        #expect(result.provider == .apple)
    }

    // MARK: - Identifiable

    @Test("ID is used for identification")
    func idIsUsedForIdentification() {
        // Given
        let result = PlaceSearchResult(
            id: "unique-id-123",
            provider: .google,
            name: "Test",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
        )

        // When/Then
        #expect(result.id == "unique-id-123")
    }
}
