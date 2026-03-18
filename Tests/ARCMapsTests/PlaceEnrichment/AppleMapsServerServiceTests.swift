//
//  AppleMapsServerServiceTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 18/03/2026.
//

import CoreLocation
import Foundation
import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

// MARK: - MockNetworkClient helpers (actor-isolated mutation)

extension MockNetworkClient {
    func setMockResponse(_ response: Any) {
        mockResponse = response
    }

    func setShouldThrowError(_ value: Bool) {
        shouldThrowError = value
    }
}

@Suite("AppleMapsServerService Tests", .serialized) struct AppleMapsServerServiceTests {
    let mockNetworkClient: MockNetworkClient
    let mockCache: MockPlaceSearchCache
    let mockTokenProvider: MockAppleMapsTokenProvider
    let sut: AppleMapsServerService

    init() async throws {
        mockNetworkClient = MockNetworkClient()
        mockCache = MockPlaceSearchCache()
        mockTokenProvider = MockAppleMapsTokenProvider()
        sut = AppleMapsServerService(tokenProvider: mockTokenProvider,
                                     networkClient: mockNetworkClient,
                                     cache: mockCache)
    }

    // MARK: - Search Places

    @Test("Search places returns mapped results") func searchPlacesReturnsMappedResults() async throws {
        // Given
        let response =
            AppleMapsServerSearchResponse(results: [AppleMapsServerSearchResult(place: AppleMapsServerPlace(placeId: "server_place_1",
                                                                                                            name: "La Taverna Server",
                                                                                                            formattedAddressLines: ["Calle Mayor 15",
                                                                                                                                    "Madrid"],
                                                                                                            coordinate: AppleMapsServerCoordinate(latitude: 40.4168,
                                                                                                                                                  longitude: -3.7038),
                                                                                                            pointOfInterestCategory: "restaurant")),
                                                    AppleMapsServerSearchResult(place: AppleMapsServerPlace(placeId: "server_place_2",
                                                                                                            name: "El Café",
                                                                                                            formattedAddressLines: ["Gran Vía 20",
                                                                                                                                    "Madrid"],
                                                                                                            coordinate: AppleMapsServerCoordinate(latitude: 40.4200,
                                                                                                                                                  longitude: -3.7050),
                                                                                                            pointOfInterestCategory: "cafe"))])
        await mockNetworkClient.setMockResponse(response)
        let query = PlaceSearchQuery(name: "restaurant Madrid")

        // When
        let results = try await sut.searchPlaces(query: query)

        // Then
        #expect(results.count == 2)
        #expect(results[0].id == "server_place_1")
        #expect(results[0].provider == .appleServer)
        #expect(results[0].name == "La Taverna Server")
        #expect(results[0].address == "Calle Mayor 15, Madrid")
        #expect(results[0].types == ["restaurant"])
        #expect(results[0].rating == nil)
    }

    @Test("Search places filters results with missing required fields")
    func searchPlacesFiltersInvalidResults() async throws {
        // Given - one result with missing placeId
        let response =
            AppleMapsServerSearchResponse(results: [AppleMapsServerSearchResult(place: AppleMapsServerPlace(placeId: nil,
                                                                                                            name: "Missing ID Place",
                                                                                                            formattedAddressLines: nil,
                                                                                                            coordinate: AppleMapsServerCoordinate(latitude: 40.0,
                                                                                                                                                  longitude: -3.0),
                                                                                                            pointOfInterestCategory: nil)),
                                                    AppleMapsServerSearchResult(place: AppleMapsServerPlace(placeId: "valid_place",
                                                                                                            name: "Valid Place",
                                                                                                            formattedAddressLines: ["Address"],
                                                                                                            coordinate: AppleMapsServerCoordinate(latitude: 40.0,
                                                                                                                                                  longitude: -3.0),
                                                                                                            pointOfInterestCategory: "restaurant"))])
        await mockNetworkClient.setMockResponse(response)

        // When
        let results = try await sut.searchPlaces(query: PlaceSearchQuery(name: "test"))

        // Then - only the valid result is returned
        #expect(results.count == 1)
        #expect(results[0].id == "valid_place")
    }

    @Test("Search places returns cached results when available") func searchPlacesReturnsCachedResults() async throws {
        // Given
        let cachedResults = [PlaceSearchResultFixtures.sampleRestaurant]
        let query = PlaceSearchQuery(name: "cached query")
        await mockCache.setResults(cachedResults, for: query)

        // When
        let results = try await sut.searchPlaces(query: query)

        // Then
        #expect(results.count == cachedResults.count)
        #expect(await mockNetworkClient.requestCount == 0)
    }

    @Test("Search places caches results after fetch") func searchPlacesCachesResultsAfterFetch() async throws {
        // Given
        let response =
            AppleMapsServerSearchResponse(results: [AppleMapsServerSearchResult(place: AppleMapsServerPlace(placeId: "cache_test",
                                                                                                            name: "Cache Test Place",
                                                                                                            formattedAddressLines: ["Address"],
                                                                                                            coordinate: AppleMapsServerCoordinate(latitude: 40.0,
                                                                                                                                                  longitude: -3.0),
                                                                                                            pointOfInterestCategory: "restaurant"))])
        await mockNetworkClient.setMockResponse(response)
        let query = PlaceSearchQuery(name: "cache test")

        // When
        _ = try await sut.searchPlaces(query: query)

        // Then
        let cached = await mockCache.getResults(for: query)
        #expect(cached != nil)
        #expect(cached?.count == 1)
    }

    @Test("Search places throws network error on failure") func searchPlacesThrowsNetworkError() async throws {
        // Given
        await mockNetworkClient.setShouldThrowError(true)
        let query = PlaceSearchQuery(name: "failing query")

        // When/Then
        await #expect(throws: PlaceEnrichmentError.self) {
            _ = try await sut.searchPlaces(query: query)
        }
    }

    @Test("Search places includes user location in request") func searchPlacesIncludesUserLocation() async throws {
        // Given
        let response = AppleMapsServerSearchResponse(results: [])
        await mockNetworkClient.setMockResponse(response)
        let query = PlaceSearchQuery(name: "nearby restaurant",
                                     coordinate: (latitude: 40.4168, longitude: -3.7038))

        // When
        _ = try await sut.searchPlaces(query: query)

        // Then
        let lastURL = await mockNetworkClient.lastURL
        #expect(lastURL?.query?.contains("userLocation") == true)
    }

    // MARK: - Get Place Details

    @Test("Get place details returns enriched data") func getPlaceDetailsReturnsEnrichedData() async throws {
        // Given
        let placeResponse = AppleMapsServerPlaceResponse(id: "server_detail_1",
                                                         name: "Detailed Restaurant",
                                                         formattedAddressLines: ["Calle Mayor 15", "Madrid, Spain"],
                                                         coordinate: AppleMapsServerCoordinate(latitude: 40.4168,
                                                                                               longitude: -3.7038),
                                                         pointOfInterestCategory: "restaurant",
                                                         url: "https://example.com",
                                                         telephone: "+34 91 000 0000")
        await mockNetworkClient.setMockResponse(placeResponse)

        // When
        let details = try await sut.getPlaceDetails(placeId: "server_detail_1")

        // Then
        #expect(details.placeId == "server_detail_1")
        #expect(details.provider == .appleServer)
        #expect(details.name == "Detailed Restaurant")
        #expect(details.formattedAddress == "Calle Mayor 15, Madrid, Spain")
        #expect(details.phoneNumber == "+34 91 000 0000")
        #expect(details.rating == nil)
        #expect(details.reviews.isEmpty)
    }

    @Test("Get place details throws on invalid response") func getPlaceDetailsThrowsOnInvalidResponse() async throws {
        // Given - response with missing name and coordinate
        await mockNetworkClient.setShouldThrowError(true)

        // When/Then
        await #expect(throws: PlaceEnrichmentError.self) {
            _ = try await sut.getPlaceDetails(placeId: "bad_place")
        }
    }

    // MARK: - Get Photo URL

    @Test("Get photo URL throws photoDownloadFailed") func getPhotoURLThrowsPhotoDownloadFailed() async throws {
        // When/Then
        await #expect(throws: PlaceEnrichmentError.self) {
            _ = try await sut.getPhotoURL(photoReference: "some_ref", maxWidth: 400)
        }
    }
}
