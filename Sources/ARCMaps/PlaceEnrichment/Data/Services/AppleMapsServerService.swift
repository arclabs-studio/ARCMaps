//
//  AppleMapsServerService.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 18/03/2026.
//

import ARCLogger
import CoreLocation
import Foundation

/// Apple Maps Server API service implementation.
///
/// Uses the Apple Maps Server REST API (`https://maps-api.apple.com/v1/`) for place search
/// and basic place detail retrieval. Requires JWT authentication via ``AppleMapsTokenProvider``.
///
/// ## Capabilities
/// - Text-based place search with optional bias toward a user location
/// - Basic place detail retrieval (name, address, category, coordinates)
///
/// ## Limitations
/// - Does not provide photos (throws `photoDownloadFailed`)
/// - Does not provide ratings, reviews, phone numbers, or opening hours
/// - Details endpoint returns address and category only
///
/// ## Example
/// ```swift
/// let tokenProvider = try AppleMapsTokenProvider(
///     keyID: config.appleMapsKeyID!,
///     teamID: config.appleMapsTeamID!,
///     privateKeyPEM: config.appleMapsPrivateKey!
/// )
/// let service = AppleMapsServerService(
///     tokenProvider: tokenProvider,
///     networkClient: DefaultNetworkClient(),
///     cache: InMemoryPlaceCache()
/// )
/// ```
public actor AppleMapsServerService: PlaceEnrichmentService {
    private let tokenProvider: any AppleMapsTokenProviding
    private let networkClient: NetworkClientProtocol
    private let cache: PlaceSearchCache
    private let logger = ARCLogger(category: "AppleMapsServerService")

    private let baseURL = "https://maps-api.apple.com/v1"

    public init(tokenProvider: any AppleMapsTokenProviding,
                networkClient: NetworkClientProtocol,
                cache: PlaceSearchCache) {
        self.tokenProvider = tokenProvider
        self.networkClient = networkClient
        self.cache = cache
    }

    // MARK: - PlaceEnrichmentService

    public func searchPlaces(query: PlaceSearchQuery) async throws -> [PlaceSearchResult] {
        logger.debug("Searching places with Apple Maps Server: \(query.fullTextQuery)")

        if let cachedResults = await cache.getResults(for: query) {
            logger.debug("Returning \(cachedResults.count) cached results")
            return cachedResults
        }

        guard var components = URLComponents(string: "\(baseURL)/search") else {
            throw PlaceEnrichmentError.invalidQuery
        }

        components.queryItems = [URLQueryItem(name: "q", value: query.fullTextQuery),
                                 URLQueryItem(name: "lang",
                                              value: Locale.current.language.languageCode?.identifier ?? "en")]

        if let coordinate = query.coordinate {
            components.queryItems?.append(URLQueryItem(name: "userLocation",
                                                       value: "\(coordinate.latitude),\(coordinate.longitude)"))
        }

        if let radius = query.radiusMeters {
            components.queryItems?.append(URLQueryItem(name: "radius", value: "\(radius)"))
        }

        guard let url = components.url else {
            throw PlaceEnrichmentError.invalidQuery
        }

        let authHeader = try await authorizationHeader()

        do {
            let response: AppleMapsServerSearchResponse = try await networkClient.request(url: url, method: .get,
                                                                                          headers: authHeader,
                                                                                          body: nil)
            let results = response.results.compactMap { mapSearchResult($0) }
            await cache.setResults(results, for: query)
            logger.info("Found \(results.count) places via Apple Maps Server")
            return results
        } catch {
            if !(error is PlaceEnrichmentError) {
                logger.error("Apple Maps Server search failed: \(error.localizedDescription)")
            }
            throw PlaceEnrichmentError.wrap(error)
        }
    }

    private func mapSearchResult(_ searchResult: AppleMapsServerSearchResult) -> PlaceSearchResult? {
        guard let place = searchResult.place,
              let placeId = place.placeId,
              let name = place.name,
              let coord = place.coordinate
        else { return nil }

        return PlaceSearchResult(id: placeId,
                                 provider: .appleServer,
                                 name: name,
                                 address: place.formattedAddressLines?.joined(separator: ", "),
                                 coordinate: CLLocationCoordinate2D(latitude: coord.latitude,
                                                                    longitude: coord.longitude),
                                 types: place.pointOfInterestCategory.map { [$0] } ?? [])
    }

    public func getPlaceDetails(placeId: String) async throws -> EnrichedPlaceData {
        logger.debug("Fetching place details via Apple Maps Server: \(placeId)")

        guard let url = URL(string: "\(baseURL)/place/\(placeId)") else {
            throw PlaceEnrichmentError.invalidQuery
        }

        let authHeader = try await authorizationHeader()

        do {
            let place: AppleMapsServerPlaceResponse = try await networkClient.request(url: url,
                                                                                      method: .get,
                                                                                      headers: authHeader,
                                                                                      body: nil)

            guard let name = place.name,
                  let coord = place.coordinate
            else {
                throw PlaceEnrichmentError.invalidResponse
            }

            let enrichedData = EnrichedPlaceData(placeId: place.id ?? placeId,
                                                 provider: .appleServer,
                                                 name: name,
                                                 formattedAddress: place.formattedAddressLines?.joined(separator: ", "),
                                                 coordinate: CLLocationCoordinate2D(latitude: coord.latitude,
                                                                                    longitude: coord.longitude),
                                                 phoneNumber: place.telephone,
                                                 website: place.url.flatMap { URL(string: $0) },
                                                 rating: nil,
                                                 userRatingsTotal: nil,
                                                 priceLevel: nil,
                                                 openingHours: nil,
                                                 photos: [],
                                                 reviews: [],
                                                 types: place.pointOfInterestCategory.map { [$0] } ?? [])

            logger.info("Fetched details for: \(name)")
            return enrichedData
        } catch {
            if !(error is PlaceEnrichmentError) {
                logger.error("Apple Maps Server place details failed: \(error.localizedDescription)")
            }
            throw PlaceEnrichmentError.wrap(error)
        }
    }

    public func getPhotoURL(photoReference: String, maxWidth _: Int) async throws -> URL {
        logger.warning("Apple Maps Server does not support photo URLs")
        throw PlaceEnrichmentError.photoDownloadFailed(photoReference)
    }

    // MARK: - Private

    private func authorizationHeader() async throws -> [String: String] {
        let token = try await tokenProvider.token()
        return ["Authorization": "Bearer \(token)"]
    }
}
