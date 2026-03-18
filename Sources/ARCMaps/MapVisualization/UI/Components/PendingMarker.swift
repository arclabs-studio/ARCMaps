//
//  PendingMarker.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 18/03/2026.
//

import SwiftUI

/// Marker for places the user wants to visit (pending status).
public struct PendingMarker: View {
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

            Image(systemName: "clock.fill")
                .foregroundStyle(.white)
                .font(.system(size: 16))
        }
    }
}
