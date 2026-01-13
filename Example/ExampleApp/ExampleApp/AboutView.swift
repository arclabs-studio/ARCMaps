//
//  AboutView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import ARCMaps
import SwiftUI

/// Information about the ARCMaps Example App.
///
/// Displays package version, feature list, and documentation links.
struct AboutView: View {
    var body: some View {
        NavigationStack {
            List {
                // Package info
                Section {
                    LabeledContent("Package", value: ARCMaps.name)
                    LabeledContent("Version", value: ARCMaps.version)
                }

                // Features demonstrated
                Section("Features Demonstrated") {
                    FeatureRow(
                        icon: "map",
                        title: "Map Visualization",
                        description: "Interactive map with custom markers for wishlist and visited places"
                    )

                    FeatureRow(
                        icon: "line.3.horizontal.decrease.circle",
                        title: "Place Filtering",
                        description: "Filter by status, category, and minimum rating"
                    )

                    FeatureRow(
                        icon: "mappin.and.ellipse",
                        title: "Native POI Selection",
                        description: "iOS 18+ feature to tap Apple Maps locations"
                    )

                    FeatureRow(
                        icon: "location",
                        title: "User Location",
                        description: "Display current location and calculate distances"
                    )

                    FeatureRow(
                        icon: "arrow.up.forward.app",
                        title: "External Maps",
                        description: "Open places in Apple Maps or Google Maps"
                    )
                }

                // Sample data info
                Section("Sample Data") {
                    Text(
                        """
                        This demo uses fictional places in Madrid, Spain. \
                        In a real app, you would fetch places from Google Places API or Apple MapKit.
                        """
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                // Links
                Section("Documentation") {
                    if let url = URL(string: "https://github.com/arclabs-studio/ARCMaps") {
                        Link(destination: url) {
                            Label("GitHub Repository", systemImage: "link")
                        }
                    }
                }
            }
            .navigationTitle("About")
        }
    }
}

/// A row displaying a feature with icon and description.
private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.accent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AboutView()
}
