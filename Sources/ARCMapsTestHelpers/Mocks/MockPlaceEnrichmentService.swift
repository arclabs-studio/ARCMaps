//
//  MockPlaceEnrichmentService.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation
@testable import ARCMaps

public actor MockPlaceEnrichmentService: PlaceEnrichmentService {
    public var mockSearchResults: [PlaceSearchResult] = []
    public var mockEnrichedData: EnrichedPlaceData?
    public var mockPhotoURL: URL?
    public var shouldThrowError = false
    public var errorToThrow: PlaceEnrichmentError = .invalidQuery

    public private(set) var searchPlacesCalled = false
    public private(set) var getPlaceDetailsCalled = false
    public private(set) var getPhotoURLCalled = false
    public private(set) var lastSearchQuery: PlaceSearchQuery?

    public init() {}

    public func searchPlaces(query: PlaceSearchQuery) async throws -> [PlaceSearchResult] {
        searchPlacesCalled = true
        lastSearchQuery = query

        if shouldThrowError {
            throw errorToThrow
        }

        return mockSearchResults
    }

    public func getPlaceDetails(placeId _: String) async throws -> EnrichedPlaceData {
        getPlaceDetailsCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        guard let data = mockEnrichedData else {
            throw PlaceEnrichmentError.noResultsFound
        }

        return data
    }

    public func getPhotoURL(photoReference: String, maxWidth _: Int) async throws -> URL {
        getPhotoURLCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        guard let url = mockPhotoURL ?? URL(string: "https://example.com/photo.jpg") else {
            throw PlaceEnrichmentError.photoDownloadFailed(photoReference)
        }

        return url
    }

    public func reset() {
        searchPlacesCalled = false
        getPlaceDetailsCalled = false
        getPhotoURLCalled = false
        lastSearchQuery = nil
        shouldThrowError = false
    }
}
