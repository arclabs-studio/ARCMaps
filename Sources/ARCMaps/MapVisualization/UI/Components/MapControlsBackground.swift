//
//  MapControlsBackground.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 19/10/2026.
//

import SwiftUI

/// The shared capsule behind the map's control column.
///
/// Standalone MapKit controls draw no background of their own, so the column
/// supplies one for native and custom buttons alike: Liquid Glass where the
/// system has it, a material capsule before that.
struct MapControlsBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, *) {
            content.glassEffect(.regular, in: .capsule)
        } else {
            content.background(.regularMaterial, in: .capsule)
        }
    }
}
