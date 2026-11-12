//
//  FootprintThinner.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/11/12.
//

import CoreLocation
import Foundation

/// 地図に表示する足跡を間引く。
enum FootprintThinner {

    /// 表示する足跡どうしの最小距離。
    /// - Note: 立ち止まっている間に同じ場所へ重なって記録された足跡を描画しないため
    static let minimumDistance: CLLocationDistance = 5

    /// 直前に残した足跡から最小距離未満の足跡を取り除く。
    /// - Parameter footprints: 記録順の足跡
    /// - Returns: 間引いた足跡
    static func thinned(_ footprints: [Footprint]) -> [Footprint] {
        var result: [Footprint] = []
        var lastLocation: CLLocation?
        for footprint in footprints {
            let location = CLLocation(latitude: footprint.latitude, longitude: footprint.longitude)
            if let lastLocation, location.distance(from: lastLocation) < minimumDistance {
                continue
            }
            result.append(footprint)
            lastLocation = location
        }
        return result
    }
}
