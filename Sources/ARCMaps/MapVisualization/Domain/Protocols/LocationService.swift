//
//  LocationService.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation

/// Service for managing location permissions and updates
public protocol LocationService: Sendable {
    /// Request location permissions
    /// - Returns: Whether permission was granted
    func requestPermission() async -> Bool

    /// Get current location authorization status
    /// - Returns: Current authorization status
    func authorizationStatus() async -> CLAuthorizationStatus

    /// Get user's current location
    /// - Returns: Current coordinate
    /// - Throws: MapError if location unavailable
    func getCurrentLocation() async throws -> CLLocationCoordinate2D

    /// Start monitoring location updates
    func startMonitoring() async

    /// Stop monitoring location updates
    func stopMonitoring() async
}
