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
            return "Location permission denied. Please enable in Settings"
        case .locationUnavailable:
            return "Unable to determine your location"
        case .invalidCoordinate:
            return "Invalid coordinate provided"
        case .noPlacesFound:
            return "No places found to display"
        case .externalAppNotInstalled(let app):
            return "\(app) is not installed"
        case .navigationFailed:
            return "Failed to open navigation"
        }
    }
}
