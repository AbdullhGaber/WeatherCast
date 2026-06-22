// Presentation/Dashboard/LocationManager.swift
// WeatherCast App
// Uses CoreLocation to fetch current simulator/device location.

import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var locationCompletion: (@MainActor (CLLocation?) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    @MainActor
    func requestLocation(completion: @escaping @MainActor (CLLocation?) -> Void) {
        self.locationCompletion = completion

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .restricted, .denied:
            completion(nil)
            self.locationCompletion = nil
        @unknown default:
            completion(nil)
            self.locationCompletion = nil
        }
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            Task { @MainActor in
                locationCompletion?(nil)
                locationCompletion = nil
            }
        default:
            break
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            Task { @MainActor in
                locationCompletion?(location)
                locationCompletion = nil
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed to fetch location: \(error.localizedDescription)")
        Task { @MainActor in
            locationCompletion?(nil)
            locationCompletion = nil
        }
    }
}
