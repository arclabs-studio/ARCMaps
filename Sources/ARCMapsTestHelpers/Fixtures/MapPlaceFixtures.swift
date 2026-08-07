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

    // MARK: - Clustering

    /// Builds `count` places packed tightly enough to share a grid cell at city zoom.
    ///
    /// Spacing is one ten-thousandth of a degree (~11 m), far below the smallest
    /// supported cell size, so these always collapse into a single cluster.
    public static func dense(count: Int,
                             around center: CLLocationCoordinate2D = madrid) -> [MapPlace] {
        (0 ..< count).map { index in
            MapPlace(id: "dense_\(index)",
                     name: "Dense \(index)",
                     coordinate: CLLocationCoordinate2D(latitude: center.latitude + Double(index) * 0.0001,
                                                        longitude: center.longitude + Double(index) * 0.0001),
                     category: "Restaurant")
        }
    }

    /// Builds `count` places spaced far enough apart to occupy separate grid cells.
    ///
    /// Spacing is two degrees of latitude (~222 km), which exceeds the cell size of
    /// every bucket up to country zoom.
    public static func spread(count: Int,
                              from origin: CLLocationCoordinate2D = madrid) -> [MapPlace] {
        (0 ..< count).map { index in
            MapPlace(id: "spread_\(index)",
                     name: "Spread \(index)",
                     coordinate: CLLocationCoordinate2D(latitude: origin.latitude + Double(index) * 2,
                                                        longitude: origin.longitude),
                     category: "Restaurant")
        }
    }

    /// A place whose coordinate is not finite and therefore cannot be placed on the grid.
    public static var nonFiniteCoordinate: MapPlace {
        MapPlace(id: "map_place_nan",
                 name: "Nowhere",
                 coordinate: CLLocationCoordinate2D(latitude: .nan, longitude: .nan))
    }

    /// Central Madrid — the anchor for the clustering fixtures above.
    public static var madrid: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
    }
}
