import Foundation
import CoreLocation

/// Complete enriched data for a place
public struct EnrichedPlaceData: Sendable, Equatable {
    public let placeId: String
    public let provider: PlaceProvider
    public let name: String
    public let formattedAddress: String?
    public let coordinate: CLLocationCoordinate2D
    public let phoneNumber: String?
    public let website: URL?
    public let rating: Double?
    public let userRatingsTotal: Int?
    public let priceLevel: Int?
    public let openingHours: OpeningHours?
    public let photos: [PlacePhoto]
    public let reviews: [PlaceReview]
    public let types: [String]

    public init(
        placeId: String,
        provider: PlaceProvider,
        name: String,
        formattedAddress: String? = nil,
        coordinate: CLLocationCoordinate2D,
        phoneNumber: String? = nil,
        website: URL? = nil,
        rating: Double? = nil,
        userRatingsTotal: Int? = nil,
        priceLevel: Int? = nil,
        openingHours: OpeningHours? = nil,
        photos: [PlacePhoto] = [],
        reviews: [PlaceReview] = [],
        types: [String] = []
    ) {
        self.placeId = placeId
        self.provider = provider
        self.name = name
        self.formattedAddress = formattedAddress
        self.coordinate = coordinate
        self.phoneNumber = phoneNumber
        self.website = website
        self.rating = rating
        self.userRatingsTotal = userRatingsTotal
        self.priceLevel = priceLevel
        self.openingHours = openingHours
        self.photos = photos
        self.reviews = reviews
        self.types = types
    }
}

/// Opening hours information
public struct OpeningHours: Sendable, Equatable {
    public let isOpen: Bool?
    public let weekdayText: [String]
    public let periods: [Period]

    public init(
        isOpen: Bool? = nil,
        weekdayText: [String] = [],
        periods: [Period] = []
    ) {
        self.isOpen = isOpen
        self.weekdayText = weekdayText
        self.periods = periods
    }

    public struct Period: Sendable, Equatable {
        public let open: DayTime
        public let close: DayTime?

        public init(open: DayTime, close: DayTime? = nil) {
            self.open = open
            self.close = close
        }
    }

    public struct DayTime: Sendable, Equatable {
        public let day: Int // 0-6 (Sunday-Saturday)
        public let time: String // HHmm format

        public init(day: Int, time: String) {
            self.day = day
            self.time = time
        }
    }
}

/// Place photo reference
public struct PlacePhoto: Sendable, Identifiable, Equatable {
    public let id: String
    public let photoReference: String
    public let width: Int
    public let height: Int
    public let attributions: [String]

    public init(
        id: String,
        photoReference: String,
        width: Int,
        height: Int,
        attributions: [String] = []
    ) {
        self.id = id
        self.photoReference = photoReference
        self.width = width
        self.height = height
        self.attributions = attributions
    }
}

/// Place review
public struct PlaceReview: Sendable, Identifiable, Equatable {
    public let id: String
    public let authorName: String
    public let rating: Int
    public let text: String
    public let time: Date
    public let language: String?

    public init(
        id: String,
        authorName: String,
        rating: Int,
        text: String,
        time: Date,
        language: String? = nil
    ) {
        self.id = id
        self.authorName = authorName
        self.rating = rating
        self.text = text
        self.time = time
        self.language = language
    }
}
