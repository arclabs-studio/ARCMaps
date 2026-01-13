import Foundation
@testable import ARCMaps

public actor MockNetworkClient: NetworkClientProtocol {

    public var mockResponse: Any?
    public var shouldThrowError = false
    public var errorToThrow: Error = NetworkError.invalidResponse

    public private(set) var requestCount = 0
    public private(set) var lastURL: URL?
    public private(set) var lastMethod: HTTPMethod?

    public init() {}

    public func request<T>(
        url: URL,
        method: HTTPMethod,
        headers: [String : String]?,
        body: Data?
    ) async throws -> T where T : Decodable & Sendable {
        requestCount += 1
        lastURL = url
        lastMethod = method

        if shouldThrowError {
            throw errorToThrow
        }

        guard let response = mockResponse as? T else {
            throw NetworkError.invalidResponse
        }

        return response
    }

    public func reset() {
        requestCount = 0
        lastURL = nil
        lastMethod = nil
        shouldThrowError = false
        mockResponse = nil
    }
}
