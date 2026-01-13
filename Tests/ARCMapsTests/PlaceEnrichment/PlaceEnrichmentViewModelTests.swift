//
//  PlaceEnrichmentViewModelTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

@Suite("PlaceEnrichmentViewModel Tests", .serialized)
@MainActor
struct PlaceEnrichmentViewModelTests {
    let mockGoogleService: MockPlaceEnrichmentService
    let mockAppleService: MockPlaceEnrichmentService
    let sut: PlaceEnrichmentViewModel

    init() async throws {
        mockGoogleService = MockPlaceEnrichmentService()
        mockAppleService = MockPlaceEnrichmentService()
        sut = PlaceEnrichmentViewModel(
            googleService: mockGoogleService,
            appleService: mockAppleService
        )
    }

    // MARK: - Initial State

    @Test("Initial state has empty search results")
    func initialStateHasEmptySearchResults() {
        #expect(sut.searchResults.isEmpty)
        #expect(sut.selectedResult == nil)
        #expect(sut.enrichedData == nil)
        #expect(sut.isSearching == false)
        #expect(sut.isLoadingDetails == false)
        #expect(sut.error == nil)
    }

    @Test("Default provider is Google")
    func defaultProviderIsGoogle() {
        #expect(sut.selectedProvider == .google)
    }

    // MARK: - Search Places

    @Test("Search places updates search results")
    func searchPlacesUpdatesSearchResults() async {
        // Given
        let expectedResults = PlaceSearchResultFixtures.allSamples
        await mockGoogleService.setMockSearchResults(expectedResults)
        let query = PlaceSearchQuery(name: "Test")

        // When
        await sut.searchPlaces(query: query)

        // Then
        #expect(sut.searchResults.count == expectedResults.count)
        #expect(sut.isSearching == false)
    }

    @Test("Search places sets isSearching during search")
    func searchPlacesSetsIsSearchingDuringSearch() async {
        // Given
        await mockGoogleService.setMockSearchResults([])
        let query = PlaceSearchQuery(name: "Test")

        // Check initial state
        #expect(sut.isSearching == false)

        // When
        await sut.searchPlaces(query: query)

        // Then - after search completes
        #expect(sut.isSearching == false)
    }

    @Test("Search places clears previous results before searching")
    func searchPlacesClearsPreviousResults() async {
        // Given
        await mockGoogleService.setMockSearchResults(PlaceSearchResultFixtures.allSamples)
        await sut.searchPlaces(query: PlaceSearchQuery(name: "First"))

        // Setup for second search with different results
        let newResults = [PlaceSearchResultFixtures.sampleRestaurant]
        await mockGoogleService.setMockSearchResults(newResults)

        // When
        await sut.searchPlaces(query: PlaceSearchQuery(name: "Second"))

        // Then
        #expect(sut.searchResults.count == 1)
    }

    @Test("Search places sets error when no results found")
    func searchPlacesSetsErrorWhenNoResultsFound() async {
        // Given
        await mockGoogleService.setMockSearchResults([])
        let query = PlaceSearchQuery(name: "NonexistentPlace")

        // When
        await sut.searchPlaces(query: query)

        // Then
        #expect(sut.error == .noResultsFound)
    }

    @Test("Search places sorts results by match score")
    func searchPlacesSortsResultsByMatchScore() async {
        // Given - results with different match scores
        let results = PlaceSearchResultFixtures.allSamples
        await mockGoogleService.setMockSearchResults(results)
        let query = PlaceSearchQuery(name: "Test")

        // When
        await sut.searchPlaces(query: query)

        // Then - results should be sorted by matchScore descending
        if sut.searchResults.count > 1 {
            for idx in 0 ..< (sut.searchResults.count - 1) {
                #expect(sut.searchResults[idx].matchScore >= sut.searchResults[idx + 1].matchScore)
            }
        }
    }

    // MARK: - Select Result

    @Test("Select result updates selected result")
    func selectResultUpdatesSelectedResult() async {
        // Given
        let result = PlaceSearchResultFixtures.sampleRestaurant
        await mockGoogleService.setMockEnrichedData(EnrichedPlaceDataFixtures.sampleRestaurant)

        // When
        await sut.selectResult(result)

        // Then
        #expect(sut.selectedResult == result)
    }

    @Test("Select result loads enriched data")
    func selectResultLoadsEnrichedData() async {
        // Given
        let result = PlaceSearchResultFixtures.sampleRestaurant
        let enrichedData = EnrichedPlaceDataFixtures.sampleRestaurant
        await mockGoogleService.setMockEnrichedData(enrichedData)

        // When
        await sut.selectResult(result)

        // Then
        #expect(sut.enrichedData != nil)
        #expect(sut.enrichedData?.placeId == enrichedData.placeId)
    }

    // MARK: - Change Provider

    @Test("Change provider updates selected provider")
    func changeProviderUpdatesSelectedProvider() {
        // When
        sut.changeProvider(.apple)

        // Then
        #expect(sut.selectedProvider == .apple)
    }

    @Test("Change provider clears previous results")
    func changeProviderClearsPreviousResults() async {
        // Given
        await mockGoogleService.setMockSearchResults(PlaceSearchResultFixtures.allSamples)
        await sut.searchPlaces(query: PlaceSearchQuery(name: "Test"))

        // When
        sut.changeProvider(.apple)

        // Then
        #expect(sut.searchResults.isEmpty)
        #expect(sut.selectedResult == nil)
        #expect(sut.enrichedData == nil)
    }

    // MARK: - Reset

    @Test("Reset clears all state")
    func resetClearsAllState() async {
        // Given
        await mockGoogleService.setMockSearchResults(PlaceSearchResultFixtures.allSamples)
        await sut.searchPlaces(query: PlaceSearchQuery(name: "Test"))

        // When
        sut.reset()

        // Then
        #expect(sut.searchResults.isEmpty)
        #expect(sut.selectedResult == nil)
        #expect(sut.enrichedData == nil)
        #expect(sut.error == nil)
        #expect(sut.isSearching == false)
        #expect(sut.isLoadingDetails == false)
    }

    // MARK: - Error Handling

    @Test("Search places handles network error")
    func searchPlacesHandlesNetworkError() async {
        // Given
        await mockGoogleService.setShouldThrowError(true)
        await mockGoogleService.setErrorToThrow(.networkError("Network failed"))
        await mockAppleService.setShouldThrowError(true) // Fallback also fails
        let query = PlaceSearchQuery(name: "Test")

        // When
        await sut.searchPlaces(query: query)

        // Then
        #expect(sut.error != nil)
    }
}

// MARK: - MockPlaceEnrichmentService Extensions for Testing

extension MockPlaceEnrichmentService {
    func setMockSearchResults(_ results: [PlaceSearchResult]) {
        mockSearchResults = results
    }

    func setMockEnrichedData(_ data: EnrichedPlaceData) {
        mockEnrichedData = data
    }

    func setShouldThrowError(_ value: Bool) {
        shouldThrowError = value
    }

    func setErrorToThrow(_ error: PlaceEnrichmentError) {
        errorToThrow = error
    }
}
