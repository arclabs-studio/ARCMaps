//
//  MapCluster.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 07/08/2026.
//

import CoreLocation
import Foundation

// MARK: - MapCluster

/// A group of nearby places collapsed into a single map annotation.
///
/// `MapCluster` is produced by ``PlaceClusterer`` when several places fall into the
/// same grid cell at the current zoom level. Rather than drawing every pin and
/// letting them overlap into an unreadable stack, the map draws one cluster bubble
/// at the centroid of its members.
///
/// ## Identity is derived, never generated
///
/// ``id`` is derived from the zoom bucket and grid cell that produced the cluster,
/// so the same places at the same zoom level always yield the same identifier.
/// This matters: SwiftUI diffs annotations by identity, and a freshly generated
/// identifier on every camera change would re-animate every annotation on the map.
///
/// ## Example
/// ```swift
/// switch annotationItem {
/// case let .cluster(cluster):
///     ClusterMarker(count: cluster.count)
///         .onTapGesture { viewModel.selectCluster(cluster) }
/// case let .place(place):
///     PlaceMarker(place: place)
/// }
/// ```
public struct MapCluster: Sendable, Identifiable, Equatable {
    /// Stable identifier derived from the zoom bucket and grid cell.
    ///
    /// Formatted as `"<bucket>:<cellX>:<cellY>"`. Never randomly generated — see
    /// the type-level discussion of identity.
    public let id: String

    /// The centroid of the clustered places, where the cluster bubble is drawn.
    ///
    /// - Note: The centroid is the arithmetic mean of member coordinates and is
    ///   therefore incorrect for clusters spanning the antimeridian. Clustering
    ///   across ±180° longitude is not supported.
    public let coordinate: CLLocationCoordinate2D

    /// The places collapsed into this cluster, in their original order.
    public let places: [MapPlace]

    /// The number of places in the cluster.
    public var count: Int {
        places.count
    }

    /// Creates a cluster with an explicit identifier and centroid.
    ///
    /// Prefer ``init(id:places:)``, which derives the centroid from the members.
    ///
    /// - Parameters:
    ///   - id: Stable identifier derived from the zoom bucket and grid cell.
    ///   - coordinate: The centroid at which to draw the cluster.
    ///   - places: The places collapsed into this cluster.
    public init(id: String,
                coordinate: CLLocationCoordinate2D,
                places: [MapPlace]) {
        self.id = id
        self.coordinate = coordinate
        self.places = places
    }

    /// Creates a cluster whose centroid is the mean of its members' coordinates.
    ///
    /// - Parameters:
    ///   - id: Stable identifier derived from the zoom bucket and grid cell.
    ///   - places: The places to cluster. Must not be empty.
    /// - Returns: `nil` if `places` is empty, since an empty cluster has no centroid.
    public init?(id: String, places: [MapPlace]) {
        guard let centroid = Self.centroid(of: places) else { return nil }
        self.init(id: id, coordinate: centroid, places: places)
    }

    /// Calculates the arithmetic mean of a set of coordinates.
    ///
    /// - Parameter places: The places to average.
    /// - Returns: The mean coordinate, or `nil` when `places` is empty.
    static func centroid(of places: [MapPlace]) -> CLLocationCoordinate2D? {
        guard !places.isEmpty else { return nil }

        let count = Double(places.count)
        let latitude = places.reduce(0) { $0 + $1.coordinate.latitude } / count
        let longitude = places.reduce(0) { $0 + $1.coordinate.longitude } / count

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - MapAnnotationItem

/// A single drawable item on the map: either a standalone place or a cluster.
///
/// ``MapViewModel/annotationItems`` publishes an array of these, and ``ARCMapView``
/// renders one annotation per element. When clustering is disabled, every element
/// is a ``place(_:)``.
///
/// - Important: This is distinct from ``MapAnnotation``, which is a standalone
///   metadata-carrying annotation model unrelated to clustering. `MapAnnotationItem`
///   is specifically the output of ``PlaceClusterer`` and the input to the map's
///   annotation rendering.
public enum MapAnnotationItem: Sendable, Identifiable, Equatable {
    /// A single place drawn with the consumer's marker view.
    case place(MapPlace)

    /// A group of nearby places drawn as one cluster bubble.
    case cluster(MapCluster)

    /// The identity SwiftUI uses to diff annotations across camera changes.
    ///
    /// Place identifiers are prefixed to guarantee they can never collide with a
    /// cluster's derived `"<bucket>:<cellX>:<cellY>"` identifier.
    public var id: String {
        switch self {
        case let .place(place):
            "place:\(place.id)"
        case let .cluster(cluster):
            "cluster:\(cluster.id)"
        }
    }

    /// The coordinate at which the item is drawn.
    public var coordinate: CLLocationCoordinate2D {
        switch self {
        case let .place(place):
            place.coordinate
        case let .cluster(cluster):
            cluster.coordinate
        }
    }

    /// The places represented by this item — one for a place, many for a cluster.
    public var places: [MapPlace] {
        switch self {
        case let .place(place):
            [place]
        case let .cluster(cluster):
            cluster.places
        }
    }
}
