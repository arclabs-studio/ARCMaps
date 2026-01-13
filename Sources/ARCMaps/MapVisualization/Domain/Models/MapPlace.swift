import Foundation
import CoreLocation

/// Represents a place to display on the map
public struct MapPlace: Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let coordinate: CLLocationCoordinate2D
    public let address: String?
    public let category: String?
    public let rating: Double?
    public let status: PlaceStatus
    public let visitDate: Date?
    public let imageURL: URL?

    public init(
        id: String,
        name: String,
        coordinate: CLLocationCoordinate2D,
        address: String? = nil,
        category: String? = nil,
        rating: Double? = nil,
        status: PlaceStatus,
        visitDate: Date? = nil,
        imageURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.address = address
        self.category = category
        self.rating = rating
        self.status = status
        self.visitDate = visitDate
        self.imageURL = imageURL
    }

    /// Distance from given coordinate in meters
    public func distance(from coordinate: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2)
    }
}

/// Status of a place (wishlist vs visited)
public enum PlaceStatus: String, Sendable, CaseIterable, Equatable, Codable {
    case wishlist = "Wishlist"
    case visited = "Visited"

    public var iconName: String {
        switch self {
        case .wishlist: return "heart.fill"
        case .visited: return "checkmark.circle.fill"
        }
    }

    public var colorName: String {
        switch self {
        case .wishlist: return "red"
        case .visited: return "green"
        }
    }
}
