//
//  PlaceProvider.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

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
        case .google: "globe"
        case .apple: "map"
        }
    }
}
