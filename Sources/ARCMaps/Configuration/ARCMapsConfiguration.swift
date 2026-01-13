import Foundation

/// Global configuration for ARCMaps
public struct ARCMapsConfiguration: Sendable {

    /// Google Places API key
    public let googlePlacesAPIKey: String?

    /// Default place provider
    public let defaultProvider: PlaceProvider

    /// Maximum cached search results
    public let maxCacheSize: Int

    /// Cache expiration in seconds
    public let cacheExpirationSeconds: TimeInterval

    /// Default photo max width
    public let defaultPhotoMaxWidth: Int

    public init(
        googlePlacesAPIKey: String? = nil,
        defaultProvider: PlaceProvider = .google,
        maxCacheSize: Int = 100,
        cacheExpirationSeconds: TimeInterval = 3600,
        defaultPhotoMaxWidth: Int = 400
    ) {
        self.googlePlacesAPIKey = googlePlacesAPIKey
        self.defaultProvider = defaultProvider
        self.maxCacheSize = maxCacheSize
        self.cacheExpirationSeconds = cacheExpirationSeconds
        self.defaultPhotoMaxWidth = defaultPhotoMaxWidth
    }

    /// Shared configuration instance
    public static var shared = ARCMapsConfiguration()
}
