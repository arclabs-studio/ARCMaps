import SwiftUI
import MapKit

/// Main map view component
public struct ARCMapView: View {
    @StateObject private var viewModel: MapViewModel

    public init(viewModel: MapViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                    .cornerRadius(12)
            }
        }
        .task {
            await viewModel.requestLocationPermission()
        }
        .alert("Map Error", isPresented: .constant(viewModel.error != nil)) {
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
            .presentationDetents([.height(300), .medium])
        }
    }
}
