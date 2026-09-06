//
//  MockPlaceCompletionService.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 06/09/2026.
//

import Foundation
@testable import ARCMaps

public actor MockPlaceCompletionService: PlaceCompleting {
    public var mockCompletions: [PlaceCompletion] = []
    public var mockResolvedPlace: PlaceSearchResult?
    public var shouldThrowError = false
    public var errorToThrow: PlaceEnrichmentError = .noResultsFound

    public private(set) var completionsCalled = false
    public private(set) var resolveCalled = false
    public private(set) var lastFragment: String?
    public private(set) var lastRegion: MapRegion?
    public private(set) var lastResolvedCompletion: PlaceCompletion?

    public init() {}

    public func completions(for fragment: String, near region: MapRegion?) async -> [PlaceCompletion] {
        completionsCalled = true
        lastFragment = fragment
        lastRegion = region

        return mockCompletions
    }

    public func resolve(_ completion: PlaceCompletion) async throws -> PlaceSearchResult? {
        resolveCalled = true
        lastResolvedCompletion = completion

        if shouldThrowError {
            throw errorToThrow
        }

        return mockResolvedPlace
    }

    public func reset() {
        completionsCalled = false
        resolveCalled = false
        lastFragment = nil
        lastRegion = nil
        lastResolvedCompletion = nil
        shouldThrowError = false
    }
}
