//
//  ClusteringDemoView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 07/08/2026.
//

import ARCMaps
import CoreLocation
import SwiftUI

/// Demonstrates annotation clustering across a country-wide dataset.
///
/// Zoom out and nearby places collapse into cluster bubbles; zoom in and they
/// dissolve back into individual pins. Tapping a bubble zooms to fit its members.
///
/// Shows three things the package exposes:
/// - `cluster:` — a custom cluster bubble via ViewBuilder injection
/// - `clusteringEnabled` — the opt-out for collections that stay legible unclustered
/// - `showsAnnotationTitles` — name labels, hidden by default because they are a
///   large part of what makes dense areas unreadable
struct ClusteringDemoView: View {
    @State private var viewModel: MapViewModel

    init() {
        let locationService = CoreLocationService()
        _viewModel = State(initialValue: MapViewModel(locationService: locationService))
    }

    var body: some View {
        NavigationStack {
            ARCMapView(viewModel: viewModel) { place in
                CategoryPin(category: place.category)
            } cluster: { cluster in
                CityClusterBubble(count: cluster.count,
                                  topRating: cluster.places.compactMap(\.rating).max())
            }
            .navigationTitle("Clustering")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                controls
            }
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
                viewModel.setPlaces(SampleData.clusteredPlaces)
                viewModel.fitAllPlaces()
            }
        }
    }

    // MARK: - Controls

    private var controls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Cluster nearby places", isOn: $viewModel.clusteringEnabled)
            Toggle("Show place names", isOn: $viewModel.showsAnnotationTitles)

            Text("\(viewModel.annotationItems.count) annotations for \(viewModel.filteredPlaces.count) places")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
    }
}

// MARK: - CityClusterBubble

/// A custom cluster bubble tinted by the best rating among its members.
///
/// Demonstrates that the consuming app decides how a cluster reads — the package
/// only supplies the grouping and a neutral default bubble.
private struct CityClusterBubble: View {
    let count: Int
    let topRating: Double?

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.gradient)
                .overlay {
                    Circle().strokeBorder(.white, lineWidth: 2)
                }
                .frame(width: diameter, height: diameter)
                .shadow(radius: 4)

            Text(count, format: .number)
                .font(.system(size: diameter * 0.38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(.rect)
    }

    private var diameter: CGFloat {
        min(38 + CGFloat(count), 62)
    }

    private var tint: Color {
        guard let topRating else { return .gray }
        return topRating >= 4.5 ? .green : topRating >= 4 ? .orange : .blue
    }
}

// MARK: - CategoryPin

/// A compact per-place pin, sized so overlapping pins stay distinguishable.
private struct CategoryPin: View {
    let category: String?

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .padding(8)
            .background(Circle().fill(.red))
            .shadow(radius: 2)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(.rect)
    }

    private var icon: String {
        switch category?.lowercased() {
        case "restaurant": "fork.knife"
        case "cafe": "cup.and.saucer.fill"
        case "market": "cart.fill"
        default: "mappin"
        }
    }
}

#Preview {
    ClusteringDemoView()
}
