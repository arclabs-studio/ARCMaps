//
//  MapFilter.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// A configurable filter for narrowing down map places based on various criteria.
///
/// `MapFilter` allows filtering places by category and minimum rating.
/// All filter conditions are combined with AND logic — a place must satisfy all
/// active filters to match.
///
/// ## Example
/// ```swift
/// // Filter to show only cafes with rating >= 4.0
/// let filter = MapFilter(
///     categories: ["cafe"],
///     minRating: 4.0
/// )
///
/// let matchingPlaces = allPlaces.filter { filter.matches($0) }
/// ```
public struct MapFilter: Sendable, Equatable {
    /// The set of categories to include. If empty, all categories are included.
    public var categories: Set<String>

    /// The minimum rating threshold. Places with ratings below this value are excluded.
    public var minRating: Double?

    /// Creates a new map filter with the specified criteria.
    ///
    /// - Parameters:
    ///   - categories: The categories to include. Empty means all categories.
    ///   - minRating: The minimum rating threshold, or `nil` to disable rating filtering.
    public init(categories: Set<String> = [],
                minRating: Double? = nil) {
        self.categories = categories
        self.minRating = minRating
    }

    /// Determines whether a place matches all active filter criteria.
    ///
    /// A place matches if it satisfies all of the following conditions:
    /// - Its category is in the `categories` set (or categories is empty)
    /// - Its rating meets or exceeds `minRating` (if set)
    ///
    /// - Parameter place: The place to evaluate against the filter criteria.
    /// - Returns: `true` if the place matches all active filters, `false` otherwise.
    public func matches(_ place: MapPlace) -> Bool {
        // Category filter
        if !categories.isEmpty {
            guard let category = place.category, categories.contains(category) else {
                return false
            }
        }

        // Rating filter
        if let minRating {
            guard let rating = place.rating, rating >= minRating else {
                return false
            }
        }

        return true
    }

    /// A filter that matches all places without any restrictions.
    ///
    /// Use this to reset filters to their default state.
    ///
    /// ## Example
    /// ```swift
    /// viewModel.filter = .all  // Show all places
    /// ```
    public static var all: MapFilter {
        MapFilter()
    }
}
