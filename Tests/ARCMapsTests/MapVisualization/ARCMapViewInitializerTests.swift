//
//  ARCMapViewInitializerTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 07/08/2026.
//

import CoreLocation
import SwiftUI
import Testing
@testable import ARCMaps
@testable import ARCMapsTestHelpers

/// Compile-time guards on ``ARCMapView``'s public initialisers.
///
/// Adding the `ClusterContent` generic parameter kept every existing initialiser
/// source-compatible only because each one pins the new parameter in a `where`
/// clause. That is exactly the kind of change where type inference quietly breaks at
/// the call site, so each supported shape is constructed here. These tests assert
/// little at runtime — the value is that they fail to *compile* if an overload
/// becomes ambiguous or loses its default.
@Suite(.serialized)
@MainActor struct ARCMapViewInitializerTests {
    let sut: MapViewModel

    init() async throws {
        sut = MapViewModel(locationService: MockLocationService())
    }

    // MARK: - Existing Call Shapes

    @Test("View model only, all content types defaulted") func viewModelOnlyInitializer() {
        // Given/When: the shape FavRes-iOS uses on develop
        let view = ARCMapView(viewModel: sut)

        // Then
        #expect(view.viewModel === sut)
    }

    @Test("View model with feature selection mode") func featureSelectionInitializer() {
        // Given/When
        let view = ARCMapView(viewModel: sut, featureSelectionMode: .pointsOfInterestOnly)

        // Then
        #expect(view.viewModel === sut)
    }

    @Test("Custom marker, default sheet and cluster") func customMarkerInitializer() {
        // Given/When: the shape FavRes-iOS uses on the FVRS-33 branch
        let view = ARCMapView(viewModel: sut) { place in
            Text(place.name)
        }

        // Then
        #expect(view.viewModel === sut)
    }

    @Test("Custom marker and sheet, default cluster") func customMarkerAndSheetInitializer() {
        // Given/When
        let view = ARCMapView(viewModel: sut) { place in
            Text(place.name)
        } sheet: { place, _ in
            Text(place.name)
        }

        // Then
        #expect(view.viewModel === sut)
    }

    // MARK: - New Call Shapes

    @Test("Custom marker and cluster, default sheet") func customMarkerAndClusterInitializer() {
        // Given/When
        let view = ARCMapView(viewModel: sut) { place in
            Text(place.name)
        } cluster: { cluster in
            Text(cluster.count, format: .number)
        }

        // Then
        #expect(view.viewModel === sut)
    }

    @Test("Custom marker, sheet, and cluster") func fullyCustomInitializer() {
        // Given/When
        let view = ARCMapView(viewModel: sut) { place in
            Text(place.name)
        } sheet: { place, _ in
            Text(place.name)
        } cluster: { cluster in
            Text(cluster.count, format: .number)
        }

        // Then
        #expect(view.viewModel === sut)
    }

    // MARK: - Defaulted Generic Parameters

    @Test("Defaulted initialisers resolve to the package's built-in content types")
    func defaultedInitializersResolveToBuiltIns() {
        // Given/When
        let view = ARCMapView(viewModel: sut)

        // Then: the concrete generic arguments the `where` clauses pin
        #expect(type(of: view) == ARCMapView<PlaceMarker, PlaceCalloutView, ClusterMarker>.self)
    }
}
