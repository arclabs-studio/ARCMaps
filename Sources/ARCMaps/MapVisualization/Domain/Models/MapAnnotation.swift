//
//  MapAnnotation.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation

/// Custom map annotation with additional metadata
public struct MapAnnotation: Sendable, Identifiable, Equatable {
    public let id: String
    public let coordinate: CLLocationCoordinate2D
    public let title: String
    public let subtitle: String?
    public let markerType: MarkerType
    public let metadata: [String: String]

    public init(
        id: String,
        coordinate: CLLocationCoordinate2D,
        title: String,
        subtitle: String? = nil,
        markerType: MarkerType = .standard,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.markerType = markerType
        self.metadata = metadata
    }
}

public enum MarkerType: Sendable, Equatable {
    case wishlist
    case visited
    case standard
    case custom(iconName: String)
}
