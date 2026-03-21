//
//  CustomMarkerDemoView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 21/03/2026.
//

import ARCMaps
import CoreLocation
import SwiftUI

/// Demonstrates how to inject custom marker and sheet views into ARCMapView.
///
/// Shows two key ViewBuilder injection patterns:
/// - `marker:` — a custom marker view per place (color-coded by category)
/// - `sheet:` — a fully custom detail sheet replacing PlaceCalloutView
struct CustomMarkerDemoView: View {
    @State private var viewModel: MapViewModel

    init() {
        let locationService = CoreLocationService()
        _viewModel = State(initialValue: MapViewModel(locationService: locationService))
    }

    var body: some View {
        NavigationStack {
            ARCMapView(viewModel: viewModel) { place in
                CategoryMarker(place: place)
            } sheet: { place, _ in
                MinimalPlaceSheet(place: place)
            }
            .navigationTitle("Custom Markers")
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
}

// MARK: - CategoryMarker

/// A marker whose color depends on the place category.
///
/// Demonstrates how the consuming app can drive marker appearance
/// using its own logic — the ARCMaps package stays generic.
private struct CategoryMarker: View {
    let place: MapPlace

    var body: some View {
        ZStack {
            Circle()
                .fill(color(for: place.category))
                .frame(width: 36, height: 36)
                .shadow(radius: 3)

            Image(systemName: icon(for: place.category))
                .foregroundStyle(.white)
                .font(.system(size: 14, weight: .semibold))
        }
    }

    private func color(for category: String?) -> Color {
        switch category?.lowercased() {
        case "restaurant": .orange
        case "cafe": .brown
        case "market": .green
        default: .blue
        }
    }

    private func icon(for category: String?) -> String {
        switch category?.lowercased() {
        case "restaurant": "fork.knife"
        case "cafe": "cup.and.saucer.fill"
        case "market": "cart.fill"
        default: "mappin"
        }
    }
}

// MARK: - MinimalPlaceSheet

/// A minimal custom detail sheet shown when a place is selected.
///
/// Demonstrates full control over the sheet layout — the consuming
/// app is not constrained to PlaceCalloutView's structure.
private struct MinimalPlaceSheet: View {
    let place: MapPlace

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.title3.weight(.semibold))

                    if let category = place.category {
                        Text(category.capitalized)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if let rating = place.rating {
                    Label(String(format: "%.1f", rating), systemImage: "star.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.orange)
                }
            }

            if let address = place.address {
                Label(address, systemImage: "mappin")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CustomMarkerDemoView()
}
