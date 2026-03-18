//
//  FilterDemoView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import ARCMaps
import SwiftUI

/// Demonstrates the MapFilter functionality.
///
/// Shows how to:
/// - Filter places by status (pending/visited)
/// - Filter to favorites only (visited + isFavorite)
/// - Filter by category
/// - Set minimum rating threshold
/// - Apply filters to the map view
struct FilterDemoView: View {
    @State private var viewModel: MapViewModel
    @State private var selectedStatuses: Set<PlaceStatus> = Set(PlaceStatus.allCases)
    @State private var selectedCategories: Set<String> = []
    @State private var minRating: Double = 0
    @State private var favoritesOnly = false
    @State private var showFilterSheet = false

    init() {
        let locationService = CoreLocationService()
        _viewModel = State(initialValue: MapViewModel(locationService: locationService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter summary bar
                filterSummaryBar

                // Map view
                ARCMapView(viewModel: viewModel)
            }
            .navigationTitle("Filter Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                filterSheet
            }
            .onAppear {
                viewModel.setPlaces(SampleData.places)
                viewModel.fitAllPlaces()
            }
        }
    }

    // MARK: - Filter Summary Bar

    private var filterSummaryBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Showing \(viewModel.filteredPlaces.count) of \(viewModel.places.count) places")
                    .font(.subheadline.weight(.medium))

                Text(filterDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if hasActiveFilters {
                Button("Reset") {
                    resetFilters()
                }
                .font(.caption)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.regularMaterial)
    }

    private var filterDescription: String {
        var parts: [String] = []

        if favoritesOnly {
            parts.append("Favorites only")
        } else if selectedStatuses.count == 1 {
            parts.append(selectedStatuses.first?.rawValue ?? "")
        }

        if !selectedCategories.isEmpty {
            let categoryList = selectedCategories.sorted().joined(separator: ", ")
            parts.append(categoryList)
        }

        if minRating > 0 {
            parts.append("Rating \(String(format: "%.1f", minRating))+")
        }

        return parts.isEmpty ? "No filters applied" : parts.joined(separator: " | ")
    }

    private var hasActiveFilters: Bool {
        favoritesOnly ||
            selectedStatuses.count < PlaceStatus.allCases.count ||
            !selectedCategories.isEmpty ||
            minRating > 0
    }

    // MARK: - Filter Sheet

    private var filterSheet: some View {
        NavigationStack {
            Form {
                // Favorites shortcut
                Section("Favorites") {
                    Toggle(isOn: Binding(
                        get: { favoritesOnly },
                        set: { newValue in
                            favoritesOnly = newValue
                            // Favorites are always a subset of visited places
                            if newValue {
                                selectedStatuses = [.visited]
                            }
                            applyFilters()
                        }
                    )) {
                        Label("Favorites only", systemImage: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                }

                // Status filter
                Section("Status") {
                    ForEach(PlaceStatus.allCases, id: \.self) { status in
                        Toggle(isOn: Binding(
                            get: { selectedStatuses.contains(status) },
                            set: { isSelected in
                                if isSelected {
                                    selectedStatuses.insert(status)
                                } else {
                                    selectedStatuses.remove(status)
                                    // Favorites require .visited — clear if deselected
                                    if status == .visited { favoritesOnly = false }
                                }
                                applyFilters()
                            }
                        )) {
                            Label(status.rawValue, systemImage: status.iconName)
                                .foregroundStyle(status == .pending ? .red : .green)
                        }
                    }
                }

                // Category filter
                Section("Category") {
                    ForEach(SampleData.categories, id: \.self) { category in
                        Toggle(isOn: Binding(
                            get: { selectedCategories.contains(category) },
                            set: { isSelected in
                                if isSelected {
                                    selectedCategories.insert(category)
                                } else {
                                    selectedCategories.remove(category)
                                }
                                applyFilters()
                            }
                        )) {
                            Text(category.capitalized)
                        }
                    }
                }

                // Rating filter
                Section("Minimum Rating") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(minRating > 0 ? String(format: "%.1f", minRating) : "Any")
                                .font(.headline)

                            Spacer()

                            ForEach(0 ..< 5) { index in
                                Image(systemName: Double(index) < minRating ? "star.fill" : "star")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                            }
                        }

                        Slider(value: $minRating, in: 0 ... 5, step: 0.5) { _ in
                            applyFilters()
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        resetFilters()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showFilterSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Filter Logic

    private func applyFilters() {
        let filter = MapFilter(
            statuses: selectedStatuses.isEmpty ? Set(PlaceStatus.allCases) : selectedStatuses,
            categories: selectedCategories,
            minRating: minRating > 0 ? minRating : nil,
            filterByFavorites: favoritesOnly
        )
        viewModel.updateFilter(filter)
    }

    private func resetFilters() {
        selectedStatuses = Set(PlaceStatus.allCases)
        selectedCategories = []
        minRating = 0
        favoritesOnly = false
        viewModel.updateFilter(.all)
    }
}

#Preview {
    FilterDemoView()
}
