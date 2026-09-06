//
//  AppleMapsSearchService.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import ARCLogger
import CoreLocation
import Foundation
import MapKit

/// Apple MapKit local search service implementation
public actor AppleMapsSearchService: PlaceEnrichmentService {
    private let cache: PlaceSearchCache
    private let logger = ARCLogger(category: "AppleMapsSearchService")

    public init(cache: PlaceSearchCache) {
        self.cache = cache
    }

    // MARK: - PlaceEnrichmentService

    public func searchPlaces(query: PlaceSearchQuery) async throws -> [PlaceSearchResult] {
        logger.debug("Searching places with Apple Maps: \(query.fullTextQuery)")

        // Check cache first
        if let cachedResults = await cache.getResults(for: query) {
            logger.debug("Returning \(cachedResults.count) cached results")
            return cachedResults
        }

        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query.fullTextQuery

        if let coordinate = query.coordinate {
            searchRequest.region = Self.searchRegion(latitude: coordinate.latitude,
                                                     longitude: coordinate.longitude,
                                                     radiusMeters: query.radiusMeters)

            // Treat the region as a hard constraint when categories are supplied
            // (POI-only nearby search). Falls back gracefully on iOS < 18.
            if query.poiCategories != nil {
                if #available(iOS 18.0, macOS 15.0, *) {
                    searchRequest.regionPriority = .required
                }
            }
        }

        if let categories = query.poiCategories, !categories.isEmpty {
            let mkCategories = categories.map(Self.mapCategory(_:))
            searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: mkCategories)
            searchRequest.resultTypes = .pointOfInterest
        }

        let search = MKLocalSearch(request: searchRequest)

        do {
            let response = try await search.start()

            // Mapping is shared with AppleMapsCompletionService so a place found by typing
            // and the same place found by picking a suggestion carry the same id.
            let results = response.mapItems.compactMap(AppleMapsPlaceMapper.searchResult(from:))

            // Cache results
            await cache.setResults(results, for: query)

            logger.info("Found \(results.count) places")
            return results
        } catch {
            logger.error("Failed to search places with Apple Maps: \(error.localizedDescription)")
            throw PlaceEnrichmentError.networkError(error.localizedDescription)
        }
    }

    public func getPlaceDetails(placeId _: String) async throws -> EnrichedPlaceData {
        logger.warning("Apple Maps does not support detailed place information")
        throw PlaceEnrichmentError.serviceUnavailable(.apple)
    }

    public func getPhotoURL(photoReference: String, maxWidth _: Int) async throws -> URL {
        logger.warning("Apple Maps does not support photo URLs")
        throw PlaceEnrichmentError.photoDownloadFailed(photoReference)
    }

    // MARK: - Internal Helpers

    /// Default search radius when a query supplies a coordinate but no radius.
    static let defaultRadiusMeters = 10000

    /// Builds the search window around a coordinate from a **radius**.
    ///
    /// `MKCoordinateRegion(center:latitudinalMeters:longitudinalMeters:)` takes the
    /// full north-to-south and east-to-west *span* — a diameter, not a radius. Passing
    /// the radius straight through therefore halved the window: a caller asking for
    /// 5 km got a 5 km-wide box, i.e. 2.5 km in every direction, and candidates it
    /// would have accepted were never returned.
    ///
    /// Longitude uses the same metre value; MapKit applies the cos(latitude)
    /// conversion itself.
    static func searchRegion(latitude: Double, longitude: Double, radiusMeters: Int?) -> MKCoordinateRegion {
        let radius = Double(radiusMeters ?? defaultRadiusMeters)
        let span = radius * 2

        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                  latitudinalMeters: span,
                                  longitudinalMeters: span)
    }

    // MARK: - Private Helpers

    /// Maps the provider-agnostic `PlaceCategory` to `MKPointOfInterestCategory`.
    /// MapKit import is kept isolated to the Data layer per Clean Architecture.
    private static func mapCategory(_ category: PlaceCategory) -> MKPointOfInterestCategory {
        switch category {
        case .restaurant: .restaurant
        case .cafe: .cafe
        case .bakery: .bakery
        case .brewery: .brewery
        case .winery: .winery
        case .foodMarket: .foodMarket
        case .nightlife: .nightlife
        }
    }
}
