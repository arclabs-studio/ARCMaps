import SwiftUI

/// Marker for wishlist places
public struct WishlistMarker: View {
    let place: MapPlace

    public init(place: MapPlace) {
        self.place = place
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(.red)
                .frame(width: 36, height: 36)
                .shadow(radius: 3)

            Image(systemName: "heart.fill")
                .foregroundStyle(.white)
                .font(.system(size: 16))
        }
    }
}
