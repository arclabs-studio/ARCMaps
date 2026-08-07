//
//  MapClusterTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 07/08/2026.
//

import CoreLocation
import Foundation
import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

struct MapClusterTests {
    // MARK: - Centroid

    @Test("Centroid is the mean of member coordinates") func centroidIsMeanOfMembers() {
        // Given
        let places = [makePlace(id: "a", latitude: 0, longitude: 0),
                      makePlace(id: "b", latitude: 2, longitude: 4),
                      makePlace(id: "c", latitude: 4, longitude: 8)]

        // When
        let cluster = MapCluster(id: "3:0:0", places: places)

        // Then
        #expect(cluster?.coordinate.latitude == 2)
        #expect(cluster?.coordinate.longitude == 4)
    }

    @Test("Centroid of a single place is that place") func centroidOfSinglePlace() {
        // Given
        let place = makePlace(id: "a", latitude: 40.4168, longitude: -3.7038)

        // When
        let cluster = MapCluster(id: "3:0:0", places: [place])

        // Then
        #expect(cluster?.coordinate == place.coordinate)
    }

    @Test("Failable init returns nil for an empty cluster") func failableInitReturnsNilWhenEmpty() {
        // Given/When
        let cluster = MapCluster(id: "3:0:0", places: [])

        // Then
        #expect(cluster == nil)
    }

    @Test("Centroid helper returns nil for no places") func centroidHelperReturnsNilWhenEmpty() {
        // Given/When
        let centroid = MapCluster.centroid(of: [])

        // Then
        #expect(centroid == nil)
    }

    // MARK: - Properties

    @Test("Count reflects the number of members") func countReflectsMembers() {
        // Given
        let places = MapPlaceFixtures.dense(count: 4)

        // When
        let cluster = MapCluster(id: "3:0:0", places: places)

        // Then
        #expect(cluster?.count == 4)
    }

    @Test("Explicit init preserves the supplied centroid") func explicitInitPreservesCoordinate() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 10, longitude: 20)
        let places = MapPlaceFixtures.dense(count: 3)

        // When
        let cluster = MapCluster(id: "3:0:0", coordinate: coordinate, places: places)

        // Then
        #expect(cluster.coordinate == coordinate)
    }

    @Test("Clusters with equal members and id are equal") func equalClustersCompareEqual() {
        // Given
        let places = MapPlaceFixtures.dense(count: 3)

        // When
        let first = MapCluster(id: "3:0:0", places: places)
        let second = MapCluster(id: "3:0:0", places: places)

        // Then
        #expect(first == second)
    }

    // MARK: - MapAnnotationItem

    @Test("Place item id is prefixed to avoid cluster collisions") func placeItemIdIsPrefixed() {
        // Given
        let place = MapPlaceFixtures.restaurant

        // When
        let item = MapAnnotationItem.place(place)

        // Then
        #expect(item.id == "place:\(place.id)")
    }

    @Test("Cluster item id is prefixed to avoid place collisions") func clusterItemIdIsPrefixed() {
        // Given
        let cluster = MapCluster(id: "3:0:0", places: MapPlaceFixtures.dense(count: 3))

        // When
        let item = cluster.map(MapAnnotationItem.cluster)

        // Then
        #expect(item?.id == "cluster:3:0:0")
    }

    @Test("Place item exposes the place coordinate") func placeItemExposesCoordinate() {
        // Given
        let place = MapPlaceFixtures.restaurant

        // When
        let item = MapAnnotationItem.place(place)

        // Then
        #expect(item.coordinate == place.coordinate)
    }

    @Test("Cluster item exposes the cluster centroid") func clusterItemExposesCentroid() {
        // Given
        let places = MapPlaceFixtures.dense(count: 3)

        // When
        let cluster = MapCluster(id: "3:0:0", places: places)
        let item = cluster.map(MapAnnotationItem.cluster)

        // Then
        #expect(item?.coordinate == cluster?.coordinate)
    }

    @Test("Place item reports a single place") func placeItemReportsSinglePlace() {
        // Given
        let place = MapPlaceFixtures.restaurant

        // When
        let item = MapAnnotationItem.place(place)

        // Then
        #expect(item.places == [place])
    }

    @Test("Cluster item reports all members") func clusterItemReportsAllMembers() {
        // Given
        let places = MapPlaceFixtures.dense(count: 4)

        // When
        let cluster = MapCluster(id: "3:0:0", places: places)
        let item = cluster.map(MapAnnotationItem.cluster)

        // Then
        #expect(item?.places == places)
    }

    // MARK: - Helpers

    private func makePlace(id: String, latitude: Double, longitude: Double) -> MapPlace {
        MapPlace(id: id,
                 name: id,
                 coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
}
