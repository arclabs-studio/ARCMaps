//
//  MapDemoView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import ARCMaps
import SwiftUI

/// Demonstrates the basic ARCMapView functionality.
///
/// Shows how to:
/// - Initialize MapViewModel with CoreLocationService
/// - Display places on the map
/// - Use the "Fit All" feature
/// - Enable iOS 18+ native POI selection
struct MapDemoView: View {
    @State private var viewModel: MapViewModel
    @State private var featureSelectionEnabled = false

    init() {
        let locationService = CoreLocationService()
        _viewModel = State(initialValue: MapViewModel(locationService: locationService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Feature selection toggle (iOS 18+ only)
                #if os(iOS)
                if #available(iOS 18.0, *) {
                    featureSelectionToggle
                }
                #endif

                // Map view
                mapView
            }
            .navigationTitle("Map Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.fitAllPlaces()
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                    }
                }
            }
            .onAppear {
                viewModel.setPlaces(SampleData.places)
                viewModel.fitAllPlaces()
            }
        }
    }

    @ViewBuilder private var featureSelectionToggle: some View {
        Toggle(isOn: $featureSelectionEnabled) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Native POI Selection")
                    .font(.subheadline)
                Text("Tap Apple Maps locations for details")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.regularMaterial)
    }

    @ViewBuilder private var mapView: some View {
        #if os(iOS)
        if #available(iOS 18.0, *) {
            ARCMapView(
                viewModel: viewModel,
                featureSelectionMode: featureSelectionEnabled ? .pointsOfInterestOnly : .disabled
            )
        } else {
            ARCMapView(viewModel: viewModel)
        }
        #else
        ARCMapView(viewModel: viewModel)
        #endif
    }
}

#Preview {
    MapDemoView()
}
