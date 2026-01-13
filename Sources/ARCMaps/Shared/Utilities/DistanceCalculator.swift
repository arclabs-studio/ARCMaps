//
//  DistanceCalculator.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation

/// Utility functions for geographic distance calculations.
///
/// `DistanceCalculator` provides static methods for measuring distances between
/// coordinates, formatting distances for display, and performing radius-based
/// proximity checks.
///
/// ## Example
/// ```swift
/// let userLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
/// let placeLocation = CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094)
///
/// // Calculate distance
/// let meters = DistanceCalculator.distance(from: userLocation, to: placeLocation)
/// print(DistanceCalculator.formatDistance(meters)) // "1.4 km"
///
/// // Check if within radius
/// if DistanceCalculator.isWithinRadius(coordinate: placeLocation, center: userLocation, radiusMeters: 5000) {
///     print("Place is within 5km")
/// }
/// ```
public enum DistanceCalculator {
    /// Calculates the distance between two coordinates using the Haversine formula.
    ///
    /// - Parameters:
    ///   - from: The starting coordinate.
    ///   - to: The destination coordinate.
    /// - Returns: The distance in meters.
    public static func distance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Double {
        from.distance(to: to)
    }

    /// Formats a distance value for human-readable display.
    ///
    /// Automatically selects the appropriate unit (meters or kilometers)
    /// based on the distance magnitude.
    ///
    /// - Parameter meters: The distance in meters.
    /// - Returns: A localized, formatted string (e.g., "150 m" or "2.5 km").
    public static func formatDistance(_ meters: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.maximumFractionDigits = 1

        if meters < 1000 {
            let measurement = Measurement(value: meters, unit: UnitLength.meters)
            return formatter.string(from: measurement)
        } else {
            let measurement = Measurement(value: meters / 1000, unit: UnitLength.kilometers)
            return formatter.string(from: measurement)
        }
    }

    /// Checks whether a coordinate falls within a specified radius of a center point.
    ///
    /// - Parameters:
    ///   - coordinate: The coordinate to check.
    ///   - center: The center point of the radius.
    ///   - radiusMeters: The radius in meters.
    /// - Returns: `true` if the coordinate is within the radius, `false` otherwise.
    public static func isWithinRadius(
        coordinate: CLLocationCoordinate2D,
        center: CLLocationCoordinate2D,
        radiusMeters: Double
    ) -> Bool {
        distance(from: coordinate, to: center) <= radiusMeters
    }
}
