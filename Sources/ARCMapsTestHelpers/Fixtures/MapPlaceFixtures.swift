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
    public static var pendingRestaurant: MapPlace {
        MapPlace(
            id: "map_place_1",
            name: "La Taverna",
            coordinate: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
            address: "Calle Mayor 15, Madrid",
            category: "Restaurant",
            rating: 4.5,
            status: .pending,
            isFavorite: false,
            visitDate: nil,
            imageURL: URL(string: "https://example.com/image1.jpg")
        )
    }

    /// Backward-compatible alias for `pendingRestaurant`.
    public static var wishlistRestaurant: MapPlace { pendingRestaurant }

    public static var visitedCafe: MapPlace {
        MapPlace(
            id: "map_place_2",
            name: "El Café Central",
            coordinate: CLLocationCoordinate2D(latitude: 40.4200, longitude: -3.7050),
            address: "Gran Vía 20, Madrid",
            category: "Cafe",
            rating: 4.2,
            status: .visited,
            isFavorite: false,
            visitDate: Date(),
            imageURL: URL(string: "https://example.com/image2.jpg")
        )
    }

    public static var visitedBar: MapPlace {
        MapPlace(
            id: "map_place_3",
            name: "El Mesón",
            coordinate: CLLocationCoordinate2D(latitude: 40.4180, longitude: -3.7020),
            address: "Calle Alcalá 30, Madrid",
            category: "Bar",
            rating: 4.0,
            status: .visited,
            isFavorite: false,
            visitDate: Date().addingTimeInterval(-86400 * 7), // 1 week ago
            imageURL: nil
        )
    }

    public static var favoriteCafe: MapPlace {
        MapPlace(
            id: "map_place_4",
            name: "Café Favorito",
            coordinate: CLLocationCoordinate2D(latitude: 40.4210, longitude: -3.7060),
            address: "Paseo de la Castellana 5, Madrid",
            category: "Cafe",
            rating: 4.8,
            status: .visited,
            isFavorite: true,
            visitDate: Date().addingTimeInterval(-86400 * 3), // 3 days ago
            imageURL: URL(string: "https://example.com/image4.jpg")
        )
    }

    public static var allSamples: [MapPlace] {
        [pendingRestaurant, visitedCafe, visitedBar]
    }

    public static var allSamplesWithFavorite: [MapPlace] {
        [pendingRestaurant, visitedCafe, visitedBar, favoriteCafe]
    }

    public static var pendingOnly: [MapPlace] {
        [pendingRestaurant]
    }

    /// Backward-compatible alias for `pendingOnly`.
    public static var wishlistOnly: [MapPlace] { pendingOnly }

    public static var visitedOnly: [MapPlace] {
        [visitedCafe, visitedBar]
    }

    public static var favoritesOnly: [MapPlace] {
        [favoriteCafe]
    }
}
