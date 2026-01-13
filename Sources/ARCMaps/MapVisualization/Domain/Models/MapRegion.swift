//
//  MapRegion.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation
import MapKit

/// A geographic region defined by a center coordinate and span.
///
/// `MapRegion` represents a rectangular area on the map, commonly used to define
/// the visible area or to fit a set of coordinates. It provides conversion to
/// MapKit's `MKCoordinateRegion` for use with Apple Maps.
///
/// ## Example
/// ```swift
/// // Create a region centered on San Francisco
/// let sfRegion = MapRegion(
///     center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
///     span: (latitudeDelta: 0.1, longitudeDelta: 0.1)
/// )
///
/// // Create a region that fits multiple coordinates
/// let coordinates = places.map(\.coordinate)
/// if let fittedRegion = MapRegion.fitting(coordinates) {
///     mapView.setRegion(fittedRegion.mkCoordinateRegion)
/// }
/// ```
public struct MapRegion: Sendable, Equatable {
    /// The geographic center of the region.
    public let center: CLLocationCoordinate2D

    /// The span defining the region's dimensions in degrees of latitude and longitude.
    public let span: (latitudeDelta: Double, longitudeDelta: Double)

    /// Creates a new map region with the specified center and span.
    ///
    /// - Parameters:
    ///   - center: The geographic center of the region.
    ///   - span: A tuple containing the latitude and longitude deltas in degrees.
    public init(
        center: CLLocationCoordinate2D,
        span: (latitudeDelta: Double, longitudeDelta: Double)
    ) {
        self.center = center
        self.span = span
    }

    /// Converts this region to a MapKit `MKCoordinateRegion`.
    ///
    /// - Returns: An equivalent `MKCoordinateRegion` for use with MapKit APIs.
    public var mkCoordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: span.latitudeDelta,
                longitudeDelta: span.longitudeDelta
            )
        )
    }

    /// Creates a region that encompasses all provided coordinates with optional padding.
    ///
    /// Calculates the minimum bounding region that contains all coordinates,
    /// then adds padding to ensure markers aren't at the edge of the visible area.
    ///
    /// - Parameters:
    ///   - coordinates: The coordinates to fit within the region.
    ///   - padding: Additional padding as a fraction of the span (default 0.1 = 10%).
    /// - Returns: A region containing all coordinates, or `nil` if the array is empty.
    public static func fitting(_ coordinates: [CLLocationCoordinate2D], padding: Double = 0.1) -> MapRegion? {
        guard !coordinates.isEmpty else { return nil }

        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)

        guard let minLat = lats.min(),
              let maxLat = lats.max(),
              let minLon = lons.min(),
              let maxLon = lons.max()
        else {
            return nil
        }

        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2

        let spanLat = (maxLat - minLat) * (1 + padding)
        let spanLon = (maxLon - minLon) * (1 + padding)

        return MapRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: (latitudeDelta: max(spanLat, 0.01), longitudeDelta: max(spanLon, 0.01))
        )
    }

    public static func == (lhs: MapRegion, rhs: MapRegion) -> Bool {
        lhs.center == rhs.center &&
            lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
            lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}
