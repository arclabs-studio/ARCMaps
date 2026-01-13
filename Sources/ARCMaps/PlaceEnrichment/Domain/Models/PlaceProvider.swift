//
//  PlaceProvider.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// External place data providers supported by ARCMaps.
///
/// `PlaceProvider` identifies the source of place data, which affects available
/// features, API requirements, and data format. Configure the default provider
/// in ``ARCMapsConfiguration``.
///
/// ## Example
/// ```swift
/// // Configure default provider
/// ARCMapsConfiguration.shared = ARCMapsConfiguration(
///     googlePlacesAPIKey: "YOUR_KEY",
///     defaultProvider: .google
/// )
///
/// // Display provider info
/// let provider: PlaceProvider = .google
/// Label(provider.displayName, systemImage: provider.iconName)
/// ```
public enum PlaceProvider: String, Sendable, CaseIterable, Equatable, Codable {
    /// Google Places API - requires API key, provides detailed place data.
    case google = "Google Places"

    /// Apple Maps / MapKit - uses device's Apple ID, no additional API key required.
    case apple = "Apple Maps"

    /// Human-readable display name for the provider.
    public var displayName: String {
        rawValue
    }

    /// SF Symbol name for visual representation.
    ///
    /// - Returns: `"globe"` for Google, `"map"` for Apple.
    public var iconName: String {
        switch self {
        case .google: "globe"
        case .apple: "map"
        }
    }
}
