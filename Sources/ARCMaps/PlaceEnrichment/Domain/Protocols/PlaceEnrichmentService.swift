import Foundation
import CoreLocation

/// Service for enriching places with external data
public protocol PlaceEnrichmentService: Sendable {
    /// Search for places matching the query
    /// - Parameter query: Search query with name, address, etc.
    /// - Returns: Array of search results
    /// - Throws: PlaceEnrichmentError if search fails
    func searchPlaces(query: PlaceSearchQuery) async throws -> [PlaceSearchResult]

    /// Get detailed information for a specific place
    /// - Parameter placeId: Unique identifier for the place
    /// - Returns: Enriched place data with photos, reviews, etc.
    /// - Throws: PlaceEnrichmentError if fetch fails
    func getPlaceDetails(placeId: String) async throws -> EnrichedPlaceData

    /// Get photo URL for a photo reference
    /// - Parameters:
    ///   - photoReference: Photo reference ID
    ///   - maxWidth: Maximum width in pixels
    /// - Returns: URL to download the photo
    /// - Throws: PlaceEnrichmentError if URL generation fails
    func getPhotoURL(photoReference: String, maxWidth: Int) async throws -> URL
}
