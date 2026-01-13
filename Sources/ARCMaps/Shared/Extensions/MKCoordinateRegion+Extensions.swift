import MapKit
import CoreLocation

extension MKCoordinateRegion {
    /// Create region that fits all coordinates with padding
    public static func fitting(_ coordinates: [CLLocationCoordinate2D], padding: Double = 0.1) -> MKCoordinateRegion? {
        guard !coordinates.isEmpty else { return nil }

        let lats = coordinates.map { $0.latitude }
        let lons = coordinates.map { $0.longitude }

        guard let minLat = lats.min(),
              let maxLat = lats.max(),
              let minLon = lons.min(),
              let maxLon = lons.max() else {
            return nil
        }

        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2

        let spanLat = (maxLat - minLat) * (1 + padding)
        let spanLon = (maxLon - minLon) * (1 + padding)

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: max(spanLat, 0.01), longitudeDelta: max(spanLon, 0.01))
        )
    }
}
