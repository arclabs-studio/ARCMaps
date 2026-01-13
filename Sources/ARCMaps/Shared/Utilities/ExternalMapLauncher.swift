//
//  ExternalMapLauncher.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// External map applications supported for navigation and location viewing.
///
/// Use with ``ExternalMapLauncher`` to open coordinates in the user's preferred map app.
///
/// ## Example
/// ```swift
/// // Check which apps are available
/// let availableApps = ExternalMapApp.allCases.filter { $0.canOpen() }
///
/// // Open in user's preferred app
/// try await ExternalMapLauncher.open(
///     coordinate: place.coordinate,
///     name: place.name,
///     app: .appleMaps
/// )
/// ```
public enum ExternalMapApp: String, CaseIterable, Sendable {
    /// Apple Maps - always available on iOS/macOS.
    case appleMaps = "Apple Maps"

    /// Google Maps - requires app to be installed.
    case googleMaps = "Google Maps"

    /// Waze - requires app to be installed.
    case waze = "Waze"

    var urlScheme: String {
        switch self {
        case .appleMaps: "http://maps.apple.com"
        case .googleMaps: "comgooglemaps"
        case .waze: "waze"
        }
    }

    /// Checks whether this map app is installed and can be opened.
    ///
    /// - Returns: `true` if the app can be opened, `false` otherwise.
    /// - Note: Always returns `false` on macOS.
    public func canOpen() -> Bool {
        #if canImport(UIKit)
        guard let url = URL(string: urlScheme + "://") else { return false }
        return UIApplication.shared.canOpenURL(url)
        #else
        return false
        #endif
    }
}

/// Utility for opening locations in external map applications.
///
/// `ExternalMapLauncher` provides a unified interface for opening coordinates
/// in Apple Maps, Google Maps, or Waze, handling URL scheme construction
/// and app availability checking.
///
/// ## Example
/// ```swift
/// // Open a place in Apple Maps
/// try await ExternalMapLauncher.open(
///     coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
///     name: "Golden Gate Bridge",
///     app: .appleMaps
/// )
/// ```
public enum ExternalMapLauncher {
    /// Opens a coordinate in the specified external map application.
    ///
    /// - Parameters:
    ///   - coordinate: The geographic coordinate to display.
    ///   - name: Optional place name to display in the map app.
    ///   - address: Optional address (used by Apple Maps if name is not provided).
    ///   - app: The external map application to open.
    /// - Throws: ``MapError/invalidCoordinate`` if the coordinate is invalid,
    ///   ``MapError/externalAppNotInstalled(_:)`` if the app is not installed,
    ///   or ``MapError/navigationFailed`` if the URL cannot be opened.
    public static func open(
        coordinate: CLLocationCoordinate2D,
        name: String? = nil,
        address: String? = nil,
        app: ExternalMapApp
    ) async throws {
        #if canImport(UIKit)
        guard coordinate.isValid else {
            throw MapError.invalidCoordinate
        }

        let url: URL?

        switch app {
        case .appleMaps:
            url = buildAppleMapsURL(coordinate: coordinate, name: name, address: address)

        case .googleMaps:
            guard app.canOpen() else {
                throw MapError.externalAppNotInstalled(app.rawValue)
            }
            url = buildGoogleMapsURL(coordinate: coordinate, name: name)

        case .waze:
            guard app.canOpen() else {
                throw MapError.externalAppNotInstalled(app.rawValue)
            }
            url = buildWazeURL(coordinate: coordinate)
        }

        guard let url else {
            throw MapError.navigationFailed
        }

        await MainActor.run {
            UIApplication.shared.open(url)
        }
        #else
        throw MapError.navigationFailed
        #endif
    }

    // MARK: - Private URL Builders

    private static func buildAppleMapsURL(
        coordinate: CLLocationCoordinate2D,
        name: String?,
        address: String?
    ) -> URL? {
        var components = URLComponents(string: "http://maps.apple.com/")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "ll", value: "\(coordinate.latitude),\(coordinate.longitude)")
        ]

        if let name {
            queryItems.append(URLQueryItem(name: "q", value: name))
        } else if let address {
            queryItems.append(URLQueryItem(name: "address", value: address))
        }

        components?.queryItems = queryItems
        return components?.url
    }

    private static func buildGoogleMapsURL(
        coordinate: CLLocationCoordinate2D,
        name: String?
    ) -> URL? {
        var components = URLComponents(string: "comgooglemaps://")
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "center", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "q", value: name ?? "\(coordinate.latitude),\(coordinate.longitude)")
        ]

        components?.queryItems = queryItems
        return components?.url
    }

    private static func buildWazeURL(coordinate: CLLocationCoordinate2D) -> URL? {
        var components = URLComponents(string: "waze://")
        components?.queryItems = [
            URLQueryItem(name: "ll", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "navigate", value: "yes")
        ]
        return components?.url
    }
}
