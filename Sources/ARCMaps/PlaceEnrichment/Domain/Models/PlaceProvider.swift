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
    /// Google Places API - requires API key, provides detailed place data including
    /// photos, ratings, opening hours, phone numbers, and reviews.
    case google = "Google Places"

    /// Apple Maps Server API - requires Apple Developer account and JWT authentication.
    /// Provides structured address, category, place ID, and coordinates. No photos/ratings.
    case appleServer = "Apple Maps Server"

    /// Apple MapKit (on-device) - no API key required, always available as offline fallback.
    /// Returns basic name, coordinate, and address only.
    case apple = "Apple Maps"

    /// Human-readable display name for the provider.
    public var displayName: String {
        rawValue
    }

    /// SF Symbol name for visual representation.
    ///
    /// - Returns: `"globe"` for Google, `"server.rack"` for Apple Server, `"map"` for Apple.
    public var iconName: String {
        switch self {
        case .google: "globe"
        case .appleServer: "server.rack"
        case .apple: "map"
        }
    }
}
