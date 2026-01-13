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
            return "The search query is invalid"
        case .noResultsFound:
            return "No places found matching your search"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidAPIKey:
            return "Invalid API key configuration"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later"
        case .invalidResponse:
            return "Invalid response from service"
        case .serviceUnavailable(let provider):
            return "\(provider.displayName) is currently unavailable"
        case .photoDownloadFailed(let reference):
            return "Failed to download photo: \(reference)"
        }
    }

    public static func == (lhs: PlaceEnrichmentError, rhs: PlaceEnrichmentError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidQuery, .invalidQuery),
             (.noResultsFound, .noResultsFound),
             (.invalidAPIKey, .invalidAPIKey),
             (.rateLimitExceeded, .rateLimitExceeded),
             (.invalidResponse, .invalidResponse):
            return true
        case (.networkError(let lhsMsg), .networkError(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.serviceUnavailable(let lhsProvider), .serviceUnavailable(let rhsProvider)):
            return lhsProvider == rhsProvider
        case (.photoDownloadFailed(let lhsRef), .photoDownloadFailed(let rhsRef)):
            return lhsRef == rhsRef
        default:
            return false
        }
    }
}
