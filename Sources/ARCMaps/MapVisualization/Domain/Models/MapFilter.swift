//
//  MapFilter.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// A configurable filter for narrowing down map places based on various criteria.
///
/// `MapFilter` allows filtering places by status, category, minimum rating, and date range.
/// All filter conditions are combined with AND logic - a place must satisfy all active
/// filters to match.
///
/// ## Example
/// ```swift
/// // Filter to show only visited restaurants with rating >= 4.0
/// let filter = MapFilter(
///     statuses: [.visited],
///     categories: ["restaurant"],
///     minRating: 4.0
/// )
///
/// let matchingPlaces = allPlaces.filter { filter.matches($0) }
/// ```
public struct MapFilter: Sendable, Equatable {
    /// The set of place statuses to include. Places with statuses not in this set are excluded.
    public var statuses: Set<PlaceStatus>

    /// The set of categories to include. If empty, all categories are included.
    public var categories: Set<String>

    /// The minimum rating threshold. Places with ratings below this value are excluded.
    public var minRating: Double?

    /// The date range for filtering by visit date. Places visited outside this range are excluded.
    public var dateRange: DateRange?

    /// Creates a new map filter with the specified criteria.
    ///
    /// - Parameters:
    ///   - statuses: The place statuses to include. Defaults to all statuses.
    ///   - categories: The categories to include. Empty means all categories.
    ///   - minRating: The minimum rating threshold, or `nil` to disable rating filtering.
    ///   - dateRange: The date range for visit dates, or `nil` to disable date filtering.
    public init(
        statuses: Set<PlaceStatus> = Set(PlaceStatus.allCases),
        categories: Set<String> = [],
        minRating: Double? = nil,
        dateRange: DateRange? = nil
    ) {
        self.statuses = statuses
        self.categories = categories
        self.minRating = minRating
        self.dateRange = dateRange
    }

    /// Determines whether a place matches all active filter criteria.
    ///
    /// A place matches if it satisfies all of the following conditions:
    /// - Its status is in the `statuses` set
    /// - Its category is in the `categories` set (or categories is empty)
    /// - Its rating meets or exceeds `minRating` (if set)
    /// - Its visit date falls within `dateRange` (if both are set)
    ///
    /// - Parameter place: The place to evaluate against the filter criteria.
    /// - Returns: `true` if the place matches all active filters, `false` otherwise.
    public func matches(_ place: MapPlace) -> Bool {
        // Status filter
        guard statuses.contains(place.status) else { return false }

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

        // Date range filter
        if let dateRange, let visitDate = place.visitDate {
            guard dateRange.contains(visitDate) else { return false }
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

/// A date range defined by start and end dates, inclusive.
///
/// `DateRange` represents a closed interval of dates, commonly used for filtering
/// places by their visit date.
///
/// ## Example
/// ```swift
/// // Create a range for the current month
/// let calendar = Calendar.current
/// let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
/// let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
/// let thisMonth = DateRange(start: startOfMonth, end: endOfMonth)
///
/// if thisMonth.contains(visitDate) {
///     print("Visited this month")
/// }
/// ```
public struct DateRange: Sendable, Equatable {
    /// The start date of the range (inclusive).
    public let start: Date

    /// The end date of the range (inclusive).
    public let end: Date

    /// Creates a new date range with the specified bounds.
    ///
    /// - Parameters:
    ///   - start: The start date of the range (inclusive).
    ///   - end: The end date of the range (inclusive).
    /// - Note: No validation is performed to ensure `start <= end`.
    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }

    /// Determines whether a date falls within this range.
    ///
    /// - Parameter date: The date to check.
    /// - Returns: `true` if `date` is between `start` and `end` (inclusive), `false` otherwise.
    public func contains(_ date: Date) -> Bool {
        date >= start && date <= end
    }
}
