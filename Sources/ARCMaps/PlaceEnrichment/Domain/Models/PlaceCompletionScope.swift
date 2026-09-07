//
//  PlaceCompletionScope.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 07/09/2026.
//

import Foundation

/// What kind of place a completer may suggest.
///
/// Provider-agnostic on purpose: a caller asking for "just towns and neighbourhoods" should not
/// have to know that MapKit expresses that as a result-type mask plus an address filter.
///
/// ## Example
/// ```swift
/// // A city field wants places, not venues and not streets.
/// let service = AppleMapsCompletionService(scope: .administrativeAreas)
/// ```
public enum PlaceCompletionScope: Sendable, CaseIterable {
    /// Everything the provider offers: addresses and points of interest.
    case all

    /// Addresses only — no venues. Street addresses are still included.
    case addresses

    /// Towns, neighbourhoods, provinces and counties. No venues, no streets.
    ///
    /// This is what an address *field* usually wants: typing "torrelodon" should offer
    /// "Torrelodones, Madrid", not "Calle Torrelodones" or a health centre on it.
    ///
    /// - Note: Requires iOS 18 / macOS 15. On earlier systems there is no address filter to
    ///   apply, so this behaves as ``addresses`` — venues are still excluded, streets are not.
    case administrativeAreas
}
