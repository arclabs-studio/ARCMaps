//
//  MapStyle+Presentation.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 19/10/2026.
//

import MapKit
import SwiftUI

// MARK: - MapStyle Presentation

extension MapStyle {
    /// User-facing name. Resolves against the host app's String Catalog; the
    /// literals are the English defaults.
    var title: LocalizedStringResource {
        switch self {
        case .standard: LocalizedStringResource("Standard", comment: "Map style: default street map")
        case .satellite: LocalizedStringResource("Satellite", comment: "Map style: satellite imagery")
        case .hybrid: LocalizedStringResource("Hybrid", comment: "Map style: satellite imagery with labels")
        }
    }

    var systemImage: String {
        switch self {
        case .standard: "map"
        case .satellite: "globe.americas"
        case .hybrid: "map.fill"
        }
    }

    /// The MapKit style this option renders as.
    var mapKitStyle: MapKit.MapStyle {
        switch self {
        case .standard: .standard
        case .satellite: .imagery
        case .hybrid: .hybrid
        }
    }
}
