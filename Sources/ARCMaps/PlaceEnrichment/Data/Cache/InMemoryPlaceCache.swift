//
//  InMemoryPlaceCache.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// In-memory cache for place search results
public actor InMemoryPlaceCache: PlaceSearchCache {
    private var cache: [PlaceSearchQuery: CachedResults] = [:]
    private let maxCacheSize: Int
    private let expirationInterval: TimeInterval

    struct CachedResults {
        let results: [PlaceSearchResult]
        let timestamp: Date
    }

    public init(maxCacheSize: Int = 100, expirationInterval: TimeInterval = 3600) {
        self.maxCacheSize = maxCacheSize
        self.expirationInterval = expirationInterval
    }

    public func getResults(for query: PlaceSearchQuery) async -> [PlaceSearchResult]? {
        guard let cached = cache[query] else { return nil }

        // Check if cached results have expired
        if Date().timeIntervalSince(cached.timestamp) > expirationInterval {
            cache.removeValue(forKey: query)
            return nil
        }

        return cached.results
    }

    public func setResults(_ results: [PlaceSearchResult], for query: PlaceSearchQuery) async {
        // Clean up old entries if cache is full
        if cache.count >= maxCacheSize {
            await evictOldest()
        }

        cache[query] = CachedResults(results: results, timestamp: Date())
    }

    public func clearCache() async {
        cache.removeAll()
    }

    private func evictOldest() async {
        guard let oldestKey = cache.min(by: { $0.value.timestamp < $1.value.timestamp })?.key else {
            return
        }
        cache.removeValue(forKey: oldestKey)
    }
}
