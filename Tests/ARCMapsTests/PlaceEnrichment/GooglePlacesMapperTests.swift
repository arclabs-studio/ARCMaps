//
//  GooglePlacesMapperTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Testing
@testable import ARCMaps

@Suite("GooglePlacesMapper Tests")
struct GooglePlacesMapperTests {
    // MARK: - Map to Search Result

    @Test("Maps basic place result correctly")
    func mapsBasicPlaceResultCorrectly() {
        // Given
        let dto = createBasicDTO()

        // When
        let result = GooglePlacesMapper.mapToSearchResult(dto)

        // Then
        #expect(result.id == "place_123")
        #expect(result.provider == .google)
        #expect(result.name == "Test Restaurant")
        #expect(result.coordinate.latitude == 40.4168)
        #expect(result.coordinate.longitude == -3.7038)
    }

    @Test("Maps address from formatted address")
    func mapsAddressFromFormattedAddress() {
        // Given
        let dto = createDTOWithAddress("Calle Mayor 15, Madrid")

        // When
        let result = GooglePlacesMapper.mapToSearchResult(dto)

        // Then
        #expect(result.address == "Calle Mayor 15, Madrid")
    }

    @Test("Maps rating and user ratings total")
    func mapsRatingAndUserRatingsTotal() {
        // Given
        let dto = createDTOWithRating(4.5, userRatingsTotal: 120)

        // When
        let result = GooglePlacesMapper.mapToSearchResult(dto)

        // Then
        #expect(result.rating == 4.5)
        #expect(result.userRatingsTotal == 120)
    }

    @Test("Maps price level")
    func mapsPriceLevel() {
        // Given
        let dto = createDTOWithPriceLevel(2)

        // When
        let result = GooglePlacesMapper.mapToSearchResult(dto)

        // Then
        #expect(result.priceLevel == 2)
    }

    @Test("Maps types array")
    func mapsTypesArray() {
        // Given
        let dto = createDTOWithTypes(["restaurant", "food", "point_of_interest"])

        // When
        let result = GooglePlacesMapper.mapToSearchResult(dto)

        // Then
        #expect(result.types.count == 3)
        #expect(result.types.contains("restaurant"))
        #expect(result.types.contains("food"))
    }

    @Test("Maps photo references")
    func mapsPhotoReferences() {
        // Given
        let dto = createDTOWithPhotos(["photo_ref_1", "photo_ref_2"])

        // When
        let result = GooglePlacesMapper.mapToSearchResult(dto)

        // Then
        #expect(result.photoReferences.count == 2)
        #expect(result.photoReferences.contains("photo_ref_1"))
    }

    @Test("Handles nil types gracefully")
    func handlesNilTypesGracefully() {
        // Given
        let dto = createBasicDTO()

        // When
        let result = GooglePlacesMapper.mapToSearchResult(dto)

        // Then
        #expect(result.types.isEmpty)
    }

    @Test("Handles nil photos gracefully")
    func handlesNilPhotosGracefully() {
        // Given
        let dto = createBasicDTO()

        // When
        let result = GooglePlacesMapper.mapToSearchResult(dto)

        // Then
        #expect(result.photoReferences.isEmpty)
    }

    // MARK: - Map to Enriched Data

    @Test("Maps to enriched data with all fields")
    func mapsToEnrichedDataWithAllFields() {
        // Given
        let dto = createFullDTO()

        // When
        let result = GooglePlacesMapper.mapToEnrichedData(dto)

        // Then
        #expect(result.placeId == "place_123")
        #expect(result.provider == .google)
        #expect(result.name == "Test Restaurant")
        #expect(result.phoneNumber == "+34 91 123 4567")
        #expect(result.website?.absoluteString == "https://example.com")
    }

    @Test("Maps opening hours correctly")
    func mapsOpeningHoursCorrectly() {
        // Given
        let dto = createDTOWithOpeningHours()

        // When
        let result = GooglePlacesMapper.mapToEnrichedData(dto)

        // Then
        #expect(result.openingHours != nil)
        #expect(result.openingHours?.isOpen == true)
        #expect(result.openingHours?.weekdayText.count == 1)
    }

    @Test("Maps reviews correctly")
    func mapsReviewsCorrectly() {
        // Given
        let dto = createDTOWithReviews()

        // When
        let result = GooglePlacesMapper.mapToEnrichedData(dto)

        // Then
        #expect(result.reviews.count == 1)
        #expect(result.reviews.first?.authorName == "John Doe")
        #expect(result.reviews.first?.rating == 5)
    }

    // MARK: - Helper Methods

    private func createBasicDTO() -> GooglePlaceResult {
        GooglePlaceResult(
            placeId: "place_123",
            name: "Test Restaurant",
            formattedAddress: nil,
            geometry: GoogleGeometry(location: GoogleLocation(lat: 40.4168, lng: -3.7038)),
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: nil,
            types: nil,
            photos: nil,
            openingHours: nil,
            website: nil,
            formattedPhoneNumber: nil,
            reviews: nil
        )
    }

    private func createDTOWithAddress(_ address: String) -> GooglePlaceResult {
        GooglePlaceResult(
            placeId: "place_123",
            name: "Test Restaurant",
            formattedAddress: address,
            geometry: GoogleGeometry(location: GoogleLocation(lat: 40.4168, lng: -3.7038)),
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: nil,
            types: nil,
            photos: nil,
            openingHours: nil,
            website: nil,
            formattedPhoneNumber: nil,
            reviews: nil
        )
    }

    private func createDTOWithRating(_ rating: Double, userRatingsTotal: Int) -> GooglePlaceResult {
        GooglePlaceResult(
            placeId: "place_123",
            name: "Test Restaurant",
            formattedAddress: nil,
            geometry: GoogleGeometry(location: GoogleLocation(lat: 40.4168, lng: -3.7038)),
            rating: rating,
            userRatingsTotal: userRatingsTotal,
            priceLevel: nil,
            types: nil,
            photos: nil,
            openingHours: nil,
            website: nil,
            formattedPhoneNumber: nil,
            reviews: nil
        )
    }

    private func createDTOWithPriceLevel(_ priceLevel: Int) -> GooglePlaceResult {
        GooglePlaceResult(
            placeId: "place_123",
            name: "Test Restaurant",
            formattedAddress: nil,
            geometry: GoogleGeometry(location: GoogleLocation(lat: 40.4168, lng: -3.7038)),
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: priceLevel,
            types: nil,
            photos: nil,
            openingHours: nil,
            website: nil,
            formattedPhoneNumber: nil,
            reviews: nil
        )
    }

    private func createDTOWithTypes(_ types: [String]) -> GooglePlaceResult {
        GooglePlaceResult(
            placeId: "place_123",
            name: "Test Restaurant",
            formattedAddress: nil,
            geometry: GoogleGeometry(location: GoogleLocation(lat: 40.4168, lng: -3.7038)),
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: nil,
            types: types,
            photos: nil,
            openingHours: nil,
            website: nil,
            formattedPhoneNumber: nil,
            reviews: nil
        )
    }

    private func createDTOWithPhotos(_ photoRefs: [String]) -> GooglePlaceResult {
        let photos = photoRefs.map { ref in
            GooglePhoto(photoReference: ref, width: 400, height: 300, htmlAttributions: [])
        }
        return GooglePlaceResult(
            placeId: "place_123",
            name: "Test Restaurant",
            formattedAddress: nil,
            geometry: GoogleGeometry(location: GoogleLocation(lat: 40.4168, lng: -3.7038)),
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: nil,
            types: nil,
            photos: photos,
            openingHours: nil,
            website: nil,
            formattedPhoneNumber: nil,
            reviews: nil
        )
    }

    private func createFullDTO() -> GooglePlaceResult {
        GooglePlaceResult(
            placeId: "place_123",
            name: "Test Restaurant",
            formattedAddress: "Calle Mayor 15, Madrid",
            geometry: GoogleGeometry(location: GoogleLocation(lat: 40.4168, lng: -3.7038)),
            rating: 4.5,
            userRatingsTotal: 120,
            priceLevel: 2,
            types: ["restaurant"],
            photos: nil,
            openingHours: nil,
            website: "https://example.com",
            formattedPhoneNumber: "+34 91 123 4567",
            reviews: nil
        )
    }

    private func createDTOWithOpeningHours() -> GooglePlaceResult {
        let openingHours = GoogleOpeningHours(
            openNow: true,
            weekdayText: ["Monday: 9:00 AM – 10:00 PM"],
            periods: nil
        )
        return GooglePlaceResult(
            placeId: "place_123",
            name: "Test Restaurant",
            formattedAddress: nil,
            geometry: GoogleGeometry(location: GoogleLocation(lat: 40.4168, lng: -3.7038)),
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: nil,
            types: nil,
            photos: nil,
            openingHours: openingHours,
            website: nil,
            formattedPhoneNumber: nil,
            reviews: nil
        )
    }

    private func createDTOWithReviews() -> GooglePlaceResult {
        let reviews = [
            GoogleReview(authorName: "John Doe", rating: 5, text: "Great place!", time: 1_609_459_200, language: "en")
        ]
        return GooglePlaceResult(
            placeId: "place_123",
            name: "Test Restaurant",
            formattedAddress: nil,
            geometry: GoogleGeometry(location: GoogleLocation(lat: 40.4168, lng: -3.7038)),
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: nil,
            types: nil,
            photos: nil,
            openingHours: nil,
            website: nil,
            formattedPhoneNumber: nil,
            reviews: reviews
        )
    }
}
