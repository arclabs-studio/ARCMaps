# ARCMaps — annotation clustering

**Created:** 2026-08-07
**Branch:** `feature/annotation-clustering`
**Origin:** FVRS-33 map pin types (FavRes-iOS PR #221). Clustering was identified
as the next pain point but is a package change, so it was kept out of that PR.

> Revised from the original vault plan after verifying every claim against the
> ARCMaps source at `b021288`. Changes from the original are marked **[rev]**.

---

## Problem

`ARCMapView` renders one `Annotation` per place with no clustering
(`Sources/ARCMaps/MapVisualization/UI/Views/ARCMapView.swift:280`):

```swift
ForEach(viewModel.filteredPlaces) { place in
    Annotation(place.name, coordinate: place.coordinate) {
        markerContent(place)
            .onTapGesture { viewModel.selectPlace(place) }
    }
}
```

At city zoom this is fine. At country/world zoom, FavRes pins pile into an
unreadable stack — observed with ~10 restaurants around Madrid, degrading
linearly with collection size. Two aggravating factors:

- **Title labels are unavoidable.** `Annotation(place.name, …)` always renders a
  name label. `.annotationTitles(.hidden)` is a `MapContent` modifier applicable
  only inside the package, so consumers cannot suppress it.
- **Marker bounds vary.** Since FVRS-33 the FavRes marker is a bare glyph with a
  44pt minimum tap frame, so overlapping pins interleave rather than stack cleanly.

## Constraint that shapes the design

SwiftUI's `Map` has **no built-in clustering**. `MKMarkerAnnotationView`'s
`clusteringIdentifier` belongs to MapKit-UIKit (`MKMapView`); there is no SwiftUI
equivalent as of iOS 26. Clustering must be hand-rolled over `MapCameraPosition`
or obtained by dropping to `MKMapView` via `UIViewRepresentable`.

**Decision: hand-rolled grid clustering (option A).** Option B buys real MapKit
clustering but costs the `markerContent` SwiftUI builder (requires
`UIHostingConfiguration` over `MKAnnotationView`) and discards the iOS 18
`FeatureSelectionMapView` path already built at `ARCMapView.swift:301-344`. That
is a view-layer rewrite to solve a density problem A solves adequately. Revisit
only if clustering fidelity becomes a product requirement.

---

## Locked decisions

| Question | Decision |
|---|---|
| Cluster marker customization | **Third generic param** `ClusterContent` on `ARCMapView` |
| Minimum cluster size | **3** — cells with 1–2 places emit individual pins |
| Clustering default | **On** (`clusteringEnabled = true`) |
| Annotation titles | **Hidden by default**, opt back in via `showsAnnotationTitles` |

Both defaults are visible behavior changes for existing consumers on upgrade.
Call them out in CHANGELOG under a `### Changed` heading, not `### Added`.

---

## Design

### Domain — `MapVisualization/Domain/Models/MapCluster.swift`

```swift
public struct MapCluster: Identifiable, Sendable, Equatable {
    public let id: String                            // derived from zoom bucket + cell index
    public let coordinate: CLLocationCoordinate2D    // centroid of members
    public let places: [MapPlace]
    public var count: Int { places.count }
}

public enum MapAnnotationItem: Identifiable, Sendable, Equatable {
    case place(MapPlace)
    case cluster(MapCluster)
}
```

`id` **must** derive from the cell index, never a fresh UUID — otherwise every
camera change hands SwiftUI new identities and re-animates all annotations.
Format: `"\(bucket.rawValue):\(cellX):\(cellY)"`.

`CLLocationCoordinate2D` is already `@retroactive Equatable`/`Hashable`
(`Shared/Extensions/CLLocationCoordinate2D+Extensions.swift:10`), so `Equatable`
synthesis works on both types.

**[rev] Naming note.** A public `MapAnnotation` type already exists
(`Domain/Models/MapAnnotation.swift`) and is unused by `ARCMapView`. DocC on
`MapAnnotationItem` must state the distinction explicitly.

### Domain — `MapVisualization/Domain/Services/PlaceClusterer.swift` **[rev]**

The original plan put the math in `MapViewModel`. It goes in a pure `Sendable`
struct instead: the view model is `@MainActor`, and 100% package coverage on
grid math is far cheaper without MainActor hops. SRP too.

```swift
public struct ZoomBucket: Sendable, Equatable, Hashable {
    init(latitudeDelta: Double)     // snaps to a discrete rung
    var cellSizeDegrees: Double
}

public struct PlaceClusterer: Sendable {
    public let minimumClusterSize: Int   // 3

    public func cluster(_ places: [MapPlace], bucket: ZoomBucket) -> [MapAnnotationItem]
}
```

Takes a plain `Double` latitude delta rather than `MKCoordinateSpan` so the
clusterer stays MapKit-free; `MapViewModel` does the conversion.

**Grid caveats to encode:**

- **Longitude scaling.** Fixed degree-width cells stretch in meters toward the
  equator and pinch toward the poles. Scale the longitude cell width by
  `cos(latitude)` at the cell's own latitude.
- **Antimeridian and poles.** Mean-of-coordinates centroid is wrong across ±180°.
  Document as unsupported; do not attempt to handle. No test asserts it.
- **Zoom buckets, not continuous cells.** Discrete rungs are what stop clusters
  popping on every pan and what makes the camera guard below possible.

### ViewModel — `MapViewModel`

```swift
public private(set) var annotationItems: [MapAnnotationItem] = []
public var clusteringEnabled: Bool = true
public var showsAnnotationTitles: Bool = false
public func updateCameraSpan(_ span: MKCoordinateSpan)
public func selectCluster(_ cluster: MapCluster)
```

- `applyFilter()` must rebuild `annotationItems` too.
- **[rev] Guard the recompute.** `updateCameraSpan` computes the bucket and
  returns early unless it differs from the stored one. Without this,
  `selectPlace` → `centerOnPlace` (`MapViewModel.swift:108`) → camera change →
  recluster churns annotations *during selection*.
- `selectCluster` fits member coordinates via the existing
  `MKCoordinateRegion.fitting(_:)` (`Shared/Extensions/MKCoordinateRegion+Extensions.swift:13`).
- Keep `filteredPlaces` public and populated — it is API FavRes reads
  (`RestaurantMapViewModel.applyCurrentFilter` clears a stale `selectedPlace` with it).

### View — `ARCMapView`

```swift
public struct ARCMapView<MarkerContent: View,
                        SheetContent: View,
                        ClusterContent: View>: View
```

**[rev] Swift has no default generic parameters.** Source compatibility comes
from pinning the new parameter in the three existing initialisers, exactly as
`SheetContent` is pinned today:

```swift
public init(viewModel: MapViewModel,
            featureSelectionMode: MapFeatureSelectionMode = .disabled,
            @ViewBuilder marker: @escaping (MapPlace) -> MarkerContent)
    where SheetContent == PlaceCalloutView,
          ClusterContent == ClusterMarker
```

Plus one new overload taking `cluster:`. Note the third parameter **is**
source-breaking for any consumer spelling `ARCMapView<A, B>` explicitly — nothing
in FavRes or `Examples/` does, but external consumers would break.

Other view changes:

- `mapContent` switches over `viewModel.annotationItems`; cluster case taps to
  `viewModel.selectCluster`.
- **[rev]** Use the value form `.annotationTitles(viewModel.showsAnnotationTitles ? .automatic : .hidden)`.
  An `if/else` inside `@MapContentBuilder` would make `mapContent` a
  `_ConditionalContent`, which then has to flow through
  `FeatureSelectionMapView<Content: MapContent>`. It compiles, but there is no
  reason to branch the type.
- **[rev]** Apply `.onMapCameraChange(frequency: .onEnd)` **once** on `coreMap`
  inside `mapView` (`ARCMapView.swift:238`), not at each of the four `Map` sites
  (`legacyMap` + three in `FeatureSelectionMapView`). Verify at runtime that it
  propagates from an ancestor of `Map`; if it does not, fall back to the four
  sites. Only move to `.continuous` after profiling shows `.onEnd` feels
  unresponsive.

### Default cluster bubble — `UI/Components/ClusterMarker.swift`

Neutral circle with a count badge, sized for a 44pt tap target, consistent with
`PlaceMarker`.

---

## Compatibility

**[rev] The original plan's FavRes call-site claim was wrong for the current
checkout.** Two distinct call sites must both build:

| Target | Call | Resolves to |
|---|---|---|
| `FavRes-iOS` @ `bugfix/location-precision-and-photo-sync` — `Presentation/Features/Map/MapView.swift:34` | `ARCMapView(viewModel:)` | all three generics pinned |
| `FavRes-iOS-worktrees/FVRS-33` — same file | `ARCMapView(viewModel:) { place in RestaurantMapMarker(…) }` | `MarkerContent` free, other two pinned |

`RestaurantMapMarker` exists only in the FVRS-33 worktree. Verify both before
tagging — this is exactly where type inference quietly breaks at the call site.

Also build `Examples/ARCMapsDemoApp` (5 call sites across `MapDemoView`,
`CustomMarkerDemoView`, `FilterDemoView`, `PlaceMapperDemoView`).

## Testing

Package target requires 100% coverage per ARC standards.

- **Cluster math** (`PlaceClustererTests`): N places in one cell → one cluster;
  places spread across cells → N items; zoom-in past threshold → clusters
  dissolve; centroid is the mean of member coordinates; 2 places in a cell →
  two `.place` items, not a cluster (minimum size 3).
- **Stable-ID regression**: same places + same bucket → identical `id` across two
  computations. This is the test that guards annotation flicker.
- **Longitude scaling**: same metric spacing at 0° and 60° latitude lands in a
  comparable number of cells.
- **ViewModel**: `updateCameraSpan` with a span inside the current bucket does
  **not** recompute; crossing a bucket boundary does. `clusteringEnabled = false`
  yields one `.place` per filtered place. `applyFilter` refreshes
  `annotationItems`. `selectCluster` sets a region fitting all members.
- Extend `MapPlaceFixtures` with a dense same-cell set and a spread set.

## Execution order

1. `MapCluster` + `MapAnnotationItem` (domain, no dependents)
2. `ZoomBucket` + `PlaceClusterer` + `PlaceClustererTests` — TDD, pure, fast
3. `MapViewModel` wiring + tests
4. `ClusterMarker` default component
5. `ARCMapView` generic + camera hook + title control
6. `Examples/ARCMapsDemoApp/ClusteringDemoView.swift`
7. DocC on all new public types, README, CHANGELOG
8. `make lint format test`
9. Build FavRes `develop` **and** the FVRS-33 worktree against the branch
10. Land, release ARCMaps, bump the FavRes pin

Watch for the worktree stale-`Package.resolved` trap noted in FavRes memory at
step 9.

## Deferred to FavRes

- Cluster colour when members are mixed status — dominant status, or neutral with
  a count. Consumer-side; ARCMaps only ships the neutral default.
- Whether the Favorites filter should cluster at all, given it yields far fewer
  pins. Consumer-side via `clusteringEnabled`.
