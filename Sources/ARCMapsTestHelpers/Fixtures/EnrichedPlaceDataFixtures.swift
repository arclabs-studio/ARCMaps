//
//  EnrichedPlaceDataFixtures.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation
@testable import ARCMaps

public enum EnrichedPlaceDataFixtures {
    public static var sampleRestaurant: EnrichedPlaceData {
        EnrichedPlaceData(
            placeId: "place_1",
            provider: .google,
            name: "La Taverna",
            formattedAddress: "Calle Mayor 15, 28013 Madrid, Spain",
            coordinate: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
            phoneNumber: "+34 91 123 4567",
            website: URL(string: "https://example.com/lataverna"),
            rating: 4.5,
            userRatingsTotal: 120,
            priceLevel: 2,
            openingHours: sampleOpeningHours,
            photos: samplePhotos,
            reviews: sampleReviews,
            types: ["restaurant", "food", "point_of_interest"]
        )
    }

    public static var sampleOpeningHours: OpeningHours {
        OpeningHours(
            isOpen: true,
            weekdayText: [
                "Monday: 12:00 PM – 11:00 PM",
                "Tuesday: 12:00 PM – 11:00 PM",
                "Wednesday: 12:00 PM – 11:00 PM",
                "Thursday: 12:00 PM – 11:00 PM",
                "Friday: 12:00 PM – 12:00 AM",
                "Saturday: 12:00 PM – 12:00 AM",
                "Sunday: Closed"
            ],
            periods: [
                OpeningHours.Period(
                    open: OpeningHours.DayTime(day: 1, time: "1200"),
                    close: OpeningHours.DayTime(day: 1, time: "2300")
                )
            ]
        )
    }

    public static var samplePhotos: [PlacePhoto] {
        [
            PlacePhoto(
                id: "photo_1",
                photoReference: "photo_ref_1",
                width: 800,
                height: 600,
                attributions: ["Photo by John Doe"]
            ),
            PlacePhoto(
                id: "photo_2",
                photoReference: "photo_ref_2",
                width: 1024,
                height: 768,
                attributions: ["Photo by Jane Smith"]
            )
        ]
    }

    public static var sampleReviews: [PlaceReview] {
        [
            PlaceReview(
                id: "review_1",
                authorName: "John Doe",
                rating: 5,
                text: "Excellent food and great service!",
                time: Date(),
                language: "en"
            ),
            PlaceReview(
                id: "review_2",
                authorName: "Jane Smith",
                rating: 4,
                text: "Good atmosphere, will come again.",
                time: Date(),
                language: "en"
            )
        ]
    }
}
