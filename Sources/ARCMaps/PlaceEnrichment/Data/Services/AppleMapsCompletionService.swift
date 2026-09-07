//
//  AppleMapsCompletionService.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 06/09/2026.
//

import ARCLogger
import CoreLocation
import Foundation
import MapKit

/// MapKit-backed place autocompletion.
///
/// `MKLocalSearchCompleter` is a stateful delegate API: it holds one live query fragment,
/// restarts its search every time that fragment is written, and republishes results through
/// `MKLocalSearchCompleterDelegate` on the main thread. That is why this type is bound to the
/// main actor while ``AppleMapsSearchService`` — request/response — is an actor.
///
/// ## Example
/// ```swift
/// let service = AppleMapsCompletionService()
/// let suggestions = await service.completions(for: "casa mar", near: region)
/// let place = try await service.resolve(suggestions[0])
/// ```
@MainActor public final class AppleMapsCompletionService: PlaceCompleting {
    /// Fragments shorter than this return nothing: MapKit answers one or two letters with
    /// noise, and every keystroke below the threshold would cost a request.
    static let minimumFragmentLength = 3

    /// How long typing must pause before the fragment is handed to MapKit.
    private let debounce: Duration
    private let completer: MKLocalSearchCompleter
    private let completerDelegate = CompleterDelegate()
    private let logger = ARCLogger(category: "AppleMapsCompletionService")

    /// The caller waiting on the next delegate callback, if any.
    private var pending: CheckedContinuation<[PlaceCompletion], Never>?

    /// The last fragment MapKit answered, and its answer.
    ///
    /// Writing the same value back to `queryFragment` does not make the completer publish
    /// again, so without this a repeated fragment would wait on a callback that never comes.
    private var lastFragment: String?
    private var lastResults: [PlaceCompletion] = []

    /// Creates a completion service.
    ///
    /// - Parameters:
    ///   - resultTypes: What MapKit may suggest. Defaults to addresses and points of
    ///     interest; query suggestions ("coffee") are excluded because they resolve to no
    ///     single place.
    ///   - debounce: How long typing must pause before a fragment is sent.
    public init(resultTypes: MKLocalSearchCompleter.ResultType = [.address, .pointOfInterest],
                debounce: Duration = .milliseconds(250)) {
        self.debounce = debounce
        completer = MKLocalSearchCompleter()
        completer.resultTypes = resultTypes
        completer.delegate = completerDelegate
        completerDelegate.owner = self
    }

    // No deinit: the completer and its delegate box are owned solely by this object and die
    // with it, and `MKLocalSearchCompleter` holds its delegate weakly, so an in-flight search
    // has nothing left to call back into. A deinit cancelling the completer would also be
    // reaching at a main-actor-isolated, non-Sendable object from a nonisolated deinit.

    // MARK: - PlaceCompleting

    public func completions(for fragment: String, near region: MapRegion?) async -> [PlaceCompletion] {
        let trimmed = fragment.trimmingCharacters(in: .whitespacesAndNewlines)

        // A superseded caller is answered rather than left suspended: only one continuation
        // can be outstanding, because only one fragment can be live in the completer.
        finishPending(with: [])

        guard trimmed.count >= Self.minimumFragmentLength else {
            completer.cancel()
            return []
        }

        if let region {
            completer.region = region.mkCoordinateRegion
        }

        // Debounced here rather than in every caller: the completer restarts its search on
        // each write, so a per-keystroke write both wastes requests and answers a fragment
        // the user has already typed past.
        do {
            try await Task.sleep(for: debounce)
        } catch {
            return [] // cancelled while waiting — the user kept typing
        }

        if trimmed == lastFragment {
            return lastResults
        }

        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                pending = continuation
                completer.queryFragment = trimmed
            }
        } onCancel: {
            Task { @MainActor [weak self] in
                self?.finishPending(with: [])
            }
        }
    }

    public func resolve(_ completion: PlaceCompletion) async throws -> PlaceSearchResult? {
        guard let mapKitCompletion = completerDelegate.rawCompletion(for: completion.id) else {
            logger.warning("Asked to resolve a completion this service never published")
            throw PlaceEnrichmentError.noResultsFound
        }

        let search = MKLocalSearch(request: MKLocalSearch.Request(completion: mapKitCompletion))

        do {
            let response = try await search.start()
            guard let mapItem = response.mapItems.first else {
                return nil
            }
            return AppleMapsPlaceMapper.searchResult(from: mapItem)
        } catch {
            logger.error("Failed to resolve completion: \(error.localizedDescription)")
            throw PlaceEnrichmentError.wrap(error)
        }
    }

    // MARK: - Delegate Callbacks

    fileprivate func completerDidUpdateResults(_ published: [PlaceCompletion], fragment: String) {
        lastFragment = fragment
        lastResults = published
        finishPending(with: published)
    }

    fileprivate func completerDidFail(_ description: String) {
        // A failed completion is an empty dropdown, never an interruption while typing.
        logger.debug("Completion failed: \(description)")
        finishPending(with: [])
    }

    // MARK: - Private Helpers

    private func finishPending(with results: [PlaceCompletion]) {
        guard let continuation = pending else { return }
        pending = nil
        continuation.resume(returning: results)
    }
}

// MARK: - Delegate Box

/// Receives `MKLocalSearchCompleterDelegate` callbacks on behalf of the service.
///
/// The delegate protocol is an Objective-C protocol with no main-actor annotation, so its
/// requirements cannot be satisfied by main-actor-isolated methods directly. MapKit does
/// deliver these callbacks on the main thread, which `MainActor.assumeIsolated` asserts
/// dynamically — the sanctioned way to state that, as opposed to disabling the checking.
private final class CompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    /// Held weakly: the service owns this box and the completer holds it as its delegate.
    weak var owner: AppleMapsCompletionService?

    /// The MapKit completions behind the last published suggestions, keyed by
    /// ``PlaceCompletion/id``.
    ///
    /// These live here rather than on the service because `MKLocalSearchCompletion` is not
    /// `Sendable` and so cannot be handed to the main actor — but `resolve(_:)` needs the
    /// original object, since a ``PlaceCompletion`` carries no coordinate and cannot be
    /// searched for on its own.
    private var index: [String: MKLocalSearchCompletion] = [:]

    func rawCompletion(for id: String) -> MKLocalSearchCompletion? {
        index[id]
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        var published: [PlaceCompletion] = []
        var mapped: [String: MKLocalSearchCompletion] = [:]
        published.reserveCapacity(completer.results.count)

        for result in completer.results {
            let id = PlaceCompletion.derivedId(title: result.title, subtitle: result.subtitle)
            // MapKit can repeat a title/subtitle pair; a duplicate id would break
            // ForEach identity in any list built from these.
            guard mapped[id] == nil else { continue }
            mapped[id] = result
            published.append(PlaceCompletion(id: id, title: result.title, subtitle: result.subtitle))
        }

        index = mapped

        let fragment = completer.queryFragment
        let owner = owner
        MainActor.assumeIsolated {
            owner?.completerDidUpdateResults(published, fragment: fragment)
        }
    }

    func completer(_: MKLocalSearchCompleter, didFailWithError error: any Error) {
        let description = error.localizedDescription
        let owner = owner
        MainActor.assumeIsolated {
            owner?.completerDidFail(description)
        }
    }
}
