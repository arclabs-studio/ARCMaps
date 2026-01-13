import Foundation
import CoreLocation

/// CoreLocation-based location service
@MainActor
public final class CoreLocationService: NSObject, LocationService, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager
    private let logger: LoggerProtocol
    private var continuation: CheckedContinuation<Bool, Never>?
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    public init(logger: LoggerProtocol) {
        self.locationManager = CLLocationManager()
        self.logger = logger
        super.init()
        self.locationManager.delegate = self
    }

    // MARK: - LocationService

    public func requestPermission() async -> Bool {
        let status = locationManager.authorizationStatus

        switch status {
        #if os(iOS)
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        #else
        case .authorized, .authorizedAlways:
            return true
        #endif
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                self.continuation = continuation
                locationManager.requestWhenInUseAuthorization()
            }
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    public func authorizationStatus() async -> CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    public func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        let status = locationManager.authorizationStatus

        #if os(iOS)
        let isAuthorized = status == .authorizedWhenInUse || status == .authorizedAlways
        #else
        let isAuthorized = status == .authorized || status == .authorizedAlways
        #endif

        guard isAuthorized else {
            throw MapError.locationPermissionDenied
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    public func startMonitoring() async {
        await logger.info("Starting location monitoring")
        locationManager.startUpdatingLocation()
    }

    public func stopMonitoring() async {
        await logger.info("Stopping location monitoring")
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        #if os(iOS)
        let authorized = status == .authorizedWhenInUse || status == .authorizedAlways
        #else
        let authorized = status == .authorized || status == .authorizedAlways
        #endif

        Task { @MainActor in
            if let continuation = self.continuation {
                continuation.resume(returning: authorized)
                self.continuation = nil
            }
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else { return }

            if let continuation = self.locationContinuation {
                continuation.resume(returning: location.coordinate)
                self.locationContinuation = nil
            }
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            await logger.error("Location error", error: error)

            if let continuation = self.locationContinuation {
                continuation.resume(throwing: MapError.locationUnavailable)
                self.locationContinuation = nil
            }
        }
    }
}
