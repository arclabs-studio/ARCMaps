//
//  MapControlsView.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import MapKit
import SwiftUI

/// The map's control column: one capsule holding MapKit's native location and
/// pitch controls, then the two actions MapKit has no control for (fit all
/// places, map style). The compass sits below the capsule, since MapKit only
/// shows it while the map is rotated.
///
/// The native controls are bound to the map through `scope` instead of living in
/// `.mapControls`. MapKit lays `.mapControls` out top-trailing on its own, and the
/// custom buttons used to sit exactly on top of `MapUserLocationButton`, hiding it.
/// One column owns the order, so nothing overlaps.
struct MapControlsView: View {
    @Bindable var viewModel: MapViewModel
    let scope: Namespace.ID

    @ScaledMetric private var buttonSize: CGFloat = 44

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 0) {
                MapUserLocationButton(scope: scope)
                MapPitchToggle(scope: scope)

                Button {
                    viewModel.fitAllPlaces()
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .frame(width: buttonSize, height: buttonSize)
                }
                .accessibilityLabel(Text("Show all places", comment: "Map control: zooms out to show every place"))

                Menu {
                    Picker(selection: $viewModel.mapStyle) {
                        ForEach(MapStyle.allCases, id: \.self) { style in
                            Label(style.title, systemImage: style.systemImage)
                        }
                    } label: {
                        Text("Map style", comment: "Map control: picker for standard, satellite or hybrid map")
                    }
                } label: {
                    Image(systemName: "map")
                        .frame(width: buttonSize, height: buttonSize)
                }
                .accessibilityLabel(Text("Map style",
                                         comment: "Map control: picker for standard, satellite or hybrid map"))
            }
            .buttonStyle(.borderless)
            .padding(.vertical, 4)
            .modifier(MapControlsBackground())

            MapCompass(scope: scope)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @Namespace var scope
    Map(scope: scope)
        .overlay(alignment: .topTrailing) {
            MapControlsView(viewModel: MapViewModel(locationService: CoreLocationService()), scope: scope)
                .padding()
        }
        .mapScope(scope)
}
