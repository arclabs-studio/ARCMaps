//
//  AppleMapsServerDTO.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 18/03/2026.
//

import Foundation

// MARK: - Search Response

/// Top-level search response from the Apple Maps Server API (`GET /v1/search`).
struct AppleMapsServerSearchResponse: Decodable {
    let results: [AppleMapsServerSearchResult]
}

/// A single search result entry returned by the Apple Maps Server API.
struct AppleMapsServerSearchResult: Decodable {
    let place: AppleMapsServerPlace?
}

// MARK: - Place Detail Response

/// Top-level place detail response from the Apple Maps Server API (`GET /v1/place/:id`).
struct AppleMapsServerPlaceResponse: Decodable {
    let id: String?
    let name: String?
    let formattedAddressLines: [String]?
    let coordinate: AppleMapsServerCoordinate?
    let pointOfInterestCategory: String?
    let url: String?
    let telephone: String?

    enum CodingKeys: String, CodingKey {
        case id, name, coordinate, url, telephone
        case formattedAddressLines
        case pointOfInterestCategory
    }
}

// MARK: - Shared Models

/// A place returned by the Apple Maps Server API.
struct AppleMapsServerPlace: Decodable {
    let placeId: String?
    let name: String?
    let formattedAddressLines: [String]?
    let coordinate: AppleMapsServerCoordinate?
    let pointOfInterestCategory: String?

    enum CodingKeys: String, CodingKey {
        case name, coordinate
        case placeId
        case formattedAddressLines
        case pointOfInterestCategory
    }
}

/// Geographic coordinates in the Apple Maps Server API format.
struct AppleMapsServerCoordinate: Decodable {
    let latitude: Double
    let longitude: Double
}
