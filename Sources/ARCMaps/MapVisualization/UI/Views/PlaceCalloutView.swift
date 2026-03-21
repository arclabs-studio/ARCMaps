//
//  PlaceCalloutView.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import ARCUIComponents
import CoreLocation
import SwiftUI

/// Default callout view shown when tapping a place marker.
///
/// `PlaceCalloutView` is the default sheet content used by ``ARCMapView``. It displays
/// basic place information (name, category, rating, address, distance) and options to
/// open the place in external map apps.
///
/// For a fully customized sheet, inject your own view via the ``ARCMapView`` initializer:
/// ```swift
/// ARCMapView(viewModel: vm) { place in
///     MyMarker(place: place)
/// } sheet: { place, userLocation in
///     MyPlaceDetailView(place: place)
/// }
/// ```
public struct PlaceCalloutView: View {
    let place: MapPlace
    let userLocation: CLLocationCoordinate2D?
    let onOpenInMaps: (ExternalMapApp) async -> Void

    @Environment(\.dismiss) private var dismiss

    public init(place: MapPlace,
                userLocation: CLLocationCoordinate2D?,
                onOpenInMaps: @escaping (ExternalMapApp) async -> Void) {
        self.place = place
        self.userLocation = userLocation
        self.onOpenInMaps = onOpenInMaps
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        if let rating = place.rating {
                            HStack {
                                ARCRatingView(rating: rating, style: .circularGauge)
                                Spacer()
                            }
                        }

                        Text(place.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        if let category = place.category {
                            Text(category)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    // Address
                    if let address = place.address {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.red)

                            Text(address)
                                .font(.body)
                        }
                    }

                    // Distance
                    if let distance = distanceText {
                        HStack(spacing: 12) {
                            Image(systemName: "figure.walk")
                                .foregroundStyle(.blue)

                            Text(distance)
                                .font(.body)
                        }
                    }

                    Divider()

                    // Open in maps
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Open in")
                            .font(.headline)

                        ForEach(ExternalMapApp.allCases, id: \.self) { app in
                            Button {
                                Task {
                                    await onOpenInMaps(app)
                                    dismiss()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: mapIcon(for: app))
                                    Text(app.rawValue)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(.regularMaterial)
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var distanceText: String? {
        guard let userLocation else { return nil }

        let distance = place.distance(from: userLocation)
        return DistanceCalculator.formatDistance(distance) + " away"
    }

    private func mapIcon(for app: ExternalMapApp) -> String {
        switch app {
        case .appleMaps: "map"
        case .googleMaps: "globe"
        case .waze: "car.fill"
        }
    }
}
