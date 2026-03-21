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

struct MapFilterTests {
    // MARK: - Category Filter

    @Test("Matches returns true when category is in filter") func matchesReturnsTrueWhenCategoryInFilter() {
        // Given
        var filter = MapFilter()
        filter.categories = ["Restaurant"]
        let place = MapPlaceFixtures.restaurant

        // When/Then
        #expect(filter.matches(place))
    }

    @Test("Matches returns false when category not in filter") func matchesReturnsFalseWhenCategoryNotInFilter() {
        // Given
        var filter = MapFilter()
        filter.categories = ["Bar"]
        let place = MapPlaceFixtures.restaurant // Category is "Restaurant"

        // When/Then
        #expect(!filter.matches(place))
    }

    @Test("Empty category filter matches any category") func emptyCategoryFilterMatchesAnyCategory() {
        // Given
        var filter = MapFilter()
        filter.categories = []
        let place = MapPlaceFixtures.restaurant

        // When/Then
        #expect(filter.matches(place))
    }

    @Test("Empty category filter matches place with no category") func emptyCategoryFilterMatchesNilCategory() {
        // Given
        let filter = MapFilter.all
        let place = MapPlaceFixtures.noCategory

        // When/Then
        #expect(filter.matches(place))
    }

    @Test("Category filter excludes place with no category") func categoryFilterExcludesNilCategory() {
        // Given
        var filter = MapFilter()
        filter.categories = ["Restaurant"]
        let place = MapPlaceFixtures.noCategory

        // When/Then
        #expect(!filter.matches(place))
    }

    // MARK: - Rating Filter

    @Test("Matches returns true when rating meets minimum") func matchesReturnsTrueWhenRatingMeetsMinimum() {
        // Given
        var filter = MapFilter()
        filter.minRating = 4.0
        let place = MapPlaceFixtures.restaurant // Rating is 4.5

        // When/Then
        #expect(filter.matches(place))
    }

    @Test("Matches returns false when rating below minimum") func matchesReturnsFalseWhenRatingBelowMinimum() {
        // Given
        var filter = MapFilter()
        filter.minRating = 5.0
        let place = MapPlaceFixtures.restaurant // Rating is 4.5

        // When/Then
        #expect(!filter.matches(place))
    }

    @Test("Nil rating filter matches any rating") func nilRatingFilterMatchesAnyRating() {
        // Given
        var filter = MapFilter()
        filter.minRating = nil
        let place = MapPlaceFixtures.restaurant

        // When/Then
        #expect(filter.matches(place))
    }

    // MARK: - All Filter

    @Test("All filter matches every place") func allFilterMatchesEveryPlace() {
        // Given
        let filter = MapFilter.all

        // When/Then
        for place in MapPlaceFixtures.allSamples {
            #expect(filter.matches(place))
        }
    }

    // MARK: - Combined Filters

    @Test("All filter conditions must be met") func allFilterConditionsMustBeMet() {
        // Given
        var filter = MapFilter()
        filter.categories = ["Cafe"]
        filter.minRating = 4.0

        let matchingPlace = MapPlaceFixtures.cafe // Cafe, 4.2 rating
        let wrongCategory = MapPlaceFixtures.restaurant // Restaurant, 4.5 rating

        // When/Then
        #expect(filter.matches(matchingPlace))
        #expect(!filter.matches(wrongCategory))
    }
}
