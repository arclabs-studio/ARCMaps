//
//  ARCMapsTests.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Testing
@testable import ARCMaps

struct ARCMapsTests {
    @Test
    func packageVersion() {
        #expect(ARCMaps.version == "1.0.0")
    }

    @Test
    func packageName() {
        #expect(ARCMaps.name == "ARCMaps")
    }
}
