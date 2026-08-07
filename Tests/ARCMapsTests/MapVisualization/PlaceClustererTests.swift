//
//  PlaceClustererTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 07/08/2026.
//

import CoreLocation
import Foundation
import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

struct PlaceClustererTests {
    // MARK: - Grouping

    @Test("Places in one cell collapse into a single cluster") func placesInOneCellCollapse() {
        // Given
        let sut = makeSUT()
        let places = MapPlaceFixtures.dense(count: 5)

        // When
        let items = sut.cluster(places, bucket: cityBucket)

        // Then
        #expect(items.count == 1)
        #expect(items.first?.places.count == 5)
    }

    @Test("Places spread across cells stay individual") func spreadPlacesStayIndividual() {
        // Given
        let sut = makeSUT()
        let places = MapPlaceFixtures.spread(count: 4)

        // When
        let items = sut.cluster(places, bucket: cityBucket)

        // Then
        #expect(items.count == 4)
        #expect(items.holdsOnlyPlaces)
    }

    @Test("Zooming in past the cell threshold dissolves a cluster") func zoomingInDissolvesCluster() {
        // Given: dense places are ~11 m apart, below city-zoom cell size
        let sut = makeSUT()
        let places = MapPlaceFixtures.dense(count: 5)

        // When
        let clustered = sut.cluster(places, bucket: cityBucket)
        let dissolved = sut.cluster(places, bucket: streetBucket)

        // Then
        #expect(clustered.count == 1)
        #expect(dissolved.count == 5)
        #expect(dissolved.holdsOnlyPlaces)
    }

    @Test("Cluster centroid is the mean of its members") func clusterCentroidIsMeanOfMembers() {
        // Given
        let sut = makeSUT()
        let places = MapPlaceFixtures.dense(count: 4)
        let expected = MapCluster.centroid(of: places)

        // When
        let items = sut.cluster(places, bucket: cityBucket)

        // Then
        #expect(items.first?.coordinate == expected)
    }

    @Test("Empty input produces no items") func emptyInputProducesNoItems() {
        // Given
        let sut = makeSUT()

        // When
        let items = sut.cluster([], bucket: cityBucket)

        // Then
        #expect(items.isEmpty)
    }

    // MARK: - Minimum Cluster Size

    @Test("A cell below the minimum emits individual places") func cellBelowMinimumEmitsPlaces() {
        // Given: two places in one cell, minimum is three
        let sut = makeSUT()
        let places = MapPlaceFixtures.dense(count: 2)

        // When
        let items = sut.cluster(places, bucket: cityBucket)

        // Then
        #expect(items.count == 2)
        #expect(items.holdsOnlyPlaces)
    }

    @Test("A cell at the minimum forms a cluster") func cellAtMinimumFormsCluster() {
        // Given
        let sut = makeSUT()
        let places = MapPlaceFixtures.dense(count: 3)

        // When
        let items = sut.cluster(places, bucket: cityBucket)

        // Then
        #expect(items.count == 1)
        #expect(items.first?.isPlace == false)
    }

    @Test("Minimum cluster size is clamped to two") func minimumClusterSizeIsClamped() {
        // Given
        let sut = makeSUT(minimumClusterSize: 1)

        // When
        let items = sut.cluster(MapPlaceFixtures.dense(count: 1), bucket: cityBucket)

        // Then
        #expect(sut.minimumClusterSize == 2)
        #expect(items.holdsOnlyPlaces)
    }

    @Test("A higher minimum keeps small groups unclustered") func higherMinimumKeepsSmallGroupsUnclustered() {
        // Given
        let sut = makeSUT(minimumClusterSize: 10)
        let places = MapPlaceFixtures.dense(count: 5)

        // When
        let items = sut.cluster(places, bucket: cityBucket)

        // Then
        #expect(items.count == 5)
        #expect(items.holdsOnlyPlaces)
    }

    // MARK: - Stable Identity

    @Test("Identical input yields identical identifiers") func identicalInputYieldsIdenticalIdentifiers() {
        // Given: the regression that would otherwise re-animate every annotation
        let sut = makeSUT()
        let places = MapPlaceFixtures.dense(count: 5)

        // When
        let first = sut.cluster(places, bucket: cityBucket).map(\.id)
        let second = sut.cluster(places, bucket: cityBucket).map(\.id)

        // Then
        #expect(first == second)
    }

    @Test("Identifiers survive reordering of the input") func identifiersSurviveReordering() {
        // Given
        let sut = makeSUT()
        let places = MapPlaceFixtures.dense(count: 5)

        // When
        let forward = sut.cluster(places, bucket: cityBucket).map(\.id)
        let reversed = sut.cluster(places.reversed(), bucket: cityBucket).map(\.id)

        // Then
        #expect(forward == reversed)
    }

    @Test("The same cell at different zoom levels gets different identifiers")
    func identifiersDifferAcrossZoomLevels() {
        // Given
        let sut = makeSUT()
        let places = MapPlaceFixtures.dense(count: 5)

        // When
        let city = sut.cluster(places, bucket: cityBucket).map(\.id)
        let country = sut.cluster(places, bucket: ZoomBucket(level: 5)).map(\.id)

        // Then
        #expect(city != country)
    }

    // MARK: - Ordering

    @Test("Output order follows first appearance of each cell") func outputFollowsFirstAppearanceOrder() {
        // Given
        let sut = makeSUT()
        let north = MapPlaceFixtures.spread(count: 1, from: CLLocationCoordinate2D(latitude: 50, longitude: 0))
        let south = MapPlaceFixtures.spread(count: 1, from: CLLocationCoordinate2D(latitude: 10, longitude: 0))

        // When
        let items = sut.cluster(north + south, bucket: cityBucket)

        // Then
        #expect(items.first?.coordinate.latitude == 50)
        #expect(items.last?.coordinate.latitude == 10)
    }

    // MARK: - Ungriddable Places

    @Test("A non-finite coordinate is emitted rather than dropped") func nonFinitePlaceIsNotDropped() {
        // Given
        let sut = makeSUT()
        let places = MapPlaceFixtures.dense(count: 3) + [MapPlaceFixtures.nonFiniteCoordinate]

        // When
        let items = sut.cluster(places, bucket: cityBucket)

        // Then: one cluster of three, plus the ungriddable place on its own
        #expect(items.count == 2)
        #expect(items.last?.id == "place:\(MapPlaceFixtures.nonFiniteCoordinate.id)")
    }

    @Test("Ungriddable places sort after clustered ones") func ungriddablePlacesSortLast() {
        // Given
        let sut = makeSUT()
        let places = [MapPlaceFixtures.nonFiniteCoordinate] + MapPlaceFixtures.dense(count: 3)

        // When
        let items = sut.cluster(places, bucket: cityBucket)

        // Then
        #expect(items.first?.isPlace == false)
        #expect(items.last?.isPlace == true)
    }

    // MARK: - Helpers

    /// A bucket whose cells span one degree — coarse enough that the dense fixture shares a cell.
    private var cityBucket: ZoomBucket {
        ZoomBucket(level: 3)
    }

    /// The tightest supported bucket, whose cells are finer than the dense fixture's spacing.
    private var streetBucket: ZoomBucket {
        ZoomBucket(level: -11)
    }

    private func makeSUT(minimumClusterSize: Int = 3) -> PlaceClusterer {
        PlaceClusterer(minimumClusterSize: minimumClusterSize)
    }
}

// MARK: - Test Support

extension MapAnnotationItem {
    fileprivate var isPlace: Bool {
        if case .place = self { return true }
        return false
    }
}

extension [MapAnnotationItem] {
    /// Whether every item is a standalone place rather than a cluster.
    ///
    /// Kept out of the `#expect` call: the macro expansion loses `allSatisfy`'s
    /// `rethrows` inference and demands a `try` the call does not need.
    fileprivate var holdsOnlyPlaces: Bool {
        allSatisfy(\.isPlace)
    }
}
