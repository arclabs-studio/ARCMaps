//
//  PlaceClusterer.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 07/08/2026.
//

import CoreLocation
import Foundation

// MARK: - PlaceClusterer

/// Collapses nearby places into clusters using a zoom-dependent grid.
///
/// SwiftUI's `Map` has no built-in clustering — `MKMarkerAnnotationView`'s
/// `clusteringIdentifier` belongs to MapKit-UIKit and has no SwiftUI equivalent.
/// `PlaceClusterer` fills that gap by bucketing places into grid cells sized from
/// the current ``ZoomBucket`` and emitting one annotation per occupied cell.
///
/// The type is pure and `Sendable`: given the same places and bucket it always
/// returns the same result, including identical cluster identifiers. That determinism
/// is what keeps SwiftUI from re-animating every annotation on each camera change.
///
/// ## Example
/// ```swift
/// let clusterer = PlaceClusterer()
/// let bucket = ZoomBucket(latitudeDelta: region.span.latitudeDelta)
/// let items = clusterer.cluster(places, bucket: bucket)
/// ```
///
/// ## Limitations
///
/// Clusters spanning the antimeridian (±180° longitude) are not supported: cell
/// indices do not wrap and the centroid is a plain arithmetic mean.
public struct PlaceClusterer: Sendable {
    // MARK: - Constants

    /// The number of places a cell must contain before clustering, unless overridden.
    ///
    /// Two overlapping pins are usually easier to read than a bubble reading "2",
    /// so three is the floor.
    public static let defaultMinimumClusterSize = 3

    /// The smallest value ``minimumClusterSize`` will accept.
    ///
    /// A cluster of one is a place, not a cluster.
    public static let smallestPermittedClusterSize = 2

    // MARK: - State

    /// The number of places a cell must contain before they collapse into a cluster.
    ///
    /// Cells holding fewer places emit individual ``MapAnnotationItem/place(_:)``
    /// items instead. Clamped to ``smallestPermittedClusterSize`` on initialization.
    public let minimumClusterSize: Int

    // MARK: - Initialization

    /// Creates a clusterer.
    ///
    /// - Parameter minimumClusterSize: Places required per cell to form a cluster.
    ///   Values below two are clamped to two. Defaults to three.
    public init(minimumClusterSize: Int = PlaceClusterer.defaultMinimumClusterSize) {
        self.minimumClusterSize = max(minimumClusterSize, Self.smallestPermittedClusterSize)
    }

    // MARK: - Clustering

    /// Groups places into clusters and standalone places for a given zoom level.
    ///
    /// Output order follows the order in which cells are first encountered while
    /// walking `places`, so the result is deterministic rather than dependent on
    /// dictionary ordering.
    ///
    /// Places with non-finite coordinates cannot be placed on the grid; they are
    /// emitted as standalone places rather than dropped, so nothing disappears
    /// from the map.
    ///
    /// - Parameters:
    ///   - places: The places to cluster, typically the filtered set.
    ///   - bucket: The zoom level determining grid cell size.
    /// - Returns: One item per occupied cell, plus one per ungriddable place.
    public func cluster(_ places: [MapPlace], bucket: ZoomBucket) -> [MapAnnotationItem] {
        var cellOrder: [CellIndex] = []
        var membersByCell: [CellIndex: [MapPlace]] = [:]
        var ungriddable: [MapPlace] = []

        for place in places {
            guard let cell = bucket.cell(for: place.coordinate) else {
                ungriddable.append(place)
                continue
            }

            if membersByCell[cell] == nil {
                cellOrder.append(cell)
            }

            membersByCell[cell, default: []].append(place)
        }

        let clustered = cellOrder.flatMap { cell -> [MapAnnotationItem] in
            let members = membersByCell[cell] ?? []

            guard members.count >= minimumClusterSize,
                  let cluster = MapCluster(id: bucket.clusterIdentifier(for: cell), places: members)
            else {
                return members.map(MapAnnotationItem.place)
            }

            return [.cluster(cluster)]
        }

        return clustered + ungriddable.map(MapAnnotationItem.place)
    }
}
