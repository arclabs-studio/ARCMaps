//
//  NetworkClient.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// Standard HTTP methods for REST API requests.
///
/// Represents the most commonly used HTTP methods in RESTful APIs.
public enum HTTPMethod: String, Sendable {
    /// HTTP GET method for retrieving resources.
    case get = "GET"

    /// HTTP POST method for creating new resources.
    case post = "POST"

    /// HTTP PUT method for replacing existing resources.
    case put = "PUT"

    /// HTTP DELETE method for removing resources.
    case delete = "DELETE"
}

/// A protocol defining the interface for making HTTP network requests.
///
/// Conforming types provide the ability to perform asynchronous HTTP requests
/// and decode responses into the specified type.
///
/// ## Conformance Requirements
/// Implementations must be `Sendable` to support concurrent usage across actors.
///
/// ## Example
/// ```swift
/// let client: NetworkClientProtocol = DefaultNetworkClient()
/// let response: MyResponse = try await client.request(
///     url: apiURL,
///     method: .get,
///     headers: ["Authorization": "Bearer token"],
///     body: nil
/// )
/// ```
public protocol NetworkClientProtocol: Sendable {
    /// Performs an HTTP request and decodes the response.
    ///
    /// - Parameters:
    ///   - url: The URL to send the request to.
    ///   - method: The HTTP method to use.
    ///   - headers: Optional HTTP headers to include in the request.
    ///   - body: Optional request body data.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: ``NetworkError`` if the request fails or the response cannot be decoded.
    func request<T: Decodable & Sendable>(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?
    ) async throws -> T
}

/// A thread-safe HTTP client implementation using `URLSession`.
///
/// `DefaultNetworkClient` is an actor that provides safe concurrent access to
/// network operations. It handles JSON decoding and HTTP error responses automatically.
///
/// ## Example
/// ```swift
/// let client = DefaultNetworkClient()
/// let places: PlacesResponse = try await client.request(
///     url: URL(string: "https://api.example.com/places")!,
///     method: .get,
///     headers: nil,
///     body: nil
/// )
/// ```
public actor DefaultNetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    /// Creates a new network client with the specified session and decoder.
    ///
    /// - Parameters:
    ///   - session: The URL session to use for requests. Defaults to `.shared`.
    ///   - decoder: The JSON decoder for parsing responses. Defaults to a new `JSONDecoder`.
    public init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    /// Performs an HTTP request and decodes the JSON response.
    ///
    /// - Parameters:
    ///   - url: The URL to send the request to.
    ///   - method: The HTTP method to use. Defaults to `.get`.
    ///   - headers: Optional HTTP headers to include in the request.
    ///   - body: Optional request body data.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: ``NetworkError/invalidResponse`` if the response is not an HTTP response,
    ///   ``NetworkError/httpError(statusCode:)`` for non-2xx status codes, or
    ///   a decoding error if JSON parsing fails.
    public func request<T: Decodable & Sendable>(
        url: URL,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        // Set headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        return try decoder.decode(T.self, from: data)
    }
}

/// Errors that can occur during network operations.
///
/// `NetworkError` represents the different failure modes when making HTTP requests,
/// including invalid responses, HTTP status errors, and JSON decoding failures.
///
/// ## Error Handling
/// ```swift
/// do {
///     let data: MyData = try await client.request(url: url, method: .get, headers: nil, body: nil)
/// } catch let error as NetworkError {
///     switch error {
///     case .invalidResponse:
///         print("Server returned an invalid response")
///     case .httpError(let statusCode):
///         print("HTTP error with status: \(statusCode)")
///     case .decodingError(let message):
///         print("Failed to parse response: \(message)")
///     }
/// }
/// ```
public enum NetworkError: LocalizedError, Sendable {
    /// The server response was not a valid HTTP response.
    case invalidResponse

    /// The server returned a non-successful HTTP status code (outside 200-299 range).
    ///
    /// - Parameter statusCode: The HTTP status code returned by the server.
    case httpError(statusCode: Int)

    /// The response body could not be decoded into the expected type.
    ///
    /// - Parameter message: A description of what went wrong during decoding.
    case decodingError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Invalid server response"
        case let .httpError(code):
            "HTTP error: \(code)"
        case let .decodingError(message):
            "Failed to decode response: \(message)"
        }
    }
}
