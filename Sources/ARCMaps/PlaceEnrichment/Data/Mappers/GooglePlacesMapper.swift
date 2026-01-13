import Foundation
import CoreLocation

/// Mapper for Google Places API responses
enum GooglePlacesMapper {

    static func mapToSearchResult(_ dto: GooglePlaceResult) -> PlaceSearchResult {
        PlaceSearchResult(
            id: dto.placeId,
            provider: .google,
            name: dto.name,
            address: dto.formattedAddress,
            coordinate: CLLocationCoordinate2D(
                latitude: dto.geometry.location.lat,
                longitude: dto.geometry.location.lng
            ),
            types: dto.types ?? [],
            rating: dto.rating,
            userRatingsTotal: dto.userRatingsTotal,
            priceLevel: dto.priceLevel,
            photoReferences: dto.photos?.map { $0.photoReference } ?? []
        )
    }

    static func mapToEnrichedData(_ dto: GooglePlaceResult) -> EnrichedPlaceData {
        EnrichedPlaceData(
            placeId: dto.placeId,
            provider: .google,
            name: dto.name,
            formattedAddress: dto.formattedAddress,
            coordinate: CLLocationCoordinate2D(
                latitude: dto.geometry.location.lat,
                longitude: dto.geometry.location.lng
            ),
            phoneNumber: dto.formattedPhoneNumber,
            website: dto.website.flatMap { URL(string: $0) },
            rating: dto.rating,
            userRatingsTotal: dto.userRatingsTotal,
            priceLevel: dto.priceLevel,
            openingHours: dto.openingHours.map { mapOpeningHours($0) },
            photos: dto.photos?.enumerated().map { index, photo in
                PlacePhoto(
                    id: "\(dto.placeId)_\(index)",
                    photoReference: photo.photoReference,
                    width: photo.width,
                    height: photo.height,
                    attributions: photo.htmlAttributions
                )
            } ?? [],
            reviews: dto.reviews?.enumerated().map { index, review in
                PlaceReview(
                    id: "\(dto.placeId)_review_\(index)",
                    authorName: review.authorName,
                    rating: review.rating,
                    text: review.text,
                    time: Date(timeIntervalSince1970: TimeInterval(review.time)),
                    language: review.language
                )
            } ?? [],
            types: dto.types ?? []
        )
    }

    private static func mapOpeningHours(_ dto: GoogleOpeningHours) -> OpeningHours {
        OpeningHours(
            isOpen: dto.openNow,
            weekdayText: dto.weekdayText ?? [],
            periods: dto.periods?.map { period in
                OpeningHours.Period(
                    open: OpeningHours.DayTime(
                        day: period.open.day,
                        time: period.open.time
                    ),
                    close: period.close.map { close in
                        OpeningHours.DayTime(
                            day: close.day,
                            time: close.time
                        )
                    }
                )
            } ?? []
        )
    }
}
