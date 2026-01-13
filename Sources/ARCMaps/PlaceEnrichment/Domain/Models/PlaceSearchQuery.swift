//
//  PlaceSearchQuery.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// A query for searching places from external providers like Google Places or Apple Maps.
///
/// `PlaceSearchQuery` encapsulates all the parameters needed to search for places,
/// including name matching, location-based filtering, and geographic proximity.
///
/// ## Example
/// ```swift
/// // Simple name-based search
/// let basicQuery = PlaceSearchQuery(name: "La Taverna")
///
/// // Location-aware search with radius
/// let locationQuery = PlaceSearchQuery(
///     name: "Coffee Shop",
///     city: "San Francisco",
///     countryCode: "US",
///     coordinate: (37.7749, -122.4194),
///     radiusMeters: 5000
/// )
/// ```
public struct PlaceSearchQuery: Sendable, Equatable, Hashable {
    /// The name of the place to search for (e.g., "La Taverna", "Coffee Shop").
    public let name: String

    /// Street address for more precise search results.
    public let address: String?

    /// City name for filtering results to a specific location.
    public let city: String?

    /// ISO 3166-1 alpha-2 country code (e.g., "US", "ES", "GB").
    public let countryCode: String?

    /// Geographic coordinates for proximity-based search.
    public let coordinate: (latitude: Double, longitude: Double)?

    /// Search radius in meters when using coordinate-based search.
    public let radiusMeters: Int?

    /// Creates a new place search query with the specified parameters.
    ///
    /// - Parameters:
    ///   - name: The name of the place to search for.
    ///   - address: Street address for precision (optional).
    ///   - city: City name for filtering (optional).
    ///   - countryCode: ISO 3166-1 alpha-2 country code (optional).
    ///   - coordinate: Geographic coordinates for proximity search (optional).
    ///   - radiusMeters: Search radius in meters (optional, used with coordinate).
    public init(
        name: String,
        address: String? = nil,
        city: String? = nil,
        countryCode: String? = nil,
        coordinate: (latitude: Double, longitude: Double)? = nil,
        radiusMeters: Int? = nil
    ) {
        self.name = name
        self.address = address
        self.city = city
        self.countryCode = countryCode
        self.coordinate = coordinate
        self.radiusMeters = radiusMeters
    }

    /// A combined text query string using all available location fields.
    ///
    /// Joins name, address, and city (if available) with commas for use
    /// in text-based search APIs.
    ///
    /// - Returns: A comma-separated string like "La Taverna, 123 Main St, Madrid".
    public var fullTextQuery: String {
        var components = [name]
        if let address { components.append(address) }
        if let city { components.append(city) }
        return components.joined(separator: ", ")
    }

    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(address)
        hasher.combine(city)
        hasher.combine(countryCode)
        hasher.combine(radiusMeters)
        if let coordinate {
            hasher.combine(coordinate.latitude)
            hasher.combine(coordinate.longitude)
        }
    }

    // Equatable conformance
    public static func == (lhs: PlaceSearchQuery, rhs: PlaceSearchQuery) -> Bool {
        lhs.name == rhs.name &&
            lhs.address == rhs.address &&
            lhs.city == rhs.city &&
            lhs.countryCode == rhs.countryCode &&
            lhs.radiusMeters == rhs.radiusMeters &&
            lhs.coordinate?.latitude == rhs.coordinate?.latitude &&
            lhs.coordinate?.longitude == rhs.coordinate?.longitude
    }
}
