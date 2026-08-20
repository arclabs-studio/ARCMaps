//
//  MapPlace.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation

/// A place that can be displayed on the map with associated metadata.
///
/// `MapPlace` represents a geographic location with additional information such as
/// name, address, category, and rating. It serves as the primary model for
/// displaying places on the map interface.
///
/// ## Example
/// ```swift
/// let place = MapPlace(
///     id: "place_123",
///     name: "Café Luna",
///     coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
///     address: "123 Main Street",
///     category: "cafe",
///     rating: 4.5
/// )
/// ```
public struct MapPlace: Sendable, Identifiable, Equatable {
    /// Unique identifier for the place.
    public let id: String

    /// Display name of the place.
    public let name: String

    /// Geographic coordinates of the place.
    public let coordinate: CLLocationCoordinate2D

    /// Street address or location description.
    public let address: String?

    /// Category or type of place (e.g., "cafe", "museum").
    public let category: String?

    /// User or aggregate rating, typically on a 1-5 scale.
    public let rating: Double?

    /// URL to an image representing the place.
    public let imageURL: URL?

    /// Creates a new map place with the specified properties.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the place.
    ///   - name: Display name of the place.
    ///   - coordinate: Geographic coordinates.
    ///   - address: Street address or location description.
    ///   - category: Category or type of place.
    ///   - rating: User or aggregate rating.
    ///   - imageURL: URL to a place image.
    public init(id: String,
                name: String,
                coordinate: CLLocationCoordinate2D,
                address: String? = nil,
                category: String? = nil,
                rating: Double? = nil,
                imageURL: URL? = nil) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.address = address
        self.category = category
        self.rating = rating
        self.imageURL = imageURL
    }

    /// Calculates the distance from this place to another coordinate.
    ///
    /// - Parameter coordinate: The coordinate to measure distance to.
    /// - Returns: The distance in meters.
    public func distance(from coordinate: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2)
    }
}
