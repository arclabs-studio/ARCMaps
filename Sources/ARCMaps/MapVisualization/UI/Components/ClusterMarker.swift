//
//  ClusterMarker.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 07/08/2026.
//

import SwiftUI

// MARK: - Constants

private enum ClusterMarkerDefaults {
    /// Diameter of the smallest cluster bubble.
    static let baseDiameter: CGFloat = 38
    /// Additional diameter applied at the largest cluster size.
    static let maximumGrowth: CGFloat = 16
    /// Member count at which the bubble stops growing.
    static let saturationCount: Double = 50
    /// Minimum hit target, per Apple's Human Interface Guidelines.
    static let minimumTapTarget: CGFloat = 44
    /// Width of the ring separating the bubble from the map beneath it.
    static let ringWidth: CGFloat = 2
    static let shadowRadius: CGFloat = 3
}

// MARK: - ClusterMarker

/// The default bubble drawn in place of a group of nearby places.
///
/// `ClusterMarker` is used by ``ARCMapView`` whenever no custom cluster builder is
/// supplied. It renders the member count in a circle that grows with cluster size,
/// so denser areas read as heavier at a glance.
///
/// The bubble carries a 44pt minimum tap target regardless of its drawn size, per
/// Apple's Human Interface Guidelines.
///
/// For custom cluster bubbles, inject a `@ViewBuilder` into ``ARCMapView``:
/// ```swift
/// ARCMapView(viewModel: vm) { place in
///     MyMarker(place: place)
/// } cluster: { cluster in
///     MyClusterBubble(count: cluster.count)
/// }
/// ```
public struct ClusterMarker: View {
    /// The number of places represented by the bubble.
    let count: Int

    /// Creates a cluster bubble showing a member count.
    ///
    /// - Parameter count: The number of places in the cluster.
    public init(count: Int) {
        self.count = count
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(.red)
                .overlay {
                    Circle()
                        .strokeBorder(.white, lineWidth: ClusterMarkerDefaults.ringWidth)
                }
                .frame(width: diameter, height: diameter)
                .shadow(radius: ClusterMarkerDefaults.shadowRadius)

            Text(count, format: .number)
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .frame(minWidth: ClusterMarkerDefaults.minimumTapTarget,
               minHeight: ClusterMarkerDefaults.minimumTapTarget)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Cluster of \(count) places")
        .accessibilityHint("Double tap to zoom in")
    }

    // MARK: - Private

    /// Bubble diameter, scaled by member count and capped at the saturation point.
    private var diameter: CGFloat {
        let progress = min(Double(count) / ClusterMarkerDefaults.saturationCount, 1)
        return ClusterMarkerDefaults.baseDiameter + ClusterMarkerDefaults.maximumGrowth * progress
    }

    /// Count label size, kept proportional to the bubble.
    private var fontSize: CGFloat {
        diameter * 0.4
    }
}

// MARK: - Previews

#Preview("Cluster sizes") {
    HStack(spacing: 12) {
        ClusterMarker(count: 3)
        ClusterMarker(count: 12)
        ClusterMarker(count: 250)
    }
    .padding()
}
