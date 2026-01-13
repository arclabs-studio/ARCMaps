//
//  PlaceEnrichmentViewModel.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import ARCLogger
import Foundation
import Observation
import SwiftUI

/// ViewModel for place enrichment flow
@Observable
@MainActor
public final class PlaceEnrichmentViewModel {
    // MARK: - State

    public var searchResults: [PlaceSearchResult] = []
    public var selectedResult: PlaceSearchResult?
    public var enrichedData: EnrichedPlaceData?
    public var isSearching = false
    public var isLoadingDetails = false
    public var error: PlaceEnrichmentError?
    public var selectedProvider: PlaceProvider = .google

    // MARK: - Dependencies

    private let googleService: PlaceEnrichmentService
    private let appleService: PlaceEnrichmentService
    private let logger = ARCLogger(category: "PlaceEnrichmentViewModel")

    // MARK: - Initialization

    public init(
        googleService: PlaceEnrichmentService,
        appleService: PlaceEnrichmentService
    ) {
        self.googleService = googleService
        self.appleService = appleService
    }

    // MARK: - Public Methods

    /// Search for places matching the query
    public func searchPlaces(query: PlaceSearchQuery) async {
        logger.info("Searching places: \(query.fullTextQuery)")

        isSearching = true
        error = nil
        searchResults = []

        defer { isSearching = false }

        let service = currentService

        do {
            let results = try await service.searchPlaces(query: query)

            // Sort by match score
            searchResults = results.sorted { $0.matchScore > $1.matchScore }

            logger.info("Found \(results.count) results from \(selectedProvider.displayName)")

            if results.isEmpty {
                error = .noResultsFound
            }
        } catch let enrichmentError as PlaceEnrichmentError {
            error = enrichmentError
            logger.error("Search failed: \(enrichmentError)")

            // Fallback to alternative provider
            await searchWithFallback(query: query)
        } catch {
            let enrichmentError = PlaceEnrichmentError.networkError(error.localizedDescription)
            self.error = enrichmentError
            logger.error("Search failed: \(error.localizedDescription)")
        }
    }

    /// Select a search result and fetch full details
    public func selectResult(_ result: PlaceSearchResult) async {
        logger.info("Selected result: \(result.name)")

        selectedResult = result
        isLoadingDetails = true
        error = nil

        defer { isLoadingDetails = false }

        let service = currentService

        do {
            enrichedData = try await service.getPlaceDetails(placeId: result.id)
            logger.info("Loaded enriched data for: \(result.name)")
        } catch let enrichmentError as PlaceEnrichmentError {
            error = enrichmentError
            logger.error("Failed to load details: \(enrichmentError)")
        } catch {
            let enrichmentError = PlaceEnrichmentError.networkError(error.localizedDescription)
            self.error = enrichmentError
            logger.error("Failed to load details: \(error.localizedDescription)")
        }
    }

    /// Get photo URL for display
    public func getPhotoURL(photoReference: String, maxWidth: Int = 400) async throws -> URL {
        try await currentService.getPhotoURL(photoReference: photoReference, maxWidth: maxWidth)
    }

    /// Change provider (Google <-> Apple)
    public func changeProvider(_ provider: PlaceProvider) {
        logger.info("Changing provider to: \(provider.displayName)")
        selectedProvider = provider

        // Clear current results
        searchResults = []
        selectedResult = nil
        enrichedData = nil
        error = nil
    }

    /// Reset state
    public func reset() {
        searchResults = []
        selectedResult = nil
        enrichedData = nil
        error = nil
        isSearching = false
        isLoadingDetails = false
    }

    // MARK: - Private Helpers

    private var currentService: PlaceEnrichmentService {
        selectedProvider == .google ? googleService : appleService
    }

    private func searchWithFallback(query: PlaceSearchQuery) async {
        let fallbackProvider: PlaceProvider = selectedProvider == .google ? .apple : .google
        let fallbackService = fallbackProvider == .google ? googleService : appleService

        logger.info("Attempting fallback to \(fallbackProvider.displayName)")

        do {
            let results = try await fallbackService.searchPlaces(query: query)
            searchResults = results.sorted { $0.matchScore > $1.matchScore }
            selectedProvider = fallbackProvider

            logger.info("Fallback successful: \(results.count) results")

            if results.isEmpty {
                error = .noResultsFound
            }
        } catch {
            logger.error("Fallback also failed: \(error.localizedDescription)")
        }
    }
}
