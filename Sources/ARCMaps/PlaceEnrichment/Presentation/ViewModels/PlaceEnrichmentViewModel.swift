import Foundation
import SwiftUI

/// ViewModel for place enrichment flow
@MainActor
public final class PlaceEnrichmentViewModel: ObservableObject {

    // MARK: - Published State

    @Published public var searchResults: [PlaceSearchResult] = []
    @Published public var selectedResult: PlaceSearchResult?
    @Published public var enrichedData: EnrichedPlaceData?
    @Published public var isSearching = false
    @Published public var isLoadingDetails = false
    @Published public var error: PlaceEnrichmentError?
    @Published public var selectedProvider: PlaceProvider = .google

    // MARK: - Dependencies

    private let googleService: PlaceEnrichmentService
    private let appleService: PlaceEnrichmentService
    private let logger: LoggerProtocol

    // MARK: - Initialization

    public init(
        googleService: PlaceEnrichmentService,
        appleService: PlaceEnrichmentService,
        logger: LoggerProtocol
    ) {
        self.googleService = googleService
        self.appleService = appleService
        self.logger = logger
    }

    // MARK: - Public Methods

    /// Search for places matching the query
    public func searchPlaces(query: PlaceSearchQuery) async {
        await logger.info("Searching places: \(query.fullTextQuery)")

        isSearching = true
        error = nil
        searchResults = []

        defer { isSearching = false }

        let service = currentService

        do {
            let results = try await service.searchPlaces(query: query)

            // Sort by match score
            searchResults = results.sorted { $0.matchScore > $1.matchScore }

            await logger.info("Found \(results.count) results from \(selectedProvider.displayName)")

            if results.isEmpty {
                error = .noResultsFound
            }

        } catch let enrichmentError as PlaceEnrichmentError {
            error = enrichmentError
            await logger.error("Search failed", error: enrichmentError)

            // Fallback to alternative provider
            await searchWithFallback(query: query)

        } catch {
            let enrichmentError = PlaceEnrichmentError.networkError(error.localizedDescription)
            self.error = enrichmentError
            await logger.error("Search failed", error: error)
        }
    }

    /// Select a search result and fetch full details
    public func selectResult(_ result: PlaceSearchResult) async {
        await logger.info("Selected result: \(result.name)")

        selectedResult = result
        isLoadingDetails = true
        error = nil

        defer { isLoadingDetails = false }

        let service = currentService

        do {
            enrichedData = try await service.getPlaceDetails(placeId: result.id)
            await logger.info("Loaded enriched data for: \(result.name)")

        } catch let enrichmentError as PlaceEnrichmentError {
            error = enrichmentError
            await logger.error("Failed to load details", error: enrichmentError)

        } catch {
            let enrichmentError = PlaceEnrichmentError.networkError(error.localizedDescription)
            self.error = enrichmentError
            await logger.error("Failed to load details", error: error)
        }
    }

    /// Get photo URL for display
    public func getPhotoURL(photoReference: String, maxWidth: Int = 400) async throws -> URL {
        try await currentService.getPhotoURL(photoReference: photoReference, maxWidth: maxWidth)
    }

    /// Change provider (Google <-> Apple)
    public func changeProvider(_ provider: PlaceProvider) {
        Task {
            await logger.info("Changing provider to: \(provider.displayName)")
        }
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

        await logger.info("Attempting fallback to \(fallbackProvider.displayName)")

        do {
            let results = try await fallbackService.searchPlaces(query: query)
            searchResults = results.sorted { $0.matchScore > $1.matchScore }
            selectedProvider = fallbackProvider

            await logger.info("Fallback successful: \(results.count) results")

            if results.isEmpty {
                error = .noResultsFound
            }

        } catch {
            await logger.error("Fallback also failed", error: error)
        }
    }
}
