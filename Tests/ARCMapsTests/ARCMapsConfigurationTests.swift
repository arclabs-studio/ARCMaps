//
//  ARCMapsConfigurationTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 19/03/2026.
//

import Testing
@testable import ARCMaps

struct ARCMapsConfigurationTests {
    // MARK: - Default Values

    @Test("Default init uses google as default provider")
    func defaultProviderIsGoogle() {
        let config = ARCMapsConfiguration()
        #expect(config.defaultProvider == .google)
    }

    @Test("Default init sets cache size to 100")
    func defaultCacheSizeIs100() {
        let config = ARCMapsConfiguration()
        #expect(config.maxCacheSize == 100)
    }

    @Test("Default init sets cache expiration to 3600 seconds")
    func defaultCacheExpirationIs3600() {
        let config = ARCMapsConfiguration()
        #expect(config.cacheExpirationSeconds == 3600)
    }

    @Test("Default init sets photo max width to 400")
    func defaultPhotoMaxWidthIs400() {
        let config = ARCMapsConfiguration()
        #expect(config.defaultPhotoMaxWidth == 400)
    }

    @Test("Default init leaves API keys nil")
    func defaultAPIKeysAreNil() {
        let config = ARCMapsConfiguration()
        #expect(config.googlePlacesAPIKey == nil)
        #expect(config.appleMapsKeyID == nil)
        #expect(config.appleMapsTeamID == nil)
        #expect(config.appleMapsPrivateKey == nil)
    }

    // MARK: - Custom Values

    @Test("Custom Google API key is stored correctly")
    func googleAPIKeyIsStored() {
        let config = ARCMapsConfiguration(googlePlacesAPIKey: "AIza_test_key")
        #expect(config.googlePlacesAPIKey == "AIza_test_key")
    }

    @Test("Custom Apple Maps credentials are stored correctly")
    func appleMapsCredentialsAreStored() {
        let config = ARCMapsConfiguration(appleMapsKeyID: "ABC1234DEF",
                                          appleMapsTeamID: "TEAM123456",
                                          appleMapsPrivateKey: "-----BEGIN PRIVATE KEY-----")
        #expect(config.appleMapsKeyID == "ABC1234DEF")
        #expect(config.appleMapsTeamID == "TEAM123456")
        #expect(config.appleMapsPrivateKey == "-----BEGIN PRIVATE KEY-----")
    }

    @Test("Custom provider is stored correctly")
    func customProviderIsStored() {
        let config = ARCMapsConfiguration(defaultProvider: .apple)
        #expect(config.defaultProvider == .apple)
    }

    @Test("Custom cache size and expiration are stored correctly")
    func customCacheSettingsAreStored() {
        let config = ARCMapsConfiguration(maxCacheSize: 250, cacheExpirationSeconds: 7200)
        #expect(config.maxCacheSize == 250)
        #expect(config.cacheExpirationSeconds == 7200)
    }

    @Test("Custom photo max width is stored correctly")
    func customPhotoMaxWidthIsStored() {
        let config = ARCMapsConfiguration(defaultPhotoMaxWidth: 800)
        #expect(config.defaultPhotoMaxWidth == 800)
    }
}
