import SwiftUI
import CoreLocation

/// Callout view shown when tapping a place marker
public struct PlaceCalloutView: View {
    let place: MapPlace
    let userLocation: CLLocationCoordinate2D?
    let onOpenInMaps: (ExternalMapApp) async -> Void

    @Environment(\.dismiss) private var dismiss

    public init(
        place: MapPlace,
        userLocation: CLLocationCoordinate2D?,
        onOpenInMaps: @escaping (ExternalMapApp) async -> Void
    ) {
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
                        HStack {
                            statusBadge
                            Spacer()
                            if let rating = place.rating {
                                ratingView(rating)
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

                    // Visit date
                    if let visitDate = place.visitDate {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .foregroundStyle(.purple)

                            Text("Visited \(visitDate.formatted(date: .abbreviated, time: .omitted))")
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: place.status.iconName)
            Text(place.status.rawValue)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(place.status == .wishlist ? Color.red : Color.green)
        .cornerRadius(12)
    }

    private func ratingView(_ rating: Double) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text(String(format: "%.1f", rating))
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }

    private var distanceText: String? {
        guard let userLocation = userLocation else { return nil }

        let distance = place.distance(from: userLocation)
        return DistanceCalculator.formatDistance(distance) + " away"
    }

    private func mapIcon(for app: ExternalMapApp) -> String {
        switch app {
        case .appleMaps: return "map"
        case .googleMaps: return "globe"
        case .waze: return "car.fill"
        }
    }
}
