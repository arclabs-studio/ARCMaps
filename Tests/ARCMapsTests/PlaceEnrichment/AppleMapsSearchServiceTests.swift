//
//  AppleMapsSearchServiceTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

@Suite("AppleMapsSearchService Tests")
struct AppleMapsSearchServiceTests {
    let mockCache: MockPlaceSearchCache
    let sut: AppleMapsSearchService

    init() async throws {
        mockCache = MockPlaceSearchCache()
        sut = AppleMapsSearchService(cache: mockCache)
    }

    // MARK: - Cache Tests

    @Test("Search places returns cached results when available")
    func searchPlacesReturnsCachedResults() async throws {
        // Given
        let query = PlaceSearchQuery(name: "Test Restaurant")
        let cachedResults = PlaceSearchResultFixtures.allSamples
        await mockCache.setResults(cachedResults, for: query)

        // When
        let results = try await sut.searchPlaces(query: query)

        // Then
        #expect(results == cachedResults)
    }

    @Test("Search places with cache hit does not make network request")
    func searchPlacesWithCacheHitDoesNotMakeNetworkRequest() async throws {
        // Given
        let query = PlaceSearchQuery(name: "Cached Place")
        let cachedResults = [PlaceSearchResultFixtures.sampleRestaurant]
        await mockCache.setResults(cachedResults, for: query)

        // When
        let results = try await sut.searchPlaces(query: query)

        // Then
        #expect(results.count == 1)
        #expect(results.first?.name == "La Taverna")
    }

    // MARK: - Get Place Details

    @Test("Get place details throws service unavailable")
    func getPlaceDetailsThrowsServiceUnavailable() async {
        // Apple Maps doesn't support detailed place information
        await #expect(throws: PlaceEnrichmentError.self) {
            _ = try await sut.getPlaceDetails(placeId: "test-id")
        }
    }

    @Test("Get place details throws correct error type")
    func getPlaceDetailsThrowsCorrectErrorType() async {
        // When/Then
        do {
            _ = try await sut.getPlaceDetails(placeId: "test-id")
            Issue.record("Expected error to be thrown")
        } catch let error as PlaceEnrichmentError {
            if case .serviceUnavailable(.apple) = error {
                #expect(Bool(true))
            } else {
                Issue.record("Expected serviceUnavailable(.apple) error, got \(error)")
            }
        } catch {
            Issue.record("Expected PlaceEnrichmentError, got \(error)")
        }
    }

    // MARK: - Get Photo URL

    @Test("Get photo URL throws photo download failed")
    func getPhotoURLThrowsPhotoDownloadFailed() async {
        // Apple Maps doesn't support photo URLs
        await #expect(throws: PlaceEnrichmentError.self) {
            _ = try await sut.getPhotoURL(photoReference: "photo_ref", maxWidth: 400)
        }
    }

    @Test("Get photo URL throws correct error type")
    func getPhotoURLThrowsCorrectErrorType() async {
        // When/Then
        do {
            _ = try await sut.getPhotoURL(photoReference: "test_photo", maxWidth: 400)
            Issue.record("Expected error to be thrown")
        } catch let error as PlaceEnrichmentError {
            if case let .photoDownloadFailed(ref) = error {
                #expect(ref == "test_photo")
            } else {
                Issue.record("Expected photoDownloadFailed error, got \(error)")
            }
        } catch {
            Issue.record("Expected PlaceEnrichmentError, got \(error)")
        }
    }

    // MARK: - Query Handling

    @Test("Search uses full text query for natural language search")
    func searchUsesFullTextQueryForNaturalLanguageSearch() async throws {
        // Given
        let query = PlaceSearchQuery(
            name: "Coffee Shop",
            address: "Main Street",
            city: "Madrid"
        )

        // Verify the full text query is constructed correctly
        #expect(query.fullTextQuery == "Coffee Shop, Main Street, Madrid")
    }

    @Test("Search with coordinate uses region for proximity search")
    func searchWithCoordinateUsesRegionForProximitySearch() async throws {
        // Given
        let query = PlaceSearchQuery(
            name: "Restaurant",
            coordinate: (latitude: 40.4168, longitude: -3.7038),
            radiusMeters: 5000
        )

        // Verify query has coordinate
        #expect(query.coordinate?.latitude == 40.4168)
        #expect(query.coordinate?.longitude == -3.7038)
        #expect(query.radiusMeters == 5000)
    }
}
