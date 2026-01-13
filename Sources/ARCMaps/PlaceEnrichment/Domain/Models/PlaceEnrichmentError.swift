//
//  PlaceEnrichmentError.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// Errors that can occur during place enrichment
public enum PlaceEnrichmentError: LocalizedError, Sendable, Equatable {
    case invalidQuery
    case noResultsFound
    case networkError(String)
    case invalidAPIKey
    case rateLimitExceeded
    case invalidResponse
    case serviceUnavailable(PlaceProvider)
    case photoDownloadFailed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidQuery:
            "The search query is invalid"
        case .noResultsFound:
            "No places found matching your search"
        case let .networkError(message):
            "Network error: \(message)"
        case .invalidAPIKey:
            "Invalid API key configuration"
        case .rateLimitExceeded:
            "API rate limit exceeded. Please try again later"
        case .invalidResponse:
            "Invalid response from service"
        case let .serviceUnavailable(provider):
            "\(provider.displayName) is currently unavailable"
        case let .photoDownloadFailed(reference):
            "Failed to download photo: \(reference)"
        }
    }

    public static func == (lhs: PlaceEnrichmentError, rhs: PlaceEnrichmentError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidQuery, .invalidQuery),
             (.noResultsFound, .noResultsFound),
             (.invalidAPIKey, .invalidAPIKey),
             (.rateLimitExceeded, .rateLimitExceeded),
             (.invalidResponse, .invalidResponse):
            true
        case let (.networkError(lhsMsg), .networkError(rhsMsg)):
            lhsMsg == rhsMsg
        case let (.serviceUnavailable(lhsProvider), .serviceUnavailable(rhsProvider)):
            lhsProvider == rhsProvider
        case let (.photoDownloadFailed(lhsRef), .photoDownloadFailed(rhsRef)):
            lhsRef == rhsRef
        default:
            false
        }
    }
}
