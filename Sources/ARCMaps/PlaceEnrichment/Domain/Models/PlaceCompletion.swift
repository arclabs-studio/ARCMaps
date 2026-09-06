//
//  PlaceCompletion.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 06/09/2026.
//

import Foundation

/// A single autocompletion suggestion for a partially typed place query.
///
/// `PlaceCompletion` is deliberately thinner than ``PlaceSearchResult``: a completion
/// carries no coordinate, because the provider has not resolved the place yet. Call
/// ``PlaceCompleting/resolve(_:)`` with the completion the user picked to obtain a
/// full ``PlaceSearchResult``.
///
/// ## Example
/// ```swift
/// let suggestions = await completer.completions(for: "gijo", near: region)
/// for suggestion in suggestions {
///     print("\(suggestion.title) — \(suggestion.subtitle)")
/// }
///
/// if let picked = suggestions.first,
///    let place = try await completer.resolve(picked) {
///     print(place.coordinate)
/// }
/// ```
public struct PlaceCompletion: Sendable, Identifiable, Equatable {
    /// Stable identifier for this suggestion within the provider's current result set.
    public let id: String

    /// The primary suggestion text, e.g. `"Gijón"` or `"Casa Marcial"`.
    public let title: String

    /// The qualifying line beneath the title, e.g. `"Asturias, Spain"`.
    ///
    /// Providers frequently put a full street address here, so treat it as display
    /// text — never as an administrative name to store in a city or zone field.
    public let subtitle: String

    /// Creates a completion with an explicit identifier.
    ///
    /// - Parameters:
    ///   - id: Stable identifier within the provider's current result set.
    ///   - title: The primary suggestion text.
    ///   - subtitle: The qualifying line beneath the title.
    public init(id: String, title: String, subtitle: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }

    /// Creates a completion whose identifier is derived from its text.
    ///
    /// Providers such as MapKit hand back no identifier for a suggestion, so the
    /// title and subtitle together are the only stable key available.
    ///
    /// - Parameters:
    ///   - title: The primary suggestion text.
    ///   - subtitle: The qualifying line beneath the title.
    public init(title: String, subtitle: String) {
        self.init(id: Self.derivedId(title: title, subtitle: subtitle),
                  title: title,
                  subtitle: subtitle)
    }

    /// Builds the identifier used when a provider supplies none.
    ///
    /// The separator is a unit separator (U+001F) rather than a printable character, which
    /// no place name contains in practice — a printable separator such as `"|"` or `", "`
    /// appears in real subtitles and would collide.
    static func derivedId(title: String, subtitle: String) -> String {
        "\(title)\u{1F}\(subtitle)"
    }
}
