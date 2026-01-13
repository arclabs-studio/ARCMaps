//
//  MapStyle.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// Map style options
public enum MapStyle: String, Sendable, CaseIterable, Equatable {
    case standard = "Standard"
    case satellite = "Satellite"
    case hybrid = "Hybrid"
}
