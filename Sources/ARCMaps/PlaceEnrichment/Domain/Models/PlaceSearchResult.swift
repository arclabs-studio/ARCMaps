//
//  PlaceSearchResult.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation

/// A place search result returned from an external provider.
///
/// `PlaceSearchResult` contains the basic information about a place returned
/// from a search query, including location, ratings, and photo references.
/// Use this to display search results before fetching full ``EnrichedPlaceData``.
///
/// ## Example
/// ```swift
/// let results = try await placesService.searchPlaces(query: query)
/// for result in results {
///     print("\(result.name) - Rating: \(result.rating ?? 0)")
///     print("Match score: \(result.matchScore)")
/// }
/// ```
public struct PlaceSearchResult: Sendable, Identifiable, Equatable {
    /// Unique identifier from the provider (e.g., Google Place ID).
    public let id: String

    /// The service provider that returned this result.
    public let provider: PlaceProvider

    /// Display name of the place.
    public let name: String

    /// Formatted address of the place.
    public let address: String?

    /// Geographic coordinates of the place.
    public let coordinate: CLLocationCoordinate2D

    /// Place type categories (e.g., "restaurant", "cafe", "museum").
    public let types: [String]

    /// Average user rating, typically on a 1-5 scale.
    public let rating: Double?

    /// Total number of user ratings.
    public let userRatingsTotal: Int?

    /// Price level indicator (0-4, where 0 is free and 4 is expensive).
    public let priceLevel: Int?

    /// References to available photos that can be fetched separately.
    public let photoReferences: [String]

    /// Creates a new place search result.
    ///
    /// - Parameters:
    ///   - id: Unique identifier from the provider.
    ///   - provider: The service provider that returned this result.
    ///   - name: Display name of the place.
    ///   - address: Formatted address of the place.
    ///   - coordinate: Geographic coordinates.
    ///   - types: Place type categories.
    ///   - rating: Average user rating.
    ///   - userRatingsTotal: Total number of user ratings.
    ///   - priceLevel: Price level indicator (0-4).
    ///   - photoReferences: References to available photos.
    public init(
        id: String,
        provider: PlaceProvider,
        name: String,
        address: String? = nil,
        coordinate: CLLocationCoordinate2D,
        types: [String] = [],
        rating: Double? = nil,
        userRatingsTotal: Int? = nil,
        priceLevel: Int? = nil,
        photoReferences: [String] = []
    ) {
        self.id = id
        self.provider = provider
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.types = types
        self.rating = rating
        self.userRatingsTotal = userRatingsTotal
        self.priceLevel = priceLevel
        self.photoReferences = photoReferences
    }

    /// A quality score (0.0 to 1.0) based on the completeness of available data.
    ///
    /// The score is calculated by summing weighted factors:
    /// - Has rating: +0.3
    /// - Has user ratings: +0.2
    /// - Has photos: +0.3
    /// - Has address: +0.2
    ///
    /// Use this to sort or filter results by data quality.
    public var matchScore: Double {
        var score = 0.0
        if rating != nil { score += 0.3 }
        if userRatingsTotal ?? 0 > 0 { score += 0.2 }
        if !photoReferences.isEmpty { score += 0.3 }
        if address != nil { score += 0.2 }
        return score
    }
}
