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
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                latitudinalMeters: Double(query.radiusMeters ?? 10000),
                longitudinalMeters: Double(query.radiusMeters ?? 10000)
            )
            searchRequest.region = region
        }

        let search = MKLocalSearch(request: searchRequest)

        do {
            let response = try await search.start()

            let results = response.mapItems.compactMap { mapItem -> PlaceSearchResult? in
                guard let name = mapItem.name,
                      let coordinate = mapItem.placemark.location?.coordinate else {
                    return nil
                }

                return PlaceSearchResult(
                    id: mapItem.placemark.description,
                    provider: .apple,
                    name: name,
                    address: formatAddress(mapItem.placemark),
                    coordinate: coordinate,
                    types: [],
                    rating: nil, // Apple Maps doesn't provide ratings in search
                    userRatingsTotal: nil,
                    priceLevel: nil,
                    photoReferences: []
                )
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

    public func getPlaceDetails(placeId: String) async throws -> EnrichedPlaceData {
        logger.warning("Apple Maps does not support detailed place information")
        throw PlaceEnrichmentError.serviceUnavailable(.apple)
    }

    public func getPhotoURL(photoReference: String, maxWidth: Int) async throws -> URL {
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
