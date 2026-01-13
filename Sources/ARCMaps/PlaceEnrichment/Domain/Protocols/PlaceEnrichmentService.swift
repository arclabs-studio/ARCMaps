//
//  PlaceEnrichmentService.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation

/// A service that fetches place data from external providers.
///
/// `PlaceEnrichmentService` defines the interface for searching places and
/// retrieving detailed information. Implementations include ``GooglePlacesService``
/// and ``AppleMapsSearchService``.
///
/// ## Conformance Requirements
/// Implementations must be `Sendable` for safe concurrent usage.
///
/// ## Example
/// ```swift
/// let service: PlaceEnrichmentService = GooglePlacesService(networkClient: client)
///
/// // Search for places
/// let query = PlaceSearchQuery(name: "Coffee", city: "Seattle")
/// let results = try await service.searchPlaces(query: query)
///
/// // Get detailed info
/// if let first = results.first {
///     let details = try await service.getPlaceDetails(placeId: first.id)
/// }
/// ```
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
