//
//  PlaceSearchCache.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// A cache for storing and retrieving place search results.
///
/// `PlaceSearchCache` provides an abstraction for caching search results to
/// reduce API calls and improve responsiveness. The default implementation
/// is ``InMemoryPlaceCache``.
///
/// ## Conformance Requirements
/// Implementations must be `Sendable` for safe concurrent usage.
///
/// ## Example
/// ```swift
/// let cache: PlaceSearchCache = InMemoryPlaceCache()
///
/// // Check cache before making API call
/// if let cached = await cache.getResults(for: query) {
///     return cached
/// }
///
/// // Fetch and cache results
/// let results = try await service.searchPlaces(query: query)
/// await cache.setResults(results, for: query)
/// ```
public protocol PlaceSearchCache: Sendable {
    /// Get cached search results
    /// - Parameter query: Search query
    /// - Returns: Cached results if available
    func getResults(for query: PlaceSearchQuery) async -> [PlaceSearchResult]?

    /// Cache search results
    /// - Parameters:
    ///   - results: Results to cache
    ///   - query: Search query
    func setResults(_ results: [PlaceSearchResult], for query: PlaceSearchQuery) async

    /// Clear all cached results
    func clearCache() async
}
