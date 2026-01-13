//
//  ARCMapsConfiguration.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// Global configuration settings for the ARCMaps package.
///
/// Configure `ARCMapsConfiguration.shared` before using ARCMaps services.
/// This must be done on the main actor, typically in your app's initialization.
///
/// ## Example
/// ```swift
/// @main
/// struct MyApp: App {
///     init() {
///         ARCMapsConfiguration.shared = ARCMapsConfiguration(
///             googlePlacesAPIKey: "YOUR_API_KEY",
///             defaultProvider: .google,
///             maxCacheSize: 200,
///             cacheExpirationSeconds: 7200
///         )
///     }
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///         }
///     }
/// }
/// ```
public struct ARCMapsConfiguration: Sendable {
    /// API key for Google Places API. Required when using the Google provider.
    public let googlePlacesAPIKey: String?

    /// The default provider to use for place searches.
    public let defaultProvider: PlaceProvider

    /// Maximum number of search results to cache.
    public let maxCacheSize: Int

    /// Time in seconds before cached results expire.
    public let cacheExpirationSeconds: TimeInterval

    /// Default maximum width in pixels for fetched photos.
    public let defaultPhotoMaxWidth: Int

    /// Creates a new configuration with the specified settings.
    ///
    /// - Parameters:
    ///   - googlePlacesAPIKey: API key for Google Places (required for Google provider).
    ///   - defaultProvider: The default provider for place searches.
    ///   - maxCacheSize: Maximum cached search results (default: 100).
    ///   - cacheExpirationSeconds: Cache TTL in seconds (default: 3600 = 1 hour).
    ///   - defaultPhotoMaxWidth: Default photo width in pixels (default: 400).
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

    /// The shared configuration instance used throughout the package.
    ///
    /// Set this property during app initialization before using any ARCMaps services.
    @MainActor public static var shared = ARCMapsConfiguration()
}
