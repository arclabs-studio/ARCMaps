//
//  AppleMapsTokenProvider.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 18/03/2026.
//

import CryptoKit
import Foundation

/// Errors that can occur during Apple Maps JWT token generation.
public enum AppleMapsTokenError: Error {
    case invalidPrivateKey(String)
    case signingFailed
}

/// A type that can provide a JWT token for Apple Maps Server API authentication.
public protocol AppleMapsTokenProviding: Sendable {
    /// Returns a valid JWT token, refreshing it if expired.
    func token() async throws -> String
}

/// Generates and caches JWT tokens for Apple Maps Server API authentication.
///
/// Tokens are signed using ES256 (ECDSA P256 SHA-256) and cached until
/// they are about to expire, minimising signing overhead.
///
/// ## Usage
/// ```swift
/// let provider = try AppleMapsTokenProvider(
///     keyID: "ABC1234DEF",
///     teamID: "TEAM123456",
///     privateKeyPEM: "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
/// )
/// let token = try await provider.token()
/// ```
public actor AppleMapsTokenProvider: AppleMapsTokenProviding {
    private let keyID: String
    private let teamID: String
    private let privateKey: P256.Signing.PrivateKey

    /// Token lifetime in seconds. Apple recommends tokens valid for up to 30 minutes.
    private let tokenLifetime: TimeInterval = 1800

    private var cachedToken: String?
    /// Expiry date with a 60-second early-refresh buffer.
    private var tokenExpiry: Date?

    public init(keyID: String, teamID: String, privateKeyPEM: String) throws {
        self.keyID = keyID
        self.teamID = teamID
        do {
            privateKey = try P256.Signing.PrivateKey(pemRepresentation: privateKeyPEM)
        } catch {
            throw AppleMapsTokenError.invalidPrivateKey(error.localizedDescription)
        }
    }

    /// Returns a valid JWT token, generating a new one if the cached token has expired.
    public func token() async throws -> String {
        let now = Date()
        if let token = cachedToken, let expiry = tokenExpiry, now < expiry {
            return token
        }

        let issued = now
        let expiry = issued.addingTimeInterval(tokenLifetime)

        let newToken = try generateJWT(issuedAt: issued, expiry: expiry)
        cachedToken = newToken
        // Refresh 60 seconds before actual expiry
        tokenExpiry = expiry.addingTimeInterval(-60)

        return newToken
    }

    // MARK: - Private

    private func generateJWT(issuedAt: Date, expiry: Date) throws -> String {
        let header: [String: Any] = ["alg": "ES256",
                                     "kid": keyID,
                                     "typ": "JWT"]
        let payload: [String: Any] = ["iss": teamID,
                                      "iat": Int(issuedAt.timeIntervalSince1970),
                                      "exp": Int(expiry.timeIntervalSince1970)]

        let headerB64 = try encodeJWTPart(header)
        let payloadB64 = try encodeJWTPart(payload)

        let signingInput = "\(headerB64).\(payloadB64)"
        guard let signingData = signingInput.data(using: .utf8) else {
            throw AppleMapsTokenError.signingFailed
        }

        let signature = try privateKey.signature(for: signingData)
        let signatureB64 = signature.rawRepresentation.base64URLEncoded

        return "\(signingInput).\(signatureB64)"
    }

    private func encodeJWTPart(_ dictionary: [String: Any]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [.sortedKeys])
        return data.base64URLEncoded
    }
}

// MARK: - Data Base64URL Extension

extension Data {
    /// Base64 URL-encoded string without padding characters.
    fileprivate var base64URLEncoded: String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
