//
//  AppleMapsCompletionServiceTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 06/09/2026.
//

import CoreLocation
import Testing
@testable import ARCMaps

/// These tests cover only what can be decided without MapKit answering: the guards that keep
/// a request from being made at all, and the failure path of `resolve`. Anything past
/// `queryFragment` is MapKit's own network service, which is not an oracle a test can hold.
@MainActor struct AppleMapsCompletionServiceTests {
    private func makeSUT(scope: PlaceCompletionScope = .all,
                         debounce: Duration = .milliseconds(1)) -> AppleMapsCompletionService {
        AppleMapsCompletionService(scope: scope, debounce: debounce)
    }

    // MARK: - Scope

    @Test("Every scope builds a usable service", arguments: PlaceCompletionScope.allCases)
    func everyScopeBuilds(scope: PlaceCompletionScope) async {
        // Given — .administrativeAreas configures an address filter on iOS 18+ and nothing on
        // iOS 17; neither path may trap, and the short-fragment guard must still hold.
        let sut = makeSUT(scope: scope)

        // When
        let suggestions = await sut.completions(for: "ca", near: nil)

        // Then
        #expect(suggestions.isEmpty)
    }

    // MARK: - Fragment Guards

    @Test("A fragment shorter than the minimum yields no suggestions") func shortFragmentYieldsNothing() async {
        // Given
        let sut = makeSUT()

        // When
        let suggestions = await sut.completions(for: "ca", near: nil)

        // Then
        #expect(suggestions.isEmpty)
    }

    @Test("A fragment that is only whitespace yields no suggestions") func whitespaceFragmentYieldsNothing() async {
        // Given
        let sut = makeSUT()

        // When
        let suggestions = await sut.completions(for: "     ", near: nil)

        // Then
        #expect(suggestions.isEmpty)
    }

    @Test("The minimum length is measured after trimming, not on the raw fragment")
    func fragmentIsTrimmedBeforeMeasuring() async {
        // Given — five characters, two of them meaningful
        let sut = makeSUT()

        // When
        let suggestions = await sut.completions(for: "  ca ", near: nil)

        // Then
        #expect(suggestions.isEmpty)
    }

    // MARK: - Cancellation

    @Test("Cancelling while debouncing returns empty rather than hanging")
    func cancellationDuringDebounceReturnsEmpty() async {
        // Given — a debounce long enough that cancellation lands inside it
        let sut = makeSUT(debounce: .seconds(5))

        // When
        let task = Task { @MainActor in
            await sut.completions(for: "casa marcial", near: nil)
        }
        task.cancel()
        let suggestions = await task.value

        // Then
        #expect(suggestions.isEmpty)
    }

    // MARK: - Resolve

    @Test("Resolving a completion this service never published throws rather than guessing")
    func resolvingUnknownCompletionThrows() async {
        // Given
        let sut = makeSUT()
        let foreign = PlaceCompletion(title: "Casa Marcial", subtitle: "Arriondas, Asturias")

        // When / Then
        await #expect(throws: PlaceEnrichmentError.noResultsFound) {
            _ = try await sut.resolve(foreign)
        }
    }
}
