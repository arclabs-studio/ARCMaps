import Testing
@testable import ARCMaps

struct ARCMapsTests {
    @Test
    func testPackageVersion() {
        #expect(ARCMaps.version == "1.0.0")
    }

    @Test
    func testPackageName() {
        #expect(ARCMaps.name == "ARCMaps")
    }
}
