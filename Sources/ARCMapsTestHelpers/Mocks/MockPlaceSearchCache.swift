import Foundation
@testable import ARCMaps

public actor MockPlaceSearchCache: PlaceSearchCache {

    public var cache: [PlaceSearchQuery: [PlaceSearchResult]] = [:]
    public private(set) var getResultsCalled = false
    public private(set) var setResultsCalled = false
    public private(set) var clearCacheCalled = false

    public init() {}

    public func getResults(for query: PlaceSearchQuery) async -> [PlaceSearchResult]? {
        getResultsCalled = true
        return cache[query]
    }

    public func setResults(_ results: [PlaceSearchResult], for query: PlaceSearchQuery) async {
        setResultsCalled = true
        cache[query] = results
    }

    public func clearCache() async {
        clearCacheCalled = true
        cache.removeAll()
    }

    public func reset() {
        getResultsCalled = false
        setResultsCalled = false
        clearCacheCalled = false
        cache.removeAll()
    }
}
