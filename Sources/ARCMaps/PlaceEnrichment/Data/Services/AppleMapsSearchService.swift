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

// MARK: - Constants

private enum SearchDefaults {
    /// Search radius used when a query does not specify one, in meters.
    static let radiusMeters = 10000
}

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

        let search = MKLocalSearch(request: makeSearchRequest(for: query))

        do {
            let response = try await search.start()
            let results = response.mapItems.compactMap(makeSearchResult)

            // Cache results
            await cache.setResults(results, for: query)

            logger.info("Found \(results.count) places")
            return results
        } catch {
            logger.error("Failed to search places with Apple Maps: \(error.localizedDescription)")
            throw PlaceEnrichmentError.networkError(error.localizedDescription)
        }
    }

    /// Builds the MapKit request for a search query, scoping it to the query's region when present.
    private func makeSearchRequest(for query: PlaceSearchQuery) -> MKLocalSearch.Request {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query.fullTextQuery

        if let coordinate = query.coordinate {
            let radius = Double(query.radiusMeters ?? SearchDefaults.radiusMeters)
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                longitude: coordinate.longitude)

            searchRequest.region = MKCoordinateRegion(center: center,
                                                      latitudinalMeters: radius,
                                                      longitudinalMeters: radius)
        }

        return searchRequest
    }

    /// Maps one MapKit item to a search result, discarding items missing a name or coordinate.
    private func makeSearchResult(from mapItem: MKMapItem) -> PlaceSearchResult? {
        guard let name = mapItem.name,
              let coordinate = mapItem.placemark.location?.coordinate
        else {
            return nil
        }

        return PlaceSearchResult(id: mapItem.placemark.description,
                                 provider: .apple,
                                 name: name,
                                 address: formatAddress(mapItem.placemark),
                                 coordinate: coordinate,
                                 types: [],
                                 rating: nil, // Apple Maps doesn't provide ratings in search
                                 userRatingsTotal: nil,
                                 priceLevel: nil,
                                 photoReferences: [])
    }

    public func getPlaceDetails(placeId _: String) async throws -> EnrichedPlaceData {
        logger.warning("Apple Maps does not support detailed place information")
        throw PlaceEnrichmentError.serviceUnavailable(.apple)
    }

    public func getPhotoURL(photoReference: String, maxWidth _: Int) async throws -> URL {
        logger.warning("Apple Maps does not support photo URLs")
        throw PlaceEnrichmentError.photoDownloadFailed(photoReference)
    }

    // MARK: - Private Helpers

    private func formatAddress(_ placemark: MKPlacemark) -> String? {
        var components: [String] = []

        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        if let subThoroughfare = placemark.subThoroughfare {
            components.append(subThoroughfare)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        if let postalCode = placemark.postalCode {
            components.append(postalCode)
        }

        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}
