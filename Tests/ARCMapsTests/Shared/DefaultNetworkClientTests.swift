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

    override class func canInit(with _: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

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

private struct TestPayload: Codable, Sendable, Equatable {
    let id: Int
    let name: String
}

// MARK: - Tests

/// Tests must run serially because MockURLProtocol uses shared static state for the request handler.
@Suite(.serialized)
struct DefaultNetworkClientTests {
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

    func makeResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: Self.testURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    // MARK: - Success

    @Test("200 response decodes JSON into the expected type")
    func successfulResponseDecodesJSON() async throws {
        // Given
        let expected = TestPayload(id: 42, name: "Café de la Paix")
        MockURLProtocol.requestHandler = { [expected] _ in
            (HTTPURLResponse(url: Self.testURL, statusCode: 200, httpVersion: nil, headerFields: nil)!,
             try JSONEncoder().encode(expected))
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

    @Test("404 response throws httpError with status 404")
    func notFoundResponseThrowsHTTPError() async throws {
        // Given
        MockURLProtocol.requestHandler = { _ in
            (HTTPURLResponse(url: Self.testURL, statusCode: 404, httpVersion: nil, headerFields: nil)!, Data())
        }
        let sut = makeSUT()

        // When / Then
        await #expect {
            let _: TestPayload = try await sut.request(url: Self.testURL, method: .get, headers: nil, body: nil)
        } throws: { error in
            guard case NetworkError.httpError(statusCode: 404) = error else { return false }
            return true
        }
    }

    @Test("500 response throws httpError with status 500")
    func serverErrorResponseThrowsHTTPError() async throws {
        // Given
        MockURLProtocol.requestHandler = { _ in
            (HTTPURLResponse(url: Self.testURL, statusCode: 500, httpVersion: nil, headerFields: nil)!, Data())
        }
        let sut = makeSUT()

        // When / Then
        await #expect {
            let _: TestPayload = try await sut.request(url: Self.testURL, method: .get, headers: nil, body: nil)
        } throws: { error in
            guard case NetworkError.httpError(statusCode: 500) = error else { return false }
            return true
        }
    }

    // MARK: - Decoding Errors

    @Test("Malformed JSON body throws a DecodingError")
    func malformedJSONThrowsDecodingError() async throws {
        // Given
        MockURLProtocol.requestHandler = { _ in
            (HTTPURLResponse(url: Self.testURL, statusCode: 200, httpVersion: nil, headerFields: nil)!,
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

    @Test("Provided HTTP headers are forwarded on the request")
    func requestForwardsHeaders() async throws {
        // Given
        var capturedRequest: URLRequest?
        let responseData = try JSONEncoder().encode(TestPayload(id: 1, name: "x"))
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (HTTPURLResponse(url: Self.testURL, statusCode: 200, httpVersion: nil, headerFields: nil)!,
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

    @Test("Specified HTTP method is set on the request")
    func requestUsesSpecifiedHTTPMethod() async throws {
        // Given
        var capturedRequest: URLRequest?
        let responseData = try JSONEncoder().encode(TestPayload(id: 1, name: "x"))
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (HTTPURLResponse(url: Self.testURL, statusCode: 200, httpVersion: nil, headerFields: nil)!,
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
