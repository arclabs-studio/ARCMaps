//
//  PlaceMarker.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import SwiftUI

/// A default map marker for displaying a place on the map.
///
/// `PlaceMarker` is the default marker used by ``ARCMapView`` when no custom
/// marker builder is provided. It renders a simple pin icon.
///
/// For custom markers, inject a `@ViewBuilder` into the ``ARCMapView`` initializer:
/// ```swift
/// ARCMapView(viewModel: vm) { place in
///     MyCustomMarker(place: place)
/// }
/// ```
public struct PlaceMarker: View {
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

            Image(systemName: "mappin")
                .foregroundStyle(.white)
                .font(.system(size: 16))
        }
    }
}
