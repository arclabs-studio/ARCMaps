//
//  MockAppleMapsTokenProvider.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 18/03/2026.
//

import Foundation
@testable import ARCMaps

public actor MockAppleMapsTokenProvider: AppleMapsTokenProviding {
    public var mockToken = "mock.jwt.token"
    public var shouldThrowError = false

    public init() {}

    public func token() async throws -> String {
        if shouldThrowError {
            throw AppleMapsTokenError.signingFailed
        }
        return mockToken
    }
}
