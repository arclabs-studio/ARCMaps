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
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                           longitude: coordinate.longitude),
                                            latitudinalMeters: Double(query.radiusMeters ?? 10000),
                                            longitudinalMeters: Double(query.radiusMeters ?? 10000))
            searchRequest.region = region

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

            let results = response.mapItems.compactMap { mapItem -> PlaceSearchResult? in
                guard let name = mapItem.name,
                      let coordinate = mapItem.placemark.location?.coordinate
                else {
                    return nil
                }

                return PlaceSearchResult(id: Self.stableId(for: mapItem),
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

    // MARK: - Private Helpers

    /// Prefer the stable `MKMapItem.Identifier` (iOS 18+) over placemark description,
    /// which is volatile across catalog updates.
    private static func stableId(for mapItem: MKMapItem) -> String {
        if #available(iOS 18.0, macOS 15.0, *), let identifier = mapItem.identifier {
            return identifier.rawValue
        }
        return mapItem.placemark.description
    }

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
