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

/// External maps apps
public enum ExternalMapApp: String, CaseIterable, Sendable {
    case appleMaps = "Apple Maps"
    case googleMaps = "Google Maps"
    case waze = "Waze"

    var urlScheme: String {
        switch self {
        case .appleMaps: "http://maps.apple.com"
        case .googleMaps: "comgooglemaps"
        case .waze: "waze"
        }
    }

    func canOpen() -> Bool {
        #if canImport(UIKit)
        guard let url = URL(string: urlScheme + "://") else { return false }
        return UIApplication.shared.canOpenURL(url)
        #else
        return false
        #endif
    }
}

/// Utility for launching external map applications
public enum ExternalMapLauncher {
    /// Open coordinate in external map app
    /// - Parameters:
    ///   - coordinate: Coordinate to open
    ///   - name: Optional place name
    ///   - address: Optional address
    ///   - app: External map app to use
    /// - Throws: MapError if app not installed or launch fails
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

        await UIApplication.shared.open(url)
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
