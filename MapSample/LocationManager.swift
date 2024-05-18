//
//  LocationManager.swift
//  MapSample
//
//  Created by Takahiro Kato on 2024/05/04.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {

    let manager = CLLocationManager()
    @Published var location = CLLocation()

    override init() {
        super.init()

        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            location = lastLocation
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("error")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("notDetermined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
        @unknown default:
            fatalError("")
        }
    }
}
