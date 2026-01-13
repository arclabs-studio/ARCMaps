//
//  EnrichedPlaceData.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation

/// Complete enriched data for a place, including details not available in search results.
///
/// `EnrichedPlaceData` contains comprehensive information about a place, including
/// contact details, opening hours, photos, and reviews. This is typically fetched
/// after selecting a place from search results.
///
/// ## Example
/// ```swift
/// let enrichedData = try await placesService.getPlaceDetails(placeId: result.id)
/// print("Phone: \(enrichedData.phoneNumber ?? "N/A")")
/// print("Website: \(enrichedData.website?.absoluteString ?? "N/A")")
/// print("Reviews: \(enrichedData.reviews.count)")
/// ```
public struct EnrichedPlaceData: Sendable, Equatable {
    /// Unique identifier from the provider.
    public let placeId: String

    /// The service provider that supplied this data.
    public let provider: PlaceProvider

    /// Display name of the place.
    public let name: String

    /// Full formatted address.
    public let formattedAddress: String?

    /// Geographic coordinates of the place.
    public let coordinate: CLLocationCoordinate2D

    /// Contact phone number.
    public let phoneNumber: String?

    /// Official website URL.
    public let website: URL?

    /// Average user rating, typically on a 1-5 scale.
    public let rating: Double?

    /// Total number of user ratings.
    public let userRatingsTotal: Int?

    /// Price level indicator (0-4, where 0 is free and 4 is expensive).
    public let priceLevel: Int?

    /// Opening hours information for the place.
    public let openingHours: OpeningHours?

    /// Available photos of the place.
    public let photos: [PlacePhoto]

    /// User reviews of the place.
    public let reviews: [PlaceReview]

    /// Place type categories (e.g., "restaurant", "cafe").
    public let types: [String]

    /// Creates a new enriched place data instance.
    ///
    /// - Parameters:
    ///   - placeId: Unique identifier from the provider.
    ///   - provider: The service provider that supplied this data.
    ///   - name: Display name of the place.
    ///   - formattedAddress: Full formatted address.
    ///   - coordinate: Geographic coordinates.
    ///   - phoneNumber: Contact phone number.
    ///   - website: Official website URL.
    ///   - rating: Average user rating.
    ///   - userRatingsTotal: Total number of user ratings.
    ///   - priceLevel: Price level indicator (0-4).
    ///   - openingHours: Opening hours information.
    ///   - photos: Available photos.
    ///   - reviews: User reviews.
    ///   - types: Place type categories.
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

/// Opening hours information for a place.
///
/// Contains both human-readable text descriptions and structured time periods
/// for programmatic access to opening hours data.
public struct OpeningHours: Sendable, Equatable {
    /// Whether the place is currently open, if known.
    public let isOpen: Bool?

    /// Human-readable opening hours text for each day of the week.
    public let weekdayText: [String]

    /// Structured time periods defining when the place is open.
    public let periods: [Period]

    /// Creates a new opening hours instance.
    ///
    /// - Parameters:
    ///   - isOpen: Whether the place is currently open.
    ///   - weekdayText: Human-readable hours for each weekday.
    ///   - periods: Structured time periods.
    public init(
        isOpen: Bool? = nil,
        weekdayText: [String] = [],
        periods: [Period] = []
    ) {
        self.isOpen = isOpen
        self.weekdayText = weekdayText
        self.periods = periods
    }

    /// A time period representing when a place is open.
    public struct Period: Sendable, Equatable {
        /// The opening time.
        public let open: DayTime

        /// The closing time, or `nil` for 24-hour operation.
        public let close: DayTime?

        /// Creates a new time period.
        ///
        /// - Parameters:
        ///   - open: The opening time.
        ///   - close: The closing time, or `nil` for 24-hour operation.
        public init(open: DayTime, close: DayTime? = nil) {
            self.open = open
            self.close = close
        }
    }

    /// A specific day and time combination.
    public struct DayTime: Sendable, Equatable {
        /// Day of the week (0 = Sunday, 6 = Saturday).
        public let day: Int

        /// Time in 24-hour HHmm format (e.g., "0900" for 9:00 AM).
        public let time: String

        /// Creates a new day/time combination.
        ///
        /// - Parameters:
        ///   - day: Day of the week (0-6, Sunday to Saturday).
        ///   - time: Time in HHmm format.
        public init(day: Int, time: String) {
            self.day = day
            self.time = time
        }
    }
}

/// A reference to a place photo that can be fetched from the provider.
///
/// Photos are not directly included in responses due to size. Instead, use the
/// `photoReference` to fetch the actual image data from the provider's photo API.
public struct PlacePhoto: Sendable, Identifiable, Equatable {
    /// Unique identifier for the photo.
    public let id: String

    /// Provider-specific reference string for fetching the photo.
    public let photoReference: String

    /// Maximum available width in pixels.
    public let width: Int

    /// Maximum available height in pixels.
    public let height: Int

    /// Attribution strings required when displaying this photo.
    public let attributions: [String]

    /// Creates a new place photo reference.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the photo.
    ///   - photoReference: Provider-specific reference for fetching.
    ///   - width: Maximum available width in pixels.
    ///   - height: Maximum available height in pixels.
    ///   - attributions: Required attribution strings.
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

/// A user review of a place.
///
/// Contains the review text, rating, author information, and timestamp.
public struct PlaceReview: Sendable, Identifiable, Equatable {
    /// Unique identifier for the review.
    public let id: String

    /// Name of the review author.
    public let authorName: String

    /// Rating given by the author (typically 1-5).
    public let rating: Int

    /// Full text content of the review.
    public let text: String

    /// Date and time when the review was submitted.
    public let time: Date

    /// ISO 639-1 language code of the review text.
    public let language: String?

    /// Creates a new place review.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the review.
    ///   - authorName: Name of the review author.
    ///   - rating: Rating given by the author.
    ///   - text: Full text content of the review.
    ///   - time: Date and time of submission.
    ///   - language: ISO 639-1 language code.
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
