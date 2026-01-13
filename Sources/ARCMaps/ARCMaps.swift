import Foundation

/// ARCMaps - Comprehensive mapping and place enrichment solution for iOS
///
/// ARCMaps provides two main functionalities:
/// 1. **Place Enrichment**: Search and enrich place data using Google Places API or Apple MapKit
/// 2. **Map Visualization**: Display places on an interactive map with custom markers and filters
///
/// ## Topics
///
/// ### Place Enrichment
/// - ``PlaceEnrichmentService``
/// - ``PlaceSearchQuery``
/// - ``PlaceSearchResult``
/// - ``EnrichedPlaceData``
/// - ``GooglePlacesService``
/// - ``AppleMapsSearchService``
///
/// ### Map Visualization
/// - ``ARCMapView``
/// - ``MapViewModel``
/// - ``MapPlace``
/// - ``MapFilter``
/// - ``LocationService``
///
/// ### Configuration
/// - ``ARCMapsConfiguration``
///
/// ### Error Handling
/// - ``PlaceEnrichmentError``
/// - ``MapError``
public struct ARCMaps {

    /// Package version
    public static let version = "1.0.0"

    /// Package name
    public static let name = "ARCMaps"

    private init() {}
}
