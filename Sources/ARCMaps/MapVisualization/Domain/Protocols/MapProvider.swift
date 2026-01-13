import Foundation
import CoreLocation

/// Abstraction over map providers (Apple MapKit, Google Maps)
@MainActor
public protocol MapProvider: Sendable {
    /// Display places on the map
    /// - Parameter places: Places to display
    func showPlaces(_ places: [MapPlace]) async

    /// Get current visible region
    /// - Returns: Current map region
    func getVisibleRegion() async -> MapRegion

    /// Center map on specific location
    /// - Parameters:
    ///   - coordinate: Coordinate to center on
    ///   - animated: Whether to animate the transition
    func centerOn(coordinate: CLLocationCoordinate2D, animated: Bool) async

    /// Zoom to fit all places
    /// - Parameters:
    ///   - places: Places to fit in view
    ///   - animated: Whether to animate the transition
    func fitPlaces(_ places: [MapPlace], animated: Bool) async
}
