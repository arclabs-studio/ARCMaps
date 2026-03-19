//
//  AppleMapsTokenProviderTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 19/03/2026.
//

import CryptoKit
import Foundation
import Testing
@testable import ARCMaps

// MARK: - Base64URL Decode Helper

private extension Data {
    /// Decodes a base64url-encoded string (no padding required).
    init?(base64URLEncoded string: String) {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder != 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        self.init(base64Encoded: base64)
    }
}

// MARK: - Tests

struct AppleMapsTokenProviderTests {
    static let testKeyID = "TESTKEY0001"
    static let testTeamID = "TESTTEAM001"

    func makeSUT(keyID: String = testKeyID, teamID: String = testTeamID) throws -> AppleMapsTokenProvider {
        let key = P256.Signing.PrivateKey()
        return try AppleMapsTokenProvider(keyID: keyID, teamID: teamID, privateKeyPEM: key.pemRepresentation)
    }

    func decodeJWTPart(_ base64url: Substring) throws -> [String: Any] {
        let data = try #require(Data(base64URLEncoded: String(base64url)))
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }

    // MARK: - Initialisation

    @Test("Init succeeds with valid P256 PEM key")
    func initSucceedsWithValidKey() {
        #expect(throws: Never.self) { try makeSUT() }
    }

    @Test("Init throws invalidPrivateKey for bad PEM input")
    func initThrowsForInvalidPEM() {
        #expect {
            try AppleMapsTokenProvider(keyID: "k", teamID: "t", privateKeyPEM: "not-a-valid-key")
        } throws: { error in
            guard case AppleMapsTokenError.invalidPrivateKey = error else { return false }
            return true
        }
    }

    // MARK: - Token Structure

    @Test("Token consists of three dot-separated parts")
    func tokenHasThreeParts() async throws {
        let sut = try makeSUT()
        let token = try await sut.token()
        #expect(token.split(separator: ".").count == 3)
    }

    @Test("Token header contains ES256 algorithm, JWT type, and correct key ID")
    func tokenHeaderIsCorrect() async throws {
        let sut = try makeSUT()
        let token = try await sut.token()
        let parts = token.split(separator: ".")
        let header = try decodeJWTPart(parts[0])

        #expect(header["alg"] as? String == "ES256")
        #expect(header["typ"] as? String == "JWT")
        #expect(header["kid"] as? String == Self.testKeyID)
    }

    @Test("Token payload contains correct issuer and 30-minute lifetime")
    func tokenPayloadIsCorrect() async throws {
        let before = Int(Date().timeIntervalSince1970)
        let sut = try makeSUT()
        let token = try await sut.token()
        let after = Int(Date().timeIntervalSince1970)

        let parts = token.split(separator: ".")
        let payload = try decodeJWTPart(parts[1])

        #expect(payload["iss"] as? String == Self.testTeamID)

        let iat = try #require(payload["iat"] as? Int)
        let exp = try #require(payload["exp"] as? Int)

        #expect(iat >= before)
        #expect(iat <= after + 1)
        #expect(exp - iat == 1800) // 30-minute token lifetime
    }

    @Test("Token signature part is valid base64url-encoded data")
    func tokenSignatureIsValidBase64URL() async throws {
        let sut = try makeSUT()
        let token = try await sut.token()
        let parts = token.split(separator: ".")
        #expect(Data(base64URLEncoded: String(parts[2])) != nil)
    }

    // MARK: - Caching

    @Test("Consecutive token calls return the same cached token")
    func tokenIsCachedAcrossConsecutiveCalls() async throws {
        let sut = try makeSUT()
        let first = try await sut.token()
        let second = try await sut.token()
        #expect(first == second)
    }

    // MARK: - Key Isolation

    @Test("Different providers with different key IDs produce tokens with different kid claims")
    func differentKeyIDsProduceDifferentKidClaims() async throws {
        let key = P256.Signing.PrivateKey()
        let sutA = try AppleMapsTokenProvider(keyID: "KEY_A", teamID: "TEAM01", privateKeyPEM: key.pemRepresentation)
        let sutB = try AppleMapsTokenProvider(keyID: "KEY_B", teamID: "TEAM01", privateKeyPEM: key.pemRepresentation)

        let tokenA = try await sutA.token()
        let tokenB = try await sutB.token()

        let partsA = tokenA.split(separator: ".")
        let partsB = tokenB.split(separator: ".")

        let headerA = try decodeJWTPart(partsA[0])
        let headerB = try decodeJWTPart(partsB[0])

        #expect(headerA["kid"] as? String == "KEY_A")
        #expect(headerB["kid"] as? String == "KEY_B")
        #expect(headerA["kid"] as? String != headerB["kid"] as? String)
    }
}
