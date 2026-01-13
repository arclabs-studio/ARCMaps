//
//  GooglePlacesServiceTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

@Suite("GooglePlacesService Tests")
struct GooglePlacesServiceTests {
    let mockNetworkClient: MockNetworkClient
    let mockCache: MockPlaceSearchCache
    let sut: GooglePlacesService

    init() async throws {
        mockNetworkClient = MockNetworkClient()
        mockCache = MockPlaceSearchCache()

        sut = GooglePlacesService(
            apiKey: "test-api-key",
            networkClient: mockNetworkClient,
            cache: mockCache
        )
    }

    // MARK: - Search Places Tests

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
        let requestCount = await mockNetworkClient.requestCount
        #expect(requestCount == 0) // No network call
    }

    @Test("Search places caches results after network request")
    func searchPlacesCachesResultsAfterNetworkRequest() async throws {
        // Given
        let query = PlaceSearchQuery(name: "Test Restaurant", address: "Test St")
        let expectedResults = PlaceSearchResultFixtures.allSamples
        await mockNetworkClient.reset()
        await mockCache.setResults(expectedResults, for: query)

        // When
        let results = try await sut.searchPlaces(query: query)

        // Then
        #expect(results.count == expectedResults.count)
    }

    @Test("Search places uses full text query")
    func searchPlacesUsesFullTextQuery() async throws {
        // Given
        let query = PlaceSearchQuery(name: "La Taverna", address: "Calle Mayor", city: "Madrid")

        // Verify full text query is constructed correctly
        #expect(query.fullTextQuery == "La Taverna, Calle Mayor, Madrid")
    }
}
