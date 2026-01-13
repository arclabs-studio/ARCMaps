//
//  LocationService.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation

/// A service that manages device location permissions and provides location updates.
///
/// `LocationService` abstracts CoreLocation functionality, providing a cleaner async/await
/// interface for requesting permissions and tracking the user's location.
/// The default implementation is ``CoreLocationService``.
///
/// ## Conformance Requirements
/// Implementations must be `Sendable` for safe concurrent usage.
///
/// ## Example
/// ```swift
/// let locationService: LocationService = CoreLocationService()
///
/// // Request permission
/// let granted = await locationService.requestPermission()
/// if granted {
///     let location = try await locationService.getCurrentLocation()
///     print("User is at: \(location.latitude), \(location.longitude)")
/// }
/// ```
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
