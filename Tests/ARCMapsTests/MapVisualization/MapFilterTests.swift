//
//  MapFilterTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation
import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

@Suite("MapFilter Tests")
struct MapFilterTests {
    // MARK: - Status Filter

    @Test("Matches returns true when status is in filter")
    func matchesReturnsTrueWhenStatusInFilter() {
        // Given
        var filter = MapFilter()
        filter.statuses = [.wishlist]
        let place = MapPlaceFixtures.wishlistRestaurant

        // When/Then
        #expect(filter.matches(place))
    }

    @Test("Matches returns false when status not in filter")
    func matchesReturnsFalseWhenStatusNotInFilter() {
        // Given
        var filter = MapFilter()
        filter.statuses = [.visited]
        let place = MapPlaceFixtures.wishlistRestaurant

        // When/Then
        #expect(!filter.matches(place))
    }

    @Test("Default filter matches all statuses")
    func defaultFilterMatchesAllStatuses() {
        // Given
        let filter = MapFilter.all
        let wishlist = MapPlaceFixtures.wishlistRestaurant
        let visited = MapPlaceFixtures.visitedCafe

        // When/Then
        #expect(filter.matches(wishlist))
        #expect(filter.matches(visited))
    }

    // MARK: - Category Filter

    @Test("Matches returns true when category is in filter")
    func matchesReturnsTrueWhenCategoryInFilter() {
        // Given
        var filter = MapFilter()
        filter.categories = ["Restaurant"]
        let place = MapPlaceFixtures.wishlistRestaurant

        // When/Then
        #expect(filter.matches(place))
    }

    @Test("Matches returns false when category not in filter")
    func matchesReturnsFalseWhenCategoryNotInFilter() {
        // Given
        var filter = MapFilter()
        filter.categories = ["Bar"]
        let place = MapPlaceFixtures.wishlistRestaurant // Category is "Restaurant"

        // When/Then
        #expect(!filter.matches(place))
    }

    @Test("Empty category filter matches any category")
    func emptyCategoryFilterMatchesAnyCategory() {
        // Given
        var filter = MapFilter()
        filter.categories = []
        let place = MapPlaceFixtures.wishlistRestaurant

        // When/Then
        #expect(filter.matches(place))
    }

    // MARK: - Rating Filter

    @Test("Matches returns true when rating meets minimum")
    func matchesReturnsTrueWhenRatingMeetsMinimum() {
        // Given
        var filter = MapFilter()
        filter.minRating = 4.0
        let place = MapPlaceFixtures.wishlistRestaurant // Rating is 4.5

        // When/Then
        #expect(filter.matches(place))
    }

    @Test("Matches returns false when rating below minimum")
    func matchesReturnsFalseWhenRatingBelowMinimum() {
        // Given
        var filter = MapFilter()
        filter.minRating = 5.0
        let place = MapPlaceFixtures.wishlistRestaurant // Rating is 4.5

        // When/Then
        #expect(!filter.matches(place))
    }

    @Test("Nil rating filter matches any rating")
    func nilRatingFilterMatchesAnyRating() {
        // Given
        var filter = MapFilter()
        filter.minRating = nil
        let place = MapPlaceFixtures.wishlistRestaurant

        // When/Then
        #expect(filter.matches(place))
    }

    // MARK: - Date Range Filter

    @Test("Matches returns true when visit date is in range")
    func matchesReturnsTrueWhenVisitDateInRange() {
        // Given - create a place with a known visit date
        let now = Date()
        let oneMonthAgo = now.addingTimeInterval(-30 * 24 * 3600)
        let oneDayFromNow = now.addingTimeInterval(24 * 3600)
        var filter = MapFilter()
        filter.dateRange = DateRange(start: oneMonthAgo, end: oneDayFromNow)

        // Create a place with visit date = now (which is in range)
        let place = MapPlace(
            id: "test",
            name: "Test Place",
            coordinate: MapPlaceFixtures.visitedCafe.coordinate,
            status: .visited,
            visitDate: now
        )

        // When/Then
        #expect(filter.matches(place))
    }

    @Test("Date filter is ignored when place has no visit date")
    func dateFilterIgnoredWhenNoVisitDate() {
        // Given
        let now = Date()
        let oneMonthAgo = now.addingTimeInterval(-30 * 24 * 3600)
        var filter = MapFilter()
        filter.dateRange = DateRange(start: oneMonthAgo, end: now)
        let place = MapPlaceFixtures.wishlistRestaurant // No visit date

        // When/Then
        #expect(filter.matches(place))
    }

    // MARK: - Combined Filters

    @Test("All filter conditions must be met")
    func allFilterConditionsMustBeMet() {
        // Given
        var filter = MapFilter()
        filter.statuses = [.visited]
        filter.categories = ["Cafe"]
        filter.minRating = 4.0

        let matchingPlace = MapPlaceFixtures.visitedCafe // Visited, Cafe, 4.2 rating
        let wrongStatus = MapPlaceFixtures.wishlistRestaurant // Wishlist, Restaurant, 4.5 rating

        // When/Then
        #expect(filter.matches(matchingPlace))
        #expect(!filter.matches(wrongStatus))
    }
}

// MARK: - DateRange Tests

@Suite("DateRange Tests")
struct DateRangeTests {
    @Test("Contains returns true for date in range")
    func containsReturnsTrueForDateInRange() {
        // Given
        let start = Date().addingTimeInterval(-86400) // Yesterday
        let end = Date().addingTimeInterval(86400) // Tomorrow
        let range = DateRange(start: start, end: end)

        // When/Then
        #expect(range.contains(Date()))
    }

    @Test("Contains returns false for date before range")
    func containsReturnsFalseForDateBeforeRange() {
        // Given
        let start = Date()
        let end = Date().addingTimeInterval(86400)
        let range = DateRange(start: start, end: end)
        let beforeStart = Date().addingTimeInterval(-86400)

        // When/Then
        #expect(!range.contains(beforeStart))
    }

    @Test("Contains returns false for date after range")
    func containsReturnsFalseForDateAfterRange() {
        // Given
        let start = Date().addingTimeInterval(-86400)
        let end = Date()
        let range = DateRange(start: start, end: end)
        let afterEnd = Date().addingTimeInterval(86400)

        // When/Then
        #expect(!range.contains(afterEnd))
    }

    @Test("Contains returns true for date at start boundary")
    func containsReturnsTrueForDateAtStartBoundary() {
        // Given
        let start = Date()
        let end = Date().addingTimeInterval(86400)
        let range = DateRange(start: start, end: end)

        // When/Then
        #expect(range.contains(start))
    }

    @Test("Contains returns true for date at end boundary")
    func containsReturnsTrueForDateAtEndBoundary() {
        // Given
        let start = Date().addingTimeInterval(-86400)
        let end = Date()
        let range = DateRange(start: start, end: end)

        // When/Then
        #expect(range.contains(end))
    }
}
