//
//  ContentView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import SwiftUI

/// Main content view with tab navigation.
///
/// Provides navigation between the four demo screens:
/// - Map Demo: Interactive map with sample places (pending, visited, favorite markers)
/// - Filter Demo: Demonstrates filtering including favorites-only filter
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

            FilterDemoView()
                .tabItem {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
                .tag(1)

            PlaceMapperDemoView()
                .tabItem {
                    Label("Mapper", systemImage: "arrow.triangle.2.circlepath.circle")
                }
                .tag(2)

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
