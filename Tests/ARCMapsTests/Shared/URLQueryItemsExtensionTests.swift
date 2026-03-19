//
//  URLQueryItemsExtensionTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 19/03/2026.
//

import Foundation
import Testing
@testable import ARCMaps

struct URLQueryItemsExtensionTests {
    // MARK: - URL.build

    @Test("build creates URL with query items appended")
    func buildCreatesURLWithQueryItems() throws {
        // Given
        let items = [URLQueryItem(name: "q", value: "pizza"), URLQueryItem(name: "lang", value: "en")]

        // When
        let url = URL.build(baseURL: "https://api.example.com", queryItems: items)

        // Then
        let result = try #require(url)
        #expect(result.host() == "api.example.com")
        let components = URLComponents(url: result, resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "q", value: "pizza")) == true)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "lang", value: "en")) == true)
    }

    @Test("build with path overrides the base URL path")
    func buildWithPathSetsCorrectPath() throws {
        // Given / When
        let url = URL.build(baseURL: "https://api.example.com",
                            path: "/v1/search",
                            queryItems: [URLQueryItem(name: "q", value: "test")])

        // Then
        let result = try #require(url)
        #expect(result.path() == "/v1/search")
    }

    @Test("build returns nil for an invalid base URL string")
    func buildReturnsNilForInvalidBaseURL() {
        let url = URL.build(baseURL: "not a valid url ://", queryItems: [])
        #expect(url == nil)
    }

    // MARK: - appendingQueryItems

    @Test("appendingQueryItems adds items to a URL with no existing params")
    func appendingQueryItemsToURLWithNoParams() throws {
        // Given
        let base = try #require(URL(string: "https://api.example.com/places"))
        let items = [URLQueryItem(name: "key", value: "abc123")]

        // When
        let result = base.appendingQueryItems(items)

        // Then
        let url = try #require(result)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "key", value: "abc123")) == true)
    }

    @Test("appendingQueryItems preserves existing query parameters")
    func appendingQueryItemsPreservesExistingParams() throws {
        // Given
        let base = try #require(URL(string: "https://api.example.com/places?lang=en"))
        let items = [URLQueryItem(name: "radius", value: "1000")]

        // When
        let result = base.appendingQueryItems(items)

        // Then
        let url = try #require(result)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "lang", value: "en")) == true)
        #expect(components?.queryItems?.contains(URLQueryItem(name: "radius", value: "1000")) == true)
    }

    @Test("appendingQueryItems with empty array returns equivalent URL")
    func appendingEmptyItemsReturnsEquivalentURL() throws {
        // Given
        let base = try #require(URL(string: "https://api.example.com/places?q=pizza"))

        // When
        let result = base.appendingQueryItems([])

        // Then
        let url = try #require(result)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.count == 1)
    }
}
