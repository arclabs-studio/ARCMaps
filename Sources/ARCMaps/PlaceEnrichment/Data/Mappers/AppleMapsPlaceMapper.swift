//
//  AppleMapsPlaceMapper.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 06/09/2026.
//

import CoreLocation
import Foundation
import MapKit

/// Converts MapKit's `MKMapItem` into ARCMaps' provider-agnostic ``PlaceSearchResult``.
///
/// Both Apple-backed services produce results from `MKMapItem` — ``AppleMapsSearchService``
/// from a text search and ``AppleMapsCompletionService`` from a resolved suggestion — and they
/// must agree on the identifier and the address format, or the same place would arrive with two
/// different ids depending on how the user found it.
enum AppleMapsPlaceMapper {
    /// Builds a search result from a map item.
    ///
    /// - Parameter mapItem: The item returned by `MKLocalSearch`.
    /// - Returns: The mapped result, or `nil` if the item has no name or no coordinate.
    static func searchResult(from mapItem: MKMapItem) -> PlaceSearchResult? {
        guard let name = mapItem.name,
              let coordinate = mapItem.placemark.location?.coordinate
        else {
            return nil
        }

        return PlaceSearchResult(id: stableId(for: mapItem),
                                 provider: .apple,
                                 name: name,
                                 address: formattedAddress(mapItem.placemark),
                                 coordinate: coordinate,
                                 types: [],
                                 rating: nil, // Apple Maps doesn't provide ratings in search
                                 userRatingsTotal: nil,
                                 priceLevel: nil,
                                 photoReferences: [])
    }

    /// Prefer the stable `MKMapItem.Identifier` (iOS 18+) over placemark description,
    /// which is volatile across catalog updates.
    static func stableId(for mapItem: MKMapItem) -> String {
        if #available(iOS 18.0, macOS 15.0, *), let identifier = mapItem.identifier {
            return identifier.rawValue
        }
        return mapItem.placemark.description
    }

    /// Formats a placemark as a single display address line.
    static func formattedAddress(_ placemark: MKPlacemark) -> String? {
        var components: [String] = []

        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        if let subThoroughfare = placemark.subThoroughfare {
            components.append(subThoroughfare)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        if let postalCode = placemark.postalCode {
            components.append(postalCode)
        }

        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}
