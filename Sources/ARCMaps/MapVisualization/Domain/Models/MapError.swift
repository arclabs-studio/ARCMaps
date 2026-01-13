//
//  MapError.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// Errors that can occur during map visualization and location operations.
///
/// These errors cover location permission issues, coordinate validation,
/// and external navigation failures.
///
/// ## Error Handling
/// ```swift
/// do {
///     try await locationService.requestPermission()
///     let location = try await locationService.getCurrentLocation()
/// } catch MapError.locationPermissionDenied {
///     showPermissionSettings()
/// } catch MapError.locationUnavailable {
///     showLocationDisabledMessage()
/// }
/// ```
public enum MapError: LocalizedError, Sendable, Equatable {
    /// The user has denied location permission for this app.
    case locationPermissionDenied

    /// Location services are unavailable or disabled.
    case locationUnavailable

    /// The provided coordinate is invalid (e.g., out of range).
    case invalidCoordinate

    /// No places are available to display on the map.
    case noPlacesFound

    /// The external navigation app is not installed on the device.
    case externalAppNotInstalled(String)

    /// Failed to open external navigation.
    case navigationFailed

    public var errorDescription: String? {
        switch self {
        case .locationPermissionDenied:
            "Location permission denied. Please enable in Settings"
        case .locationUnavailable:
            "Unable to determine your location"
        case .invalidCoordinate:
            "Invalid coordinate provided"
        case .noPlacesFound:
            "No places found to display"
        case let .externalAppNotInstalled(app):
            "\(app) is not installed"
        case .navigationFailed:
            "Failed to open navigation"
        }
    }
}
