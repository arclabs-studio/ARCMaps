//
//  PlaceMapper.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 18/03/2026.
//

import Foundation

/// Converts `PlaceSearchResult` values into `MapPlace` values for map display.
///
/// `PlaceMapper` provides the bridge between the `PlaceEnrichment` module (search results
/// from Google Places / Apple Maps Server) and the `MapVisualization` module (pins on the map).
///
/// ## FavRes Discover Flow
/// ```swift
/// // 1. Search for restaurants
/// let results = try await viewModel.searchPlaces(query: PlaceSearchQuery(name: "pizza"))
///
/// // 2. User selects a result — convert to MapPlace and add to map
/// let mapPlace = PlaceMapper.toMapPlace(results[0], status: .pending)
/// mapViewModel.addPlace(mapPlace)
/// ```
public enum PlaceMapper {
    /// Converts a search result to a map place with the specified status.
    ///
    /// The first element of `result.types` is used as the `MapPlace` category.
    /// Photos are not included since `PlaceSearchResult` only contains references, not URLs.
    /// Use `PlaceEnrichmentService.getPhotoURL(photoReference:maxWidth:)` to resolve them separately.
    ///
    /// - Parameters:
    ///   - result: The search result to convert.
    ///   - status: The initial status for the new map place (e.g., `.pending` when adding from Discover).
    /// - Returns: A `MapPlace` ready to be displayed on the map.
    public static func toMapPlace(_ result: PlaceSearchResult, status: PlaceStatus) -> MapPlace {
        MapPlace(
            id: result.id,
            name: result.name,
            coordinate: result.coordinate,
            address: result.address,
            category: result.types.first,
            rating: result.rating,
            status: status,
            isFavorite: false,
            visitDate: nil,
            imageURL: nil
        )
    }
}
