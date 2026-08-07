//
//  ZoomBucketTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 07/08/2026.
//

import CoreLocation
import Foundation
import Testing
@testable import ARCMaps

struct ZoomBucketTests {
    // MARK: - Bucketing

    @Test("Camera span snaps to a power-of-two rung") func spanSnapsToRung() {
        // Given/When
        let bucket = ZoomBucket(latitudeDelta: 10)

        // Then: floor(log2(10)) == 3
        #expect(bucket.level == 3)
    }

    @Test("Spans inside one rung produce the same bucket") func spansInsideRungShareBucket() {
        // Given
        let lower = ZoomBucket(latitudeDelta: 8)
        let upper = ZoomBucket(latitudeDelta: 15.9)

        // When/Then
        #expect(lower == upper)
    }

    @Test("Crossing a rung boundary produces a different bucket") func crossingRungChangesBucket() {
        // Given
        let inside = ZoomBucket(latitudeDelta: 15.9)
        let beyond = ZoomBucket(latitudeDelta: 16.1)

        // When/Then
        #expect(inside != beyond)
    }

    @Test("Span below the supported floor clamps to the closest bucket") func spanBelowFloorClamps() {
        // Given
        let tiny = ZoomBucket(latitudeDelta: 0.0000001)
        let floorSpan = ZoomBucket(latitudeDelta: 0.0005)

        // When/Then
        #expect(tiny == floorSpan)
    }

    @Test("Span above the supported ceiling clamps to the closest bucket") func spanAboveCeilingClamps() {
        // Given
        let huge = ZoomBucket(latitudeDelta: 10000)
        let ceilingSpan = ZoomBucket(latitudeDelta: 180)

        // When/Then
        #expect(huge == ceilingSpan)
    }

    @Test("Zero and negative spans clamp rather than producing an invalid grid") func degenerateSpansClamp() {
        // Given
        let zero = ZoomBucket(latitudeDelta: 0)
        let negative = ZoomBucket(latitudeDelta: -5)
        let floorSpan = ZoomBucket(latitudeDelta: 0.0005)

        // When/Then
        #expect(zero == floorSpan)
        #expect(negative == floorSpan)
    }

    @Test("Non-finite span falls back to the widest bucket") func nonFiniteSpanFallsBack() {
        // Given
        let notANumber = ZoomBucket(latitudeDelta: .nan)
        let widest = ZoomBucket(latitudeDelta: 180)

        // When/Then
        #expect(notANumber == widest)
    }

    // MARK: - Cell Size

    @Test("Cell size divides the rung span into a fixed number of cells") func cellSizeDividesRung() {
        // Given
        let bucket = ZoomBucket(level: 3)

        // When/Then: 2^3 / 8 == 1 degree
        #expect(bucket.cellSizeDegrees == 1)
    }

    @Test("Zooming in one rung halves the cell size") func zoomingInHalvesCellSize() {
        // Given
        let wide = ZoomBucket(level: 3)
        let close = ZoomBucket(level: 2)

        // When/Then
        #expect(close.cellSizeDegrees == wide.cellSizeDegrees / 2)
    }

    // MARK: - Grid

    @Test("Coordinates in the same cell share an index") func sameCellSharesIndex() {
        // Given
        let bucket = ZoomBucket(level: 3) // 1 degree cells
        let first = CLLocationCoordinate2D(latitude: 40.1, longitude: -3.1)
        let second = CLLocationCoordinate2D(latitude: 40.9, longitude: -3.2)

        // When/Then
        #expect(bucket.cell(for: first) == bucket.cell(for: second))
    }

    @Test("Coordinates a cell apart get different indices") func differentCellsGetDifferentIndices() {
        // Given
        let bucket = ZoomBucket(level: 3) // 1 degree cells
        let first = CLLocationCoordinate2D(latitude: 40.5, longitude: -3.5)
        let second = CLLocationCoordinate2D(latitude: 42.5, longitude: -3.5)

        // When/Then
        #expect(bucket.cell(for: first) != bucket.cell(for: second))
    }

    @Test("Longitude cells widen with latitude to stay roughly square") func longitudeCellsWidenWithLatitude() {
        // Given: 1 degree cells; at 60° a degree of longitude covers half the ground
        let bucket = ZoomBucket(level: 3)
        let equatorWest = CLLocationCoordinate2D(latitude: 0.2, longitude: 0)
        let equatorEast = CLLocationCoordinate2D(latitude: 0.2, longitude: 1.5)
        let northWest = CLLocationCoordinate2D(latitude: 60.2, longitude: 0)
        let northEast = CLLocationCoordinate2D(latitude: 60.2, longitude: 1.5)

        // When/Then: the same longitude gap splits at the equator but not at 60°
        #expect(bucket.cell(for: equatorWest) != bucket.cell(for: equatorEast))
        #expect(bucket.cell(for: northWest) == bucket.cell(for: northEast))
    }

    @Test("Longitude cell width stays finite near the poles") func polarLongitudeCellsStayFinite() {
        // Given
        let bucket = ZoomBucket(level: 3)
        let nearPole = CLLocationCoordinate2D(latitude: 89.9, longitude: 0)
        let farAcross = CLLocationCoordinate2D(latitude: 89.9, longitude: 175)

        // When/Then: the cosine floor keeps cells bounded, so distant longitudes still split
        #expect(bucket.cell(for: nearPole) != bucket.cell(for: farAcross))
    }

    @Test("Non-finite coordinates cannot be placed on the grid") func nonFiniteCoordinateHasNoCell() {
        // Given
        let bucket = ZoomBucket(level: 3)
        let notANumber = CLLocationCoordinate2D(latitude: .nan, longitude: 0)
        let infinite = CLLocationCoordinate2D(latitude: 0, longitude: .infinity)

        // When/Then
        #expect(bucket.cell(for: notANumber) == nil)
        #expect(bucket.cell(for: infinite) == nil)
    }

    // MARK: - Identifiers

    @Test("Cluster identifier encodes level and cell") func clusterIdentifierEncodesLevelAndCell() {
        // Given
        let bucket = ZoomBucket(level: 3)

        // When
        let identifier = bucket.clusterIdentifier(for: CellIndex(x: -3, y: 40))

        // Then
        #expect(identifier == "3:-3:40")
    }

    @Test("Same cell at different levels yields different identifiers") func identifiersDifferAcrossLevels() {
        // Given
        let cell = CellIndex(x: 1, y: 2)

        // When
        let wide = ZoomBucket(level: 3).clusterIdentifier(for: cell)
        let close = ZoomBucket(level: 2).clusterIdentifier(for: cell)

        // Then
        #expect(wide != close)
    }
}
