//
//  ContentView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import SwiftUI

/// Main content view with tab navigation.
///
/// Provides navigation between the three demo screens:
/// - Map Demo: Interactive map with sample places
/// - Filter Demo: Demonstrates filtering capabilities
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

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
