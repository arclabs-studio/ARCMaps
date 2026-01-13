import Foundation

/// Cache for place search results
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
