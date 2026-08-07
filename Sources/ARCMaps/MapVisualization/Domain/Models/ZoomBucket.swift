//
//  ZoomBucket.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 07/08/2026.
//

import CoreLocation
import Foundation

// MARK: - Constants

private enum ZoomDefaults {
    /// Smallest camera span the grid distinguishes, in degrees of latitude (~55 m).
    static let minimumLatitudeDelta: Double = 0.0005
    /// Largest camera span the grid distinguishes, in degrees of latitude (whole globe).
    static let maximumLatitudeDelta: Double = 180
    /// Approximate number of grid cells spanning the visible region.
    ///
    /// Higher values produce smaller cells and therefore more, smaller clusters.
    static let cellsPerSpan: Double = 8
    /// Cosine floor used when widening longitude cells, equivalent to ~84.3° latitude.
    ///
    /// Without a floor, longitude cell width diverges at the poles.
    static let minimumLatitudeCosine: Double = 0.1
}

// MARK: - CellIndex

/// The integer coordinates of a single cell in the clustering grid.
struct CellIndex: Hashable {
    let x: Int
    let y: Int
}

// MARK: - ZoomBucket

/// A discrete zoom level that determines clustering grid resolution.
///
/// The map camera reports a continuously varying span, but clustering against a
/// continuous value would re-form clusters on every pixel of pan, producing constant
/// annotation churn. `ZoomBucket` snaps the camera span to a discrete rung
/// (a power of two), so clusters only re-form when the zoom changes meaningfully.
///
/// ``MapViewModel`` relies on this: it skips recomputation entirely when a camera
/// change lands in the same bucket.
///
/// ## Example
/// ```swift
/// let bucket = ZoomBucket(latitudeDelta: region.span.latitudeDelta)
/// let items = PlaceClusterer().cluster(places, bucket: bucket)
/// ```
public struct ZoomBucket: Sendable, Equatable, Hashable {
    /// The discrete rung this bucket occupies, as a base-two exponent of the camera span.
    ///
    /// Lower values mean closer zoom. Derived as `floor(log2(latitudeDelta))`.
    public let level: Int

    /// The height of one grid cell, in degrees of latitude.
    ///
    /// Longitude cell width is derived from this per latitude band — see
    /// ``cell(for:)`` — so that cells stay roughly square in meters.
    public var cellSizeDegrees: Double {
        exp2(Double(level)) / ZoomDefaults.cellsPerSpan
    }

    /// Creates the bucket containing a given camera span.
    ///
    /// The span is clamped to a supported range before bucketing, so degenerate
    /// values (zero, negative, or non-finite) resolve to the closest valid bucket
    /// rather than producing an invalid grid.
    ///
    /// - Parameter latitudeDelta: The camera's visible latitude span, in degrees.
    public init(latitudeDelta: Double) {
        let clamped = if latitudeDelta.isFinite {
            min(max(latitudeDelta, ZoomDefaults.minimumLatitudeDelta), ZoomDefaults.maximumLatitudeDelta)
        } else {
            ZoomDefaults.maximumLatitudeDelta
        }

        level = Int(floor(log2(clamped)))
    }

    /// Creates a bucket at an explicit rung, bypassing camera-span clamping.
    ///
    /// Intended for tests and for callers that already reason in rungs.
    ///
    /// - Parameter level: The base-two exponent defining cell size.
    public init(level: Int) {
        self.level = level
    }

    // MARK: - Grid

    /// Returns the grid cell containing a coordinate.
    ///
    /// Latitude bands have uniform height. Longitude cell width is widened by
    /// `1 / cos(latitude)` at the band's center, because a degree of longitude covers
    /// less ground as latitude increases — without this, cells become long thin
    /// slivers away from the equator and clustering degrades. The cosine is floored
    /// so that width stays finite near the poles.
    ///
    /// - Parameter coordinate: The coordinate to locate. Must be finite.
    /// - Returns: The containing cell, or `nil` if the coordinate is not finite.
    func cell(for coordinate: CLLocationCoordinate2D) -> CellIndex? {
        guard coordinate.latitude.isFinite, coordinate.longitude.isFinite else { return nil }

        let size = cellSizeDegrees
        let y = Int(floor(coordinate.latitude / size))

        let bandCenterLatitude = (Double(y) + 0.5) * size
        let cosine = max(abs(cos(bandCenterLatitude * .pi / 180)), ZoomDefaults.minimumLatitudeCosine)
        let longitudeCellSize = size / cosine

        let x = Int(floor(coordinate.longitude / longitudeCellSize))

        return CellIndex(x: x, y: y)
    }

    /// Builds the stable cluster identifier for a cell at this zoom level.
    ///
    /// The level is part of the identifier so that clusters at different zoom levels
    /// are never mistaken for one another by SwiftUI's annotation diffing.
    ///
    /// - Parameter cell: The grid cell backing the cluster.
    /// - Returns: An identifier of the form `"<level>:<x>:<y>"`.
    func clusterIdentifier(for cell: CellIndex) -> String {
        "\(level):\(cell.x):\(cell.y)"
    }
}
