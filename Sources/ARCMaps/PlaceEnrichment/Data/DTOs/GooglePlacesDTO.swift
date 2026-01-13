import Foundation

// MARK: - Response DTOs

struct GooglePlacesSearchResponse: Codable, Sendable {
    let results: [GooglePlaceResult]
    let status: String
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case results
        case status
        case errorMessage = "error_message"
    }
}

struct GooglePlaceDetailsResponse: Codable, Sendable {
    let result: GooglePlaceResult
    let status: String
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case result
        case status
        case errorMessage = "error_message"
    }
}

struct GooglePlaceResult: Codable, Sendable {
    let placeId: String
    let name: String
    let formattedAddress: String?
    let geometry: GoogleGeometry
    let rating: Double?
    let userRatingsTotal: Int?
    let priceLevel: Int?
    let types: [String]?
    let photos: [GooglePhoto]?
    let openingHours: GoogleOpeningHours?
    let website: String?
    let formattedPhoneNumber: String?
    let reviews: [GoogleReview]?

    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case name
        case formattedAddress = "formatted_address"
        case geometry
        case rating
        case userRatingsTotal = "user_ratings_total"
        case priceLevel = "price_level"
        case types
        case photos
        case openingHours = "opening_hours"
        case website
        case formattedPhoneNumber = "formatted_phone_number"
        case reviews
    }
}

struct GoogleGeometry: Codable, Sendable {
    let location: GoogleLocation
}

struct GoogleLocation: Codable, Sendable {
    let lat: Double
    let lng: Double
}

struct GooglePhoto: Codable, Sendable {
    let photoReference: String
    let width: Int
    let height: Int
    let htmlAttributions: [String]

    enum CodingKeys: String, CodingKey {
        case photoReference = "photo_reference"
        case width
        case height
        case htmlAttributions = "html_attributions"
    }
}

struct GoogleOpeningHours: Codable, Sendable {
    let openNow: Bool?
    let weekdayText: [String]?
    let periods: [GooglePeriod]?

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case weekdayText = "weekday_text"
        case periods
    }
}

struct GooglePeriod: Codable, Sendable {
    let open: GoogleDayTime
    let close: GoogleDayTime?
}

struct GoogleDayTime: Codable, Sendable {
    let day: Int
    let time: String
}

struct GoogleReview: Codable, Sendable {
    let authorName: String
    let rating: Int
    let text: String
    let time: Int
    let language: String?

    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case rating
        case text
        case time
        case language
    }
}
