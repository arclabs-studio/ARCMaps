//
//  MapRegion.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation
import MapKit

/// Represents a map region
public struct MapRegion: Sendable, Equatable {
    public let center: CLLocationCoordinate2D
    public let span: (latitudeDelta: Double, longitudeDelta: Double)

    public init(
        center: CLLocationCoordinate2D,
        span: (latitudeDelta: Double, longitudeDelta: Double)
    ) {
        self.center = center
        self.span = span
    }

    /// Convert to MKCoordinateRegion
    public var mkCoordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: span.latitudeDelta,
                longitudeDelta: span.longitudeDelta
            )
        )
    }

    /// Create region that fits all coordinates
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
