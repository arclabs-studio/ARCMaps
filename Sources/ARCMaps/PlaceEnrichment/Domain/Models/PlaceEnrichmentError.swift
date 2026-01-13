//
//  PlaceEnrichmentError.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// Errors that can occur during place search and enrichment operations.
///
/// These errors cover the various failure modes when interacting with place
/// providers, including validation, network, and service-level errors.
///
/// ## Error Handling
/// ```swift
/// do {
///     let results = try await placesService.searchPlaces(query: query)
/// } catch let error as PlaceEnrichmentError {
///     switch error {
///     case .invalidAPIKey:
///         showConfigurationError()
///     case .rateLimitExceeded:
///         scheduleRetry()
///     case .noResultsFound:
///         showEmptyState()
///     default:
///         showGenericError(error.localizedDescription)
///     }
/// }
/// ```
public enum PlaceEnrichmentError: LocalizedError, Sendable, Equatable {
    /// The search query is empty or malformed.
    case invalidQuery

    /// No places matched the search criteria.
    case noResultsFound

    /// A network error occurred during the request.
    case networkError(String)

    /// The API key is missing or invalid.
    case invalidAPIKey

    /// The provider's rate limit has been exceeded.
    case rateLimitExceeded

    /// The provider returned an unexpected or malformed response.
    case invalidResponse

    /// The specified provider is currently unavailable.
    case serviceUnavailable(PlaceProvider)

    /// Failed to download a photo from the provider.
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
