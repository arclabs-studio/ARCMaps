//
//  DistanceCalculator.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation

/// Utility for calculating distances between coordinates
public enum DistanceCalculator {
    /// Calculate distance between two coordinates in meters
    public static func distance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Double {
        from.distance(to: to)
    }

    /// Format distance for display
    /// - Parameter meters: Distance in meters
    /// - Returns: Formatted string (e.g., "150 m" or "2.5 km")
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

    /// Check if coordinate is within radius of another coordinate
    public static func isWithinRadius(
        coordinate: CLLocationCoordinate2D,
        center: CLLocationCoordinate2D,
        radiusMeters: Double
    ) -> Bool {
        distance(from: coordinate, to: center) <= radiusMeters
    }
}
