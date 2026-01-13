//
//  MapError.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// Errors that can occur in map operations
public enum MapError: LocalizedError, Sendable, Equatable {
    case locationPermissionDenied
    case locationUnavailable
    case invalidCoordinate
    case noPlacesFound
    case externalAppNotInstalled(String)
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
