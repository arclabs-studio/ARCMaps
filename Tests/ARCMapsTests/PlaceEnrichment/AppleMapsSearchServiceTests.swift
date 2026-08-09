//
//  AppleMapsSearchServiceTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import MapKit
import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

struct AppleMapsSearchServiceTests {
    let mockCache: MockPlaceSearchCache
    let sut: AppleMapsSearchService

    init() async throws {
        mockCache = MockPlaceSearchCache()
        sut = AppleMapsSearchService(cache: mockCache)
    }

    // MARK: - Cache Tests

    @Test("Search places returns cached results when available") func searchPlacesReturnsCachedResults() async throws {
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

    @Test("Get place details throws service unavailable") func getPlaceDetailsThrowsServiceUnavailable() async {
        // Apple Maps doesn't support detailed place information
        await #expect(throws: PlaceEnrichmentError.self) {
            _ = try await sut.getPlaceDetails(placeId: "test-id")
        }
    }

    @Test("Get place details throws correct error type") func getPlaceDetailsThrowsCorrectErrorType() async {
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

    @Test("Get photo URL throws photo download failed") func getPhotoURLThrowsPhotoDownloadFailed() async {
        // Apple Maps doesn't support photo URLs
        await #expect(throws: PlaceEnrichmentError.self) {
            _ = try await sut.getPhotoURL(photoReference: "photo_ref", maxWidth: 400)
        }
    }

    @Test("Get photo URL throws correct error type") func getPhotoURLThrowsCorrectErrorType() async {
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
    func searchUsesFullTextQueryForNaturalLanguageSearch() {
        // Given
        let query = PlaceSearchQuery(name: "Coffee Shop",
                                     address: "Main Street",
                                     city: "Madrid")

        // Verify the full text query is constructed correctly
        #expect(query.fullTextQuery == "Coffee Shop, Main Street, Madrid")
    }

    @Test("Search with coordinate uses region for proximity search")
    func searchWithCoordinateUsesRegionForProximitySearch() {
        // Given
        let query = PlaceSearchQuery(name: "Restaurant",
                                     coordinate: (latitude: 40.4168, longitude: -3.7038),
                                     radiusMeters: 5000)

        // Verify query has coordinate
        #expect(query.coordinate?.latitude == 40.4168)
        #expect(query.coordinate?.longitude == -3.7038)
        #expect(query.radiusMeters == 5000)
    }

    // MARK: - Search Region

    @Test("The search region reaches the requested radius in every direction")
    func searchRegionReachesRequestedRadius() {
        // Given — `radiusMeters` is a radius, but `MKCoordinateRegion` takes a span.
        // Passing it through unconverted halved the window: a 5 km request searched
        // only 2.5 km, and candidates the caller would have accepted never came back.
        let radiusMeters = 5000

        // When
        let region = AppleMapsSearchService.searchRegion(latitude: Self.madridLatitude,
                                                         longitude: Self.madridLongitude,
                                                         radiusMeters: radiusMeters)

        // Then
        #expect(Self.isClose(Self.northEdgeDistance(of: region), to: Double(radiusMeters)))
        #expect(Self.isClose(Self.eastEdgeDistance(of: region), to: Double(radiusMeters)))
    }

    @Test("Doubling the requested radius doubles the region span") func searchRegionScalesLinearlyWithRadius() {
        // Given
        let small = AppleMapsSearchService.searchRegion(latitude: Self.madridLatitude,
                                                        longitude: Self.madridLongitude,
                                                        radiusMeters: 2500)
        let large = AppleMapsSearchService.searchRegion(latitude: Self.madridLatitude,
                                                        longitude: Self.madridLongitude,
                                                        radiusMeters: 5000)

        // Then
        #expect(Self.isClose(large.span.latitudeDelta, to: small.span.latitudeDelta * 2))
    }

    @Test("A query without a radius falls back to the documented default")
    func searchRegionUsesDefaultRadiusWhenMissing() {
        // When
        let region = AppleMapsSearchService.searchRegion(latitude: Self.madridLatitude,
                                                         longitude: Self.madridLongitude,
                                                         radiusMeters: nil)

        // Then
        #expect(Self.isClose(Self.northEdgeDistance(of: region),
                             to: Double(AppleMapsSearchService.defaultRadiusMeters)))
    }

    @Test("The region stays centred on the requested coordinate") func searchRegionKeepsRequestedCentre() {
        // When
        let region = AppleMapsSearchService.searchRegion(latitude: Self.madridLatitude,
                                                         longitude: Self.madridLongitude,
                                                         radiusMeters: 5000)

        // Then
        #expect(Self.isClose(region.center.latitude, to: Self.madridLatitude))
        #expect(Self.isClose(region.center.longitude, to: Self.madridLongitude))
    }
}

// MARK: - Region Helpers

extension AppleMapsSearchServiceTests {
    fileprivate static let madridLatitude = 40.4168
    fileprivate static let madridLongitude = -3.7038

    /// Metres from the centre to the northern edge of the region.
    fileprivate static func northEdgeDistance(of region: MKCoordinateRegion) -> Double {
        let centre = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        let edge = CLLocation(latitude: region.center.latitude + region.span.latitudeDelta / 2,
                              longitude: region.center.longitude)
        return edge.distance(from: centre)
    }

    /// Metres from the centre to the eastern edge of the region.
    fileprivate static func eastEdgeDistance(of region: MKCoordinateRegion) -> Double {
        let centre = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        let edge = CLLocation(latitude: region.center.latitude,
                              longitude: region.center.longitude + region.span.longitudeDelta / 2)
        return edge.distance(from: centre)
    }

    /// Tolerant comparison — MapKit's metre-to-degree conversion is approximate, so an
    /// exact match would make these tests brittle without making them stricter.
    fileprivate static func isClose(_ value: Double, to expected: Double, relativeTolerance: Double = 0.01) -> Bool {
        abs(value - expected) <= max(abs(expected) * relativeTolerance, 0.0001)
    }
}
