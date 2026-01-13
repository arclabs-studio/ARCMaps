import ARCLogger
import CoreLocation
import Foundation

/// Google Places API service implementation
public actor GooglePlacesService: PlaceEnrichmentService {

    private let apiKey: String
    private let networkClient: NetworkClientProtocol
    private let cache: PlaceSearchCache
    private let logger = ARCLogger(category: "GooglePlacesService")

    private let baseURL = "https://maps.googleapis.com/maps/api/place"

    public init(
        apiKey: String,
        networkClient: NetworkClientProtocol,
        cache: PlaceSearchCache
    ) {
        self.apiKey = apiKey
        self.networkClient = networkClient
        self.cache = cache
    }

    // MARK: - PlaceEnrichmentService

    public func searchPlaces(query: PlaceSearchQuery) async throws -> [PlaceSearchResult] {
        logger.debug("Searching places with query: \(query.fullTextQuery)")

        // Check cache first
        if let cachedResults = await cache.getResults(for: query) {
            logger.debug("Returning \(cachedResults.count) cached results")
            return cachedResults
        }

        // Build request
        var components = URLComponents(string: "\(baseURL)/textsearch/json")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query.fullTextQuery),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "language", value: Locale.current.language.languageCode?.identifier ?? "en")
        ]

        if let coordinate = query.coordinate {
            let location = "\(coordinate.latitude),\(coordinate.longitude)"
            components.queryItems?.append(URLQueryItem(name: "location", value: location))
        }

        if let radius = query.radiusMeters {
            components.queryItems?.append(URLQueryItem(name: "radius", value: "\(radius)"))
        }

        guard let url = components.url else {
            throw PlaceEnrichmentError.invalidQuery
        }

        // Execute request
        do {
            let response: GooglePlacesSearchResponse = try await networkClient.request(
                url: url,
                method: .get,
                headers: nil,
                body: nil
            )

            guard response.status == "OK" || response.status == "ZERO_RESULTS" else {
                logger.error("Google Places API error: \(response.status)")
                throw mapGoogleError(response.status)
            }

            let results = response.results.map { GooglePlacesMapper.mapToSearchResult($0) }

            // Cache results
            await cache.setResults(results, for: query)

            logger.info("Found \(results.count) places")
            return results

        } catch let error as PlaceEnrichmentError {
            throw error
        } catch {
            logger.error("Failed to search places: \(error.localizedDescription)")
            throw PlaceEnrichmentError.networkError(error.localizedDescription)
        }
    }

    public func getPlaceDetails(placeId: String) async throws -> EnrichedPlaceData {
        logger.debug("Fetching details for place: \(placeId)")

        var components = URLComponents(string: "\(baseURL)/details/json")!
        components.queryItems = [
            URLQueryItem(name: "place_id", value: placeId),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "fields", value: "name,formatted_address,geometry,photos,rating,user_ratings_total,price_level,opening_hours,website,formatted_phone_number,reviews,types"),
            URLQueryItem(name: "language", value: Locale.current.language.languageCode?.identifier ?? "en")
        ]

        guard let url = components.url else {
            throw PlaceEnrichmentError.invalidQuery
        }

        do {
            let response: GooglePlaceDetailsResponse = try await networkClient.request(
                url: url,
                method: .get,
                headers: nil,
                body: nil
            )

            guard response.status == "OK" else {
                logger.error("Google Places API error: \(response.status)")
                throw mapGoogleError(response.status)
            }

            let enrichedData = GooglePlacesMapper.mapToEnrichedData(response.result)

            logger.info("Fetched details for: \(enrichedData.name)")
            return enrichedData

        } catch let error as PlaceEnrichmentError {
            throw error
        } catch {
            logger.error("Failed to fetch place details: \(error.localizedDescription)")
            throw PlaceEnrichmentError.networkError(error.localizedDescription)
        }
    }

    public func getPhotoURL(photoReference: String, maxWidth: Int) async throws -> URL {
        var components = URLComponents(string: "\(baseURL)/photo")!
        components.queryItems = [
            URLQueryItem(name: "photoreference", value: photoReference),
            URLQueryItem(name: "maxwidth", value: "\(maxWidth)"),
            URLQueryItem(name: "key", value: apiKey)
        ]

        guard let url = components.url else {
            throw PlaceEnrichmentError.photoDownloadFailed(photoReference)
        }

        return url
    }

    // MARK: - Private Helpers

    private func mapGoogleError(_ status: String) -> PlaceEnrichmentError {
        switch status {
        case "ZERO_RESULTS":
            return .noResultsFound
        case "INVALID_REQUEST":
            return .invalidQuery
        case "OVER_QUERY_LIMIT":
            return .rateLimitExceeded
        case "REQUEST_DENIED":
            return .invalidAPIKey
        default:
            return .serviceUnavailable(.google)
        }
    }
}
