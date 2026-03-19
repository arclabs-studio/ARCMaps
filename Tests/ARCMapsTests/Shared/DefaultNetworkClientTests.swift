//
//  DefaultNetworkClientTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 19/03/2026.
//

import Foundation
import Testing
@testable import ARCMaps

// MARK: - URLProtocol Mock

/// URLProtocol stub for intercepting URLSession requests in tests.
final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override static func canInit(with _: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Helpers

private struct TestPayload: Codable, Equatable {
    let id: Int
    let name: String
}

// MARK: - Tests

/// Tests must run serially because MockURLProtocol uses shared static state for the request handler.
@Suite(.serialized) struct DefaultNetworkClientTests {
    // swiftlint:disable:next force_unwrapping
    static let testURL = URL(string: "https://test.example.com/api")!

    init() {
        // Clear shared handler between tests to prevent cross-test contamination.
        MockURLProtocol.requestHandler = nil
    }

    func makeSUT() -> DefaultNetworkClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return DefaultNetworkClient(session: URLSession(configuration: config))
    }

    func makeResponse(statusCode: Int) throws -> HTTPURLResponse {
        try #require(HTTPURLResponse(url: Self.testURL, statusCode: statusCode, httpVersion: nil, headerFields: nil))
    }

    // MARK: - Success

    @Test("200 response decodes JSON into the expected type") func successfulResponseDecodesJSON() async throws {
        // Given
        let expected = TestPayload(id: 42, name: "Café de la Paix")
        MockURLProtocol.requestHandler = { [expected] _ in
            try (makeResponse(statusCode: 200),
                 JSONEncoder().encode(expected))
        }
        let sut = makeSUT()

        // When
        let result: TestPayload = try await sut.request(url: Self.testURL,
                                                        method: .get,
                                                        headers: nil,
                                                        body: nil)

        // Then
        #expect(result == expected)
    }

    // MARK: - HTTP Error Codes

    @Test("HTTP error response throws httpError with the correct status code", arguments: [404, 500])
    func httpErrorResponseThrowsCorrectError(statusCode: Int) async throws {
        // Given
        MockURLProtocol.requestHandler = { _ in
            try (makeResponse(statusCode: statusCode), Data())
        }
        let sut = makeSUT()

        // When / Then
        await #expect {
            let _: TestPayload = try await sut.request(url: Self.testURL, method: .get, headers: nil, body: nil)
        } throws: { error in
            guard case NetworkError.httpError(statusCode: statusCode) = error else { return false }
            return true
        }
    }

    // MARK: - Decoding Errors

    @Test("Malformed JSON body throws a DecodingError") func malformedJSONThrowsDecodingError() async throws {
        // Given
        MockURLProtocol.requestHandler = { _ in
            try (makeResponse(statusCode: 200),
                 Data("not-json".utf8))
        }
        let sut = makeSUT()

        // When / Then
        await #expect {
            let _: TestPayload = try await sut.request(url: Self.testURL, method: .get, headers: nil, body: nil)
        } throws: { error in
            error is DecodingError
        }
    }

    // MARK: - Request Construction

    @Test("Provided HTTP headers are forwarded on the request") func requestForwardsHeaders() async throws {
        // Given
        var capturedRequest: URLRequest?
        let responseData = try JSONEncoder().encode(TestPayload(id: 1, name: "x"))
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return try (makeResponse(statusCode: 200),
                        responseData)
        }
        let sut = makeSUT()

        // When
        let _: TestPayload = try await sut.request(url: Self.testURL,
                                                   method: .get,
                                                   headers: ["Authorization": "Bearer tok123"],
                                                   body: nil)

        // Then
        #expect(capturedRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer tok123")
    }

    @Test("Specified HTTP method is set on the request") func requestUsesSpecifiedHTTPMethod() async throws {
        // Given
        var capturedRequest: URLRequest?
        let responseData = try JSONEncoder().encode(TestPayload(id: 1, name: "x"))
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return try (makeResponse(statusCode: 200),
                        responseData)
        }
        let sut = makeSUT()

        // When
        let _: TestPayload = try await sut.request(url: Self.testURL,
                                                   method: .post,
                                                   headers: nil,
                                                   body: nil)

        // Then
        #expect(capturedRequest?.httpMethod == "POST")
    }
}
