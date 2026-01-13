import SwiftUI

/// Map control buttons
struct MapControlsView: View {
    let onFitAll: () -> Void
    let onChangeStyle: (MapStyle) -> Void
    let currentStyle: MapStyle

    var body: some View {
        VStack(spacing: 12) {
            Button {
                onFitAll()
            } label: {
                Image(systemName: "scope")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial)
                    .clipShape(Circle())
            }

            Menu {
                ForEach(MapStyle.allCases, id: \.self) { style in
                    Button {
                        onChangeStyle(style)
                    } label: {
                        Label(style.rawValue, systemImage: mapStyleIcon(style))
                    }
                }
            } label: {
                Image(systemName: "map")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial)
                    .clipShape(Circle())
            }
        }
    }

    private func mapStyleIcon(_ style: MapStyle) -> String {
        switch style {
        case .standard: return "map"
        case .satellite: return "globe.americas"
        case .hybrid: return "map.fill"
        }
    }
}
