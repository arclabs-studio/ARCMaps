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
        case .authorizedWhenInUse, .authorizedAlways:
            return true
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

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
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
        Task { @MainActor in
            let status = manager.authorizationStatus
            let authorized = status == .authorizedWhenInUse || status == .authorizedAlways

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
