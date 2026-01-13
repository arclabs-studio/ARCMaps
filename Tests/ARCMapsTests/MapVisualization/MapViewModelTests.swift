import XCTest
@testable import ARCMaps
@testable import ARCMapsTestHelpers

@MainActor
final class MapViewModelTests: XCTestCase {

    var sut: MapViewModel!
    var mockLocationService: MockLocationService!
    var mockLogger: MockLogger!

    override func setUp() async throws {
        mockLocationService = MockLocationService()
        mockLogger = MockLogger()

        sut = MapViewModel(
            locationService: mockLocationService,
            logger: mockLogger
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockLocationService = nil
        mockLogger = nil
    }

    func testSetPlaces() {
        // Given
        let places = MapPlaceFixtures.allSamples

        // When
        sut.setPlaces(places)

        // Then
        XCTAssertEqual(sut.places.count, places.count)
        XCTAssertEqual(sut.filteredPlaces.count, places.count)
    }

    func testApplyFilter_StatusFilter() {
        // Given
        let places = MapPlaceFixtures.allSamples
        sut.setPlaces(places)

        var filter = MapFilter()
        filter.statuses = [.wishlist]

        // When
        sut.updateFilter(filter)

        // Then
        XCTAssertEqual(sut.filteredPlaces.count, 1)
        XCTAssertTrue(sut.filteredPlaces.allSatisfy { $0.status == .wishlist })
    }

    func testSelectPlace() {
        // Given
        let place = MapPlaceFixtures.wishlistRestaurant

        // When
        sut.selectPlace(place)

        // Then
        XCTAssertEqual(sut.selectedPlace, place)
    }
}
