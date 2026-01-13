//
//  ARCMapView.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import MapKit
import SwiftUI

// MARK: - Constants

private enum ViewDefaults {
    /// Initial height for the place detail sheet.
    static let sheetInitialHeight: CGFloat = 300
    /// Corner radius for the loading indicator background.
    static let loadingIndicatorCornerRadius: CGFloat = 12
}

/// Main map view component
public struct ARCMapView: View {
    @Bindable var viewModel: MapViewModel

    public init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            mapView

            VStack {
                HStack {
                    Spacer()
                    MapControlsView(
                        onFitAll: {
                            viewModel.fitAllPlaces()
                        },
                        onChangeStyle: { style in
                            viewModel.changeMapStyle(style)
                        },
                        currentStyle: viewModel.mapStyle
                    )
                }
                .padding()

                Spacer()
            }

            if viewModel.isLoadingLocation {
                ProgressView("Getting location...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(ViewDefaults.loadingIndicatorCornerRadius)
            }
        }
        .task {
            await viewModel.requestLocationPermission()
        }
        .alert(
            "Map Error",
            isPresented: .constant(viewModel.error != nil)
        ) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }

    private var mapView: some View {
        Map(position: $viewModel.cameraPosition) {
            // User location
            if viewModel.userLocation != nil {
                UserAnnotation()
            }

            // Wishlist places
            ForEach(viewModel.filteredPlaces.filter { $0.status == .wishlist }) { place in
                Annotation(place.name, coordinate: place.coordinate) {
                    WishlistMarker(place: place)
                        .onTapGesture {
                            viewModel.selectPlace(place)
                        }
                }
            }

            // Visited places
            ForEach(viewModel.filteredPlaces.filter { $0.status == .visited }) { place in
                Annotation(place.name, coordinate: place.coordinate) {
                    VisitedMarker(place: place)
                        .onTapGesture {
                            viewModel.selectPlace(place)
                        }
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            PlaceCalloutView(
                place: place,
                userLocation: viewModel.userLocation,
                onOpenInMaps: { app in
                    await viewModel.openInExternalMaps(place, app: app)
                }
            )
            .presentationDetents([.height(ViewDefaults.sheetInitialHeight), .medium])
        }
    }
}
