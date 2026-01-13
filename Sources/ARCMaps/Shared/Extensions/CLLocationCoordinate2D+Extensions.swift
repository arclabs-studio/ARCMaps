import CoreLocation

extension CLLocationCoordinate2D: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

extension CLLocationCoordinate2D {
    /// Check if coordinate is valid
    public var isValid: Bool {
        CLLocationCoordinate2DIsValid(self)
    }

    /// Calculate distance to another coordinate in meters
    public func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2)
    }
}
