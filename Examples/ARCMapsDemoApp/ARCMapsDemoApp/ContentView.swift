//
//  ContentView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import SwiftUI

/// Main content view with tab navigation.
///
/// Provides navigation between the demo screens:
/// - Map Demo: Interactive map with default markers and sheet
/// - Custom Markers: Custom marker and sheet via ViewBuilder injection
/// - Clustering Demo: Country-wide dataset with custom cluster bubbles
/// - Filter Demo: Category and rating filters
/// - PlaceMapper Demo: Bridges PlaceSearchResult to MapPlace using PlaceMapper
/// - About: Information about the demo app
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MapDemoView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(0)

            CustomMarkerDemoView()
                .tabItem {
                    Label("Custom", systemImage: "mappin.and.ellipse")
                }
                .tag(1)

            ClusteringDemoView()
                .tabItem {
                    Label("Cluster", systemImage: "circle.grid.3x3.fill")
                }
                .tag(2)

            FilterDemoView()
                .tabItem {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
                .tag(3)

            PlaceMapperDemoView()
                .tabItem {
                    Label("Mapper", systemImage: "arrow.triangle.2.circlepath.circle")
                }
                .tag(4)

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(5)
        }
    }
}

#Preview {
    ContentView()
}
