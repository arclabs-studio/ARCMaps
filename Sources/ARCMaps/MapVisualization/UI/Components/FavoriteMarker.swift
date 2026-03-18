//
//  FavoriteMarker.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 18/03/2026.
//

import SwiftUI

/// Marker for visited places that have been marked as favorites.
///
/// Displayed when `place.status == .visited && place.isFavorite == true`.
public struct FavoriteMarker: View {
    let place: MapPlace

    public init(place: MapPlace) {
        self.place = place
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(.yellow)
                .frame(width: 36, height: 36)
                .shadow(radius: 3)

            Image(systemName: "star.fill")
                .foregroundStyle(.white)
                .font(.system(size: 16))
        }
    }
}
