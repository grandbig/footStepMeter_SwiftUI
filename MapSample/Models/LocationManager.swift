//
//  LocationManager.swift
//  MapSample
//
//  Created by Takahiro Kato on 2024/05/04.
//

import Foundation
import CoreLocation

/// 位置情報の管理を担う。
final class LocationManager: NSObject, ObservableObject {

    /// CLLocationManager。
    let manager = CLLocationManager()
    
    /// 位置情報。
    @Published var location = CLLocation()

    override init() {
        super.init()

        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }
    
    /// 位置情報の取得処理を開始する。
    /// - Parameter accuracy: 位置情報の取得精度
    func startUpdateingLocation(accuracy: LocationAccuracy) {
        guard let cLLocationAccuracy = accuracy.cLLocationAccuracy else { return }
        manager.desiredAccuracy = cLLocationAccuracy
        manager.startUpdatingLocation()
    }
    
    /// 位置情報の取得処理を終了する。
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate

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
