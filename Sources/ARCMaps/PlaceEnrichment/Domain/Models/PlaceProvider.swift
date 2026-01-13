import Foundation

/// Supported place data providers
public enum PlaceProvider: String, Sendable, CaseIterable, Equatable, Codable {
    case google = "Google Places"
    case apple = "Apple Maps"

    /// Display name for UI
    public var displayName: String {
        rawValue
    }

    /// Icon system name
    public var iconName: String {
        switch self {
        case .google: return "globe"
        case .apple: return "map"
        }
    }
}
