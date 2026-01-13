//
//  MapFilter.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// Filter options for map places
public struct MapFilter: Sendable, Equatable {
    public var statuses: Set<PlaceStatus>
    public var categories: Set<String>
    public var minRating: Double?
    public var dateRange: DateRange?

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

    /// Check if a place matches the filter
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

    /// Reset to default (show all)
    public static var all: MapFilter {
        MapFilter()
    }
}

public struct DateRange: Sendable, Equatable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }

    public func contains(_ date: Date) -> Bool {
        date >= start && date <= end
    }
}
