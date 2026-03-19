//
//  PlaceMapperDemoView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 18/03/2026.
//

import ARCMaps
import CoreLocation
import SwiftUI

/// Demonstrates PlaceMapper — bridging PlaceSearchResult to MapPlace.
///
/// Shows how to:
/// - Simulate search results (as would come from PlaceEnrichmentViewModel)
/// - Convert them to MapPlace using PlaceMapper.toMapPlace(_:status:)
/// - Add the converted place to the map with .pending status
/// - Mark a place as visited + favorite directly on the map
struct PlaceMapperDemoView: View {
    @State private var mapViewModel: MapViewModel
    @State private var addedPlaceIDs: Set<String> = []
    @State private var showInfo = false

    init() {
        _mapViewModel = State(initialValue: MapViewModel(locationService: CoreLocationService()))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                infoBar

                ARCMapView(viewModel: mapViewModel)
            }
            .navigationTitle("PlaceMapper Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .sheet(isPresented: $showInfo) {
                infoSheet
            }
        }
    }

    // MARK: - Info Bar

    private var infoBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(simulatedSearchResults) { result in
                    addButton(for: result)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(.regularMaterial)
    }

    @ViewBuilder private func addButton(for result: PlaceSearchResult) -> some View {
        let alreadyAdded = addedPlaceIDs.contains(result.id)

        Button {
            guard !alreadyAdded else { return }
            // PlaceMapper bridges PlaceSearchResult → MapPlace
            let mapPlace = PlaceMapper.toMapPlace(result, status: .pending)
            mapViewModel.setPlaces(mapViewModel.places + [mapPlace])
            addedPlaceIDs.insert(result.id)
            mapViewModel.centerOnPlace(mapPlace, animated: true)
        } label: {
            Label(result.name, systemImage: alreadyAdded ? "checkmark" : "plus")
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(alreadyAdded ? Color.green.opacity(0.15) : Color.accentColor.opacity(0.1))
                .foregroundStyle(alreadyAdded ? .green : .accentColor)
                .clipShape(Capsule())
        }
        .disabled(alreadyAdded)
    }

    // MARK: - Info Sheet

    private var infoSheet: some View {
        NavigationStack {
            List {
                Section("What this demo shows") {
                    Label("Simulated search results appear as pills above the map", systemImage: "1.circle")
                    Label("Tap a pill to convert it via PlaceMapper and pin it on the map", systemImage: "2.circle")
                    Label("Each pinned place starts with .pending status (red clock marker)", systemImage: "3.circle")
                    Label("PlaceMapper copies id, name, coordinate, address, category, and rating",
                          systemImage: "4.circle")
                }

                Section("Code") {
                    Text("""
                    let mapPlace = PlaceMapper.toMapPlace(
                        searchResult,
                        status: .pending
                    )
                    mapViewModel.setPlaces(mapViewModel.places + [mapPlace])
                    """)
                    .font(.system(.caption, design: .monospaced))
                }
            }
            .navigationTitle("PlaceMapper")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showInfo = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Simulated Search Results

    /// Simulates the PlaceSearchResult values that PlaceEnrichmentViewModel would return.
    /// In a real app these come from GooglePlacesService or AppleMapsServerService.
    private var simulatedSearchResults: [PlaceSearchResult] {
        [PlaceSearchResult(id: "sim-1",
                           provider: .google,
                           name: "DiverXO",
                           address: "Calle Padre Damián 23, Madrid",
                           coordinate: CLLocationCoordinate2D(latitude: 40.4610, longitude: -3.6884),
                           types: ["restaurant"],
                           rating: 4.9,
                           userRatingsTotal: 4200),
         PlaceSearchResult(id: "sim-2",
                           provider: .google,
                           name: "Lateral Gran Vía",
                           address: "Gran Vía 5, Madrid",
                           coordinate: CLLocationCoordinate2D(latitude: 40.4199, longitude: -3.7049),
                           types: ["restaurant"],
                           rating: 4.3,
                           userRatingsTotal: 1800),
         PlaceSearchResult(id: "sim-3",
                           provider: .google,
                           name: "Café Comercial",
                           address: "Glorieta de Bilbao 7, Madrid",
                           coordinate: CLLocationCoordinate2D(latitude: 40.4265, longitude: -3.7069),
                           types: ["cafe"],
                           rating: 4.5,
                           userRatingsTotal: 950),
         PlaceSearchResult(id: "sim-4",
                           provider: .google,
                           name: "La Pepita",
                           address: "Calle de la Ballesta 18, Madrid",
                           coordinate: CLLocationCoordinate2D(latitude: 40.4231, longitude: -3.7038),
                           types: ["cafe"],
                           rating: 4.4,
                           userRatingsTotal: 620)]
    }
}

#Preview {
    PlaceMapperDemoView()
}
