//
//  SampleData.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import ARCMaps
import CoreLocation
import Foundation

/// Sample places for demonstrating ARCMaps features.
///
/// Contains a collection of places in Madrid, Spain, with various categories and ratings.
enum SampleData {
    /// Sample places in Madrid representing different categories.
    static let places: [MapPlace] = [MapPlace(id: "1",
                                              name: "La Barraca",
                                              coordinate: CLLocationCoordinate2D(latitude: 40.4200, longitude: -3.7025),
                                              address: "Calle de la Reina 29, Madrid",
                                              category: "restaurant",
                                              rating: 4.7),
                                     MapPlace(id: "2",
                                              name: "Sobrino de Botin",
                                              coordinate: CLLocationCoordinate2D(latitude: 40.4133, longitude: -3.7080),
                                              address: "Calle Cuchilleros 17, Madrid",
                                              category: "restaurant",
                                              rating: 4.5),
                                     MapPlace(id: "3",
                                              name: "Toma Cafe",
                                              coordinate: CLLocationCoordinate2D(latitude: 40.4280, longitude: -3.7050),
                                              address: "Calle de la Palma 49, Madrid",
                                              category: "cafe",
                                              rating: 4.8),
                                     MapPlace(id: "4",
                                              name: "El Club Allard",
                                              coordinate: CLLocationCoordinate2D(latitude: 40.4230, longitude: -3.7120),
                                              address: "Calle Ferraz 2, Madrid",
                                              category: "restaurant",
                                              rating: 4.9),
                                     MapPlace(id: "5",
                                              name: "Mercado de San Miguel",
                                              coordinate: CLLocationCoordinate2D(latitude: 40.4152, longitude: -3.7089),
                                              address: "Plaza de San Miguel, Madrid",
                                              category: "market",
                                              rating: 4.3),
                                     MapPlace(id: "6",
                                              name: "Cafe de Oriente",
                                              coordinate: CLLocationCoordinate2D(latitude: 40.4180, longitude: -3.7140),
                                              address: "Plaza de Oriente 2, Madrid",
                                              category: "cafe",
                                              rating: 4.4),
                                     MapPlace(id: "7",
                                              name: "StreetXO",
                                              coordinate: CLLocationCoordinate2D(latitude: 40.4195, longitude: -3.6960),
                                              address: "Calle Serrano 52, Madrid",
                                              category: "restaurant",
                                              rating: 4.2),
                                     MapPlace(id: "8",
                                              name: "Federal Cafe",
                                              coordinate: CLLocationCoordinate2D(latitude: 40.4260, longitude: -3.7000),
                                              address: "Plaza de las Comendadoras 9, Madrid",
                                              category: "cafe",
                                              rating: 4.6),
                                     MapPlace(id: "9",
                                              name: "Casa Lucio",
                                              coordinate: CLLocationCoordinate2D(latitude: 40.4125, longitude: -3.7095),
                                              address: "Calle Cava Baja 35, Madrid",
                                              category: "restaurant",
                                              rating: 4.1),
                                     MapPlace(id: "10",
                                              name: "Chocolateria San Gines",
                                              coordinate: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7063),
                                              address: "Pasadizo de San Gines 5, Madrid",
                                              category: "cafe",
                                              rating: 4.0)]

    /// All unique categories from the sample places.
    static var categories: [String] {
        Array(Set(places.compactMap(\.category))).sorted()
    }

    // MARK: - Clustering

    /// Spanish cities used as cluster centres in the clustering demo.
    private static let cities: [(name: String, coordinate: CLLocationCoordinate2D)] =
        [("Madrid", CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)),
         ("Barcelona", CLLocationCoordinate2D(latitude: 41.3874, longitude: 2.1686)),
         ("Valencia", CLLocationCoordinate2D(latitude: 39.4699, longitude: -0.3763)),
         ("Sevilla", CLLocationCoordinate2D(latitude: 37.3891, longitude: -5.9845)),
         ("Bilbao", CLLocationCoordinate2D(latitude: 43.2630, longitude: -2.9350))]

    /// A country-wide dataset dense enough to show clustering in action.
    ///
    /// Each city gets a differently sized cluster, so zooming out produces bubbles of
    /// visibly different weight and zooming in dissolves them into individual pins.
    static let clusteredPlaces: [MapPlace] = cities.enumerated().flatMap { cityIndex, city in
        let count = 4 + cityIndex * 3

        return (0 ..< count).map { index in
            MapPlace(id: "\(city.name.lowercased())_\(index)",
                     name: "\(city.name) spot \(index + 1)",
                     coordinate: CLLocationCoordinate2D(latitude: city.coordinate.latitude
                         + Double(index % 4) * 0.004,
                         longitude: city.coordinate.longitude
                             + Double(index / 4) * 0.004),
                     address: city.name,
                     category: categories[index % categories.count],
                     rating: 3.5 + Double(index % 4) * 0.4)
        }
    }
}
