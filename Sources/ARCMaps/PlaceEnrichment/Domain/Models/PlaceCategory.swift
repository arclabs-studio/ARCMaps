//
//  PlaceCategory.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 28/05/2026.
//

import Foundation

/// Provider-agnostic Point-of-Interest categories for place search filtering.
///
/// Mirrors the most useful subset of categories supported by both Apple MapKit
/// (`MKPointOfInterestCategory`) and Google Places (`primaryType`). Concrete
/// services in the Data layer translate these to provider-specific values.
public enum PlaceCategory: String, Sendable, Hashable, CaseIterable {
    case restaurant
    case cafe
    case bakery
    case brewery
    case winery
    case foodMarket
    case nightlife
}
