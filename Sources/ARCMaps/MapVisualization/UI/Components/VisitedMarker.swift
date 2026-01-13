import SwiftUI

/// Marker for visited places
public struct VisitedMarker: View {
    let place: MapPlace

    public init(place: MapPlace) {
        self.place = place
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(.green)
                .frame(width: 36, height: 36)
                .shadow(radius: 3)

            Image(systemName: "checkmark")
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .bold))
        }
    }
}
