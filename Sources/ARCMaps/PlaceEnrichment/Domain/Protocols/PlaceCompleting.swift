//
//  PlaceCompleting.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 06/09/2026.
//

import Foundation

/// A service that turns a partially typed query into place suggestions.
///
/// `PlaceCompleting` is separate from ``PlaceEnrichmentService`` on purpose. Enrichment is
/// request/response — one query, one answer. Completion is incremental: the provider keeps a
/// live query fragment and republishes its results as the user types. Folding the two into one
/// protocol would force every enrichment implementation to carry state it does not have.
///
/// ## Conformance Requirements
/// Implementations must be `Sendable`. A `@MainActor` type satisfies this, which matters
/// because the MapKit implementation is bound to the main actor by its delegate API.
///
/// ## Example
/// ```swift
/// let completer = AppleMapsCompletionService()
/// let suggestions = await completer.completions(for: "casa mar", near: currentRegion)
///
/// if let picked = suggestions.first,
///    let place = try await completer.resolve(picked) {
///     restaurant.coordinate = place.coordinate
/// }
/// ```
public protocol PlaceCompleting: Sendable {
    /// Suggestions for a partially typed query.
    ///
    /// Implementations debounce and deduplicate internally, so callers may call this on
    /// every keystroke. A fragment too short to be meaningful returns an empty array without
    /// contacting the provider.
    ///
    /// This method does not throw: a provider failure is an empty list of suggestions, not an
    /// error worth interrupting typing for.
    ///
    /// - Parameters:
    ///   - fragment: The text typed so far.
    ///   - region: A geographic bias for the results, or `nil` for no bias.
    /// - Returns: Suggestions for the fragment, or an empty array.
    func completions(for fragment: String, near region: MapRegion?) async -> [PlaceCompletion]

    /// Resolves a picked suggestion into a full place, coordinate included.
    ///
    /// - Parameter completion: A suggestion previously returned by
    ///   ``completions(for:near:)`` on the same instance.
    /// - Returns: The resolved place, or `nil` if the provider matched nothing.
    /// - Throws: ``PlaceEnrichmentError`` if the lookup fails.
    func resolve(_ completion: PlaceCompletion) async throws -> PlaceSearchResult?
}
