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
}
