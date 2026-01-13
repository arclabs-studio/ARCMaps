import Foundation
import CoreLocation

/// Represents a search result from a place provider
public struct PlaceSearchResult: Sendable, Identifiable, Equatable {
    public let id: String
    public let provider: PlaceProvider
    public let name: String
    public let address: String?
    public let coordinate: CLLocationCoordinate2D
    public let types: [String]
    public let rating: Double?
    public let userRatingsTotal: Int?
    public let priceLevel: Int?
    public let photoReferences: [String]

    public init(
        id: String,
        provider: PlaceProvider,
        name: String,
        address: String? = nil,
        coordinate: CLLocationCoordinate2D,
        types: [String] = [],
        rating: Double? = nil,
        userRatingsTotal: Int? = nil,
        priceLevel: Int? = nil,
        photoReferences: [String] = []
    ) {
        self.id = id
        self.provider = provider
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.types = types
        self.rating = rating
        self.userRatingsTotal = userRatingsTotal
        self.priceLevel = priceLevel
        self.photoReferences = photoReferences
    }

    /// Calculated match score based on available data
    public var matchScore: Double {
        var score = 0.0
        if rating != nil { score += 0.3 }
        if userRatingsTotal ?? 0 > 0 { score += 0.2 }
        if !photoReferences.isEmpty { score += 0.3 }
        if address != nil { score += 0.2 }
        return score
    }
}

// Equatable conformance for CLLocationCoordinate2D
extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
