//
//  PlaceSearchQuery.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// Represents a search query for finding places
public struct PlaceSearchQuery: Sendable, Equatable, Hashable {
    /// Name of the place (e.g., "La Taverna")
    public let name: String

    /// Optional address for more precise search
    public let address: String?

    /// Optional city for filtering results
    public let city: String?

    /// Optional country code (ISO 3166-1 alpha-2)
    public let countryCode: String?

    /// Optional coordinate for proximity search
    public let coordinate: (latitude: Double, longitude: Double)?

    /// Search radius in meters (used with coordinate)
    public let radiusMeters: Int?

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

    /// Full text query combining all available fields
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
