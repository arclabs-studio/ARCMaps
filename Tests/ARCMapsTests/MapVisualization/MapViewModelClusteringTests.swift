//
//  MapViewModelClusteringTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 07/08/2026.
//

import CoreLocation
import MapKit
import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

@Suite(.serialized)
@MainActor struct MapViewModelClusteringTests {
    let mockLocationService: MockLocationService
    let sut: MapViewModel

    init() async throws {
        mockLocationService = MockLocationService()
        sut = MapViewModel(locationService: mockLocationService)
    }

    // MARK: - Building Annotation Items

    @Test("Setting places populates annotation items") func setPlacesPopulatesAnnotationItems() {
        // Given
        let places = MapPlaceFixtures.spread(count: 4)

        // When
        sut.setPlaces(places)

        // Then
        #expect(sut.annotationItems.count == 4)
    }

    @Test("Places sharing a cell collapse into one cluster") func placesSharingCellCollapse() {
        // Given
        sut.updateCameraSpan(countrySpan)

        // When
        sut.setPlaces(MapPlaceFixtures.dense(count: 5))

        // Then
        #expect(sut.annotationItems.count == 1)
        #expect(sut.annotationItems.first?.places.count == 5)
    }

    @Test("Clustering is enabled by default") func clusteringIsEnabledByDefault() {
        // Then
        #expect(sut.clusteringEnabled)
    }

    @Test("Annotation titles are hidden by default") func annotationTitlesAreHiddenByDefault() {
        // Then
        #expect(!sut.showsAnnotationTitles)
    }

    // MARK: - Toggling Clustering

    @Test("Disabling clustering emits one item per filtered place") func disablingClusteringEmitsOneItemPerPlace() {
        // Given
        sut.updateCameraSpan(countrySpan)
        sut.setPlaces(MapPlaceFixtures.dense(count: 5))

        // When
        sut.clusteringEnabled = false

        // Then
        #expect(sut.annotationItems.count == 5)
    }

    @Test("Re-enabling clustering restores clusters") func reEnablingClusteringRestoresClusters() {
        // Given
        sut.updateCameraSpan(countrySpan)
        sut.setPlaces(MapPlaceFixtures.dense(count: 5))
        sut.clusteringEnabled = false

        // When
        sut.clusteringEnabled = true

        // Then
        #expect(sut.annotationItems.count == 1)
    }

    @Test("Reassigning the same clustering value leaves items untouched") func reassigningSameValueLeavesItemsUntouched() {
        // Given
        sut.updateCameraSpan(countrySpan)
        sut.setPlaces(MapPlaceFixtures.dense(count: 5))
        let before = sut.annotationItems

        // When
        sut.clusteringEnabled = true

        // Then
        #expect(sut.annotationItems == before)
    }

    // MARK: - Camera Changes

    @Test("Camera change inside the current bucket keeps items stable") func cameraChangeInsideBucketKeepsItemsStable() {
        // Given
        sut.updateCameraSpan(countrySpan)
        sut.setPlaces(MapPlaceFixtures.dense(count: 5))
        let before = sut.annotationItems

        // When: a span that snaps to the same zoom bucket
        sut.updateCameraSpan(MKCoordinateSpan(latitudeDelta: 12, longitudeDelta: 12))

        // Then
        #expect(sut.annotationItems == before)
    }

    @Test("Crossing a bucket boundary re-clusters") func crossingBucketBoundaryReClusters() {
        // Given
        sut.updateCameraSpan(countrySpan)
        sut.setPlaces(MapPlaceFixtures.dense(count: 5))
        #expect(sut.annotationItems.count == 1)

        // When: zoom in far enough that the dense fixture separates
        sut.updateCameraSpan(streetSpan)

        // Then
        #expect(sut.annotationItems.count == 5)
    }

    @Test("Cluster identifiers are stable across repeated camera changes") func clusterIdentifiersAreStable() {
        // Given
        sut.updateCameraSpan(countrySpan)
        sut.setPlaces(MapPlaceFixtures.dense(count: 5))
        let first = sut.annotationItems.map(\.id)

        // When: zoom away and back
        sut.updateCameraSpan(streetSpan)
        sut.updateCameraSpan(countrySpan)

        // Then
        #expect(sut.annotationItems.map(\.id) == first)
    }

    // MARK: - Filtering

    @Test("Applying a filter rebuilds annotation items") func applyingFilterRebuildsAnnotationItems() {
        // Given
        sut.setPlaces(MapPlaceFixtures.allSamples)
        var filter = MapFilter()
        filter.categories = ["Restaurant"]

        // When
        sut.updateFilter(filter)

        // Then
        let categories = sut.annotationItems.flatMap(\.places).compactMap(\.category)

        #expect(sut.annotationItems.count == sut.filteredPlaces.count)
        #expect(Set(categories) == ["Restaurant"])
    }

    // MARK: - Cluster Selection

    @Test("Selecting a cluster fits its members in the camera") func selectingClusterFitsMembers() {
        // Given
        let places = MapPlaceFixtures.spread(count: 3)
        guard let cluster = MapCluster(id: "3:0:0", places: places) else {
            Issue.record("Expected a cluster from a non-empty fixture")
            return
        }

        // When
        sut.selectCluster(cluster)

        // Then
        #expect(sut.cameraPosition.region != nil)
    }

    @Test("Selecting a cluster does not open the place sheet") func selectingClusterDoesNotOpenSheet() {
        // Given
        guard let cluster = MapCluster(id: "3:0:0", places: MapPlaceFixtures.dense(count: 3)) else {
            Issue.record("Expected a cluster from a non-empty fixture")
            return
        }

        // When
        sut.selectCluster(cluster)

        // Then
        #expect(sut.selectedPlace == nil)
    }

    @Test("Selecting an empty cluster leaves the camera untouched") func selectingEmptyClusterLeavesCameraUntouched() {
        // Given: an explicitly constructed empty cluster, which has no fittable region
        let cluster = MapCluster(id: "3:0:0",
                                 coordinate: MapPlaceFixtures.madrid,
                                 places: [])

        // When
        sut.selectCluster(cluster)

        // Then
        #expect(sut.cameraPosition.region == nil)
    }

    // MARK: - Custom Clusterer

    @Test("A custom minimum cluster size is honoured") func customMinimumClusterSizeIsHonoured() {
        // Given
        let strict = MapViewModel(locationService: mockLocationService,
                                  clusterer: PlaceClusterer(minimumClusterSize: 10))
        strict.updateCameraSpan(countrySpan)

        // When
        strict.setPlaces(MapPlaceFixtures.dense(count: 5))

        // Then
        #expect(strict.annotationItems.count == 5)
    }

    // MARK: - Helpers

    /// A span that snaps to a bucket with one-degree cells, coarse enough to cluster the dense fixture.
    private var countrySpan: MKCoordinateSpan {
        MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    }

    /// The tightest supported span, whose cells are finer than the dense fixture's spacing.
    private var streetSpan: MKCoordinateSpan {
        MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
    }
}
