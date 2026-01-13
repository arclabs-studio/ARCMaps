//
//  InMemoryPlaceCacheTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

@Suite("InMemoryPlaceCache Tests")
struct InMemoryPlaceCacheTests {
    // MARK: - Basic Cache Operations

    @Test("Get results returns nil for empty cache")
    func getResultsReturnsNilForEmptyCache() async {
        // Given
        let sut = InMemoryPlaceCache()
        let query = PlaceSearchQuery(name: "Test")

        // When
        let results = await sut.getResults(for: query)

        // Then
        #expect(results == nil)
    }

    @Test("Set and get results works correctly")
    func setAndGetResultsWorksCorrectly() async {
        // Given
        let sut = InMemoryPlaceCache()
        let query = PlaceSearchQuery(name: "Test Restaurant")
        let expectedResults = PlaceSearchResultFixtures.allSamples

        // When
        await sut.setResults(expectedResults, for: query)
        let results = await sut.getResults(for: query)

        // Then
        #expect(results == expectedResults)
    }

    @Test("Different queries return different cached results")
    func differentQueriesReturnDifferentResults() async {
        // Given
        let sut = InMemoryPlaceCache()
        let query1 = PlaceSearchQuery(name: "Restaurant A")
        let query2 = PlaceSearchQuery(name: "Restaurant B")
        let results1 = [PlaceSearchResultFixtures.sampleRestaurant]
        let results2 = [PlaceSearchResultFixtures.sampleCafe]

        // When
        await sut.setResults(results1, for: query1)
        await sut.setResults(results2, for: query2)

        let retrieved1 = await sut.getResults(for: query1)
        let retrieved2 = await sut.getResults(for: query2)

        // Then
        #expect(retrieved1 == results1)
        #expect(retrieved2 == results2)
    }

    // MARK: - Cache Clearing

    @Test("Clear cache removes all entries")
    func clearCacheRemovesAllEntries() async {
        // Given
        let sut = InMemoryPlaceCache()
        let query = PlaceSearchQuery(name: "Test")
        await sut.setResults(PlaceSearchResultFixtures.allSamples, for: query)

        // When
        await sut.clearCache()
        let results = await sut.getResults(for: query)

        // Then
        #expect(results == nil)
    }

    // MARK: - Cache Expiration

    @Test("Expired entries are removed on access")
    func expiredEntriesAreRemovedOnAccess() async throws {
        // Given - cache with 1 second expiration
        let sut = InMemoryPlaceCache(maxCacheSize: 100, expirationInterval: 0.1)
        let query = PlaceSearchQuery(name: "Test")
        await sut.setResults(PlaceSearchResultFixtures.allSamples, for: query)

        // When - wait for expiration
        try await Task.sleep(for: .milliseconds(150))
        let results = await sut.getResults(for: query)

        // Then
        #expect(results == nil)
    }

    @Test("Non-expired entries are returned")
    func nonExpiredEntriesAreReturned() async {
        // Given - cache with long expiration
        let sut = InMemoryPlaceCache(maxCacheSize: 100, expirationInterval: 3600)
        let query = PlaceSearchQuery(name: "Test")
        let expectedResults = PlaceSearchResultFixtures.allSamples

        // When
        await sut.setResults(expectedResults, for: query)
        let results = await sut.getResults(for: query)

        // Then
        #expect(results == expectedResults)
    }

    // MARK: - Cache Size Limits

    @Test("Cache evicts oldest entry when full")
    func cacheEvictsOldestEntryWhenFull() async throws {
        // Given - small cache with 2 entries max
        let sut = InMemoryPlaceCache(maxCacheSize: 2, expirationInterval: 3600)

        let query1 = PlaceSearchQuery(name: "First")
        let query2 = PlaceSearchQuery(name: "Second")
        let query3 = PlaceSearchQuery(name: "Third")

        // When - add 3 entries to a size-2 cache
        await sut.setResults([PlaceSearchResultFixtures.sampleRestaurant], for: query1)
        try await Task.sleep(for: .milliseconds(10)) // Ensure different timestamps
        await sut.setResults([PlaceSearchResultFixtures.sampleCafe], for: query2)
        try await Task.sleep(for: .milliseconds(10))
        await sut.setResults([PlaceSearchResultFixtures.sampleBar], for: query3)

        // Then - oldest entry (query1) should be evicted
        let results1 = await sut.getResults(for: query1)
        let results2 = await sut.getResults(for: query2)
        let results3 = await sut.getResults(for: query3)

        #expect(results1 == nil) // Evicted
        #expect(results2 != nil)
        #expect(results3 != nil)
    }
}
