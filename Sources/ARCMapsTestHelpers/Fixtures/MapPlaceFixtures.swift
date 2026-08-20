//
//  MapPlaceFixtures.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation
@testable import ARCMaps

public enum MapPlaceFixtures {
    public static var restaurant: MapPlace {
        MapPlace(id: "map_place_1",
                 name: "La Taverna",
                 coordinate: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
                 address: "Calle Mayor 15, Madrid",
                 category: "Restaurant",
                 rating: 4.5,
                 imageURL: URL(string: "https://example.com/image1.jpg"))
    }

    public static var cafe: MapPlace {
        MapPlace(id: "map_place_2",
                 name: "El Café Central",
                 coordinate: CLLocationCoordinate2D(latitude: 40.4200, longitude: -3.7050),
                 address: "Gran Vía 20, Madrid",
                 category: "Cafe",
                 rating: 4.2,
                 imageURL: URL(string: "https://example.com/image2.jpg"))
    }

    public static var bar: MapPlace {
        MapPlace(id: "map_place_3",
                 name: "El Mesón",
                 coordinate: CLLocationCoordinate2D(latitude: 40.4180, longitude: -3.7020),
                 address: "Calle Alcalá 30, Madrid",
                 category: "Bar",
                 rating: 4.0,
                 imageURL: nil)
    }

    public static var noCategory: MapPlace {
        MapPlace(id: "map_place_5",
                 name: "Unknown Spot",
                 coordinate: CLLocationCoordinate2D(latitude: 40.4190, longitude: -3.7030))
    }

    public static var allSamples: [MapPlace] {
        [restaurant, cafe, bar]
    }
}
