//
//  URL+QueryItems.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

extension URL {
    /// Create URL with query items
    public static func build(
        baseURL: String,
        path: String? = nil,
        queryItems: [URLQueryItem]
    ) -> URL? {
        var components = URLComponents(string: baseURL)

        if let path {
            components?.path = path
        }

        components?.queryItems = queryItems

        return components?.url
    }

    /// Add query items to existing URL
    public func appendingQueryItems(_ queryItems: [URLQueryItem]) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }

        var existingItems = components.queryItems ?? []
        existingItems.append(contentsOf: queryItems)
        components.queryItems = existingItems

        return components.url
    }
}
