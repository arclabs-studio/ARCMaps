//
//  PlaceSearchResultFixtures.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation
@testable import ARCMaps

public enum PlaceSearchResultFixtures {
    public static var sampleRestaurant: PlaceSearchResult {
        PlaceSearchResult(
            id: "place_1",
            provider: .google,
            name: "La Taverna",
            address: "Calle Mayor 15, Madrid",
            coordinate: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
            types: ["restaurant", "food"],
            rating: 4.5,
            userRatingsTotal: 120,
            priceLevel: 2,
            photoReferences: ["photo_ref_1", "photo_ref_2"]
        )
    }

    public static var sampleCafe: PlaceSearchResult {
        PlaceSearchResult(
            id: "place_2",
            provider: .google,
            name: "El Café Central",
            address: "Gran Vía 20, Madrid",
            coordinate: CLLocationCoordinate2D(latitude: 40.4200, longitude: -3.7050),
            types: ["cafe", "food"],
            rating: 4.2,
            userRatingsTotal: 85,
            priceLevel: 1,
            photoReferences: ["photo_ref_3"]
        )
    }

    public static var sampleBar: PlaceSearchResult {
        PlaceSearchResult(
            id: "place_3",
            provider: .apple,
            name: "El Mesón",
            address: "Calle Alcalá 30, Madrid",
            coordinate: CLLocationCoordinate2D(latitude: 40.4180, longitude: -3.7020),
            types: ["bar", "nightlife"],
            rating: 4.0,
            userRatingsTotal: 60,
            priceLevel: 2,
            photoReferences: []
        )
    }

    public static var allSamples: [PlaceSearchResult] {
        [sampleRestaurant, sampleCafe, sampleBar]
    }
}
