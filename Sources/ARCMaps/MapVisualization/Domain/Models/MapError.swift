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

    /// Localizable user-facing message.
    ///
    /// `LocalizedStringResource` defaults to `BundleDescription.main`, which at
    /// runtime is the *host app's* bundle — so the app's String Catalog supplies
    /// the translations and the literals here are only the English defaults.
    /// ARC packages stay text-agnostic: no `.xcstrings` ships with ARCMaps, and a
    /// key the host has not translated falls back to the default below. [FVRS-324]
    public var message: LocalizedStringResource {
        switch self {
        case .locationPermissionDenied:
            LocalizedStringResource("Location permission denied. Please enable in Settings",
                                    comment: "Error: the user denied location permission for the map")
        case .locationUnavailable:
            LocalizedStringResource("Unable to determine your location",
                                    comment: "Error: the device could not resolve the user's location")
        case .invalidCoordinate:
            LocalizedStringResource("Invalid coordinate provided",
                                    comment: "Error: a place carries an out-of-range coordinate")
        case .noPlacesFound:
            LocalizedStringResource("No places found to display",
                                    comment: "Error: the map has no places to show")
        case let .externalAppNotInstalled(app):
            LocalizedStringResource("\(app) is not installed",
                                    comment: "Error: external maps app missing. %@ is its name, e.g. Google Maps")
        case .navigationFailed:
            LocalizedStringResource("Failed to open navigation",
                                    comment: "Error: launching the external navigation app failed")
        }
    }

    /// Plain-English bridge for system contexts that take an `Error`.
    ///
    /// UI should render ``message`` instead: resolving here would pin the string
    /// to the current locale at throw time.
    public var errorDescription: String? {
        String(localized: message)
    }
}
