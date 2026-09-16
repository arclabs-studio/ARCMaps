//
//  MockLocationService.swift
//  ARCMaps
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import CoreLocation
import Foundation
@testable import ARCMaps

public actor MockLocationService: LocationService {
    public var mockPermissionGranted = true
    #if os(iOS)
    public var mockAuthorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    #else
    public var mockAuthorizationStatus: CLAuthorizationStatus = .authorized
    #endif
    public var mockCurrentLocation: CLLocationCoordinate2D?
    public var shouldThrowError = false
    public var errorToThrow: MapError = .locationUnavailable

    public private(set) var requestPermissionCalled = false
    public private(set) var authorizationStatusCalled = false
    public private(set) var getCurrentLocationCalled = false
    public private(set) var startMonitoringCalled = false
    public private(set) var stopMonitoringCalled = false

    public init() {}

    // MARK: - Configuration

    /// Sets what the next ``requestPermission()`` returns.
    ///
    /// The stored properties are actor-isolated, so a caller outside the actor
    /// cannot assign to them directly — these setters are the seam.
    public func setMockPermissionGranted(_ granted: Bool) {
        mockPermissionGranted = granted
    }

    /// Sets what ``authorizationStatus()`` reports.
    public func setMockAuthorizationStatus(_ status: CLAuthorizationStatus) {
        mockAuthorizationStatus = status
    }

    /// Sets the coordinate ``getCurrentLocation()`` returns.
    public func setMockCurrentLocation(_ location: CLLocationCoordinate2D?) {
        mockCurrentLocation = location
    }

    // MARK: - LocationService

    public func requestPermission() async -> Bool {
        requestPermissionCalled = true
        return mockPermissionGranted
    }

    public func authorizationStatus() async -> CLAuthorizationStatus {
        authorizationStatusCalled = true
        return mockAuthorizationStatus
    }

    public func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        getCurrentLocationCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        guard let location = mockCurrentLocation else {
            throw MapError.locationUnavailable
        }

        return location
    }

    public func startMonitoring() async {
        startMonitoringCalled = true
    }

    public func stopMonitoring() async {
        stopMonitoringCalled = true
    }

    public func reset() {
        requestPermissionCalled = false
        authorizationStatusCalled = false
        getCurrentLocationCalled = false
        startMonitoringCalled = false
        stopMonitoringCalled = false
        shouldThrowError = false
    }
}
