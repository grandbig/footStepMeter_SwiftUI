//
//  LocationAccuracy.swift
//  MapSample
//
//  Created by Takahiro Kato on 2024/05/25.
//

import Foundation
import CoreLocation

/// 位置情報の取得精度
enum LocationAccuracy: Int, CaseIterable {
    /// 指定なし
    case none
    /// 最高精度
    case bestForNavigation
    /// 高精度
    case best
    /// 誤差10m以内
    case nearestTenMeters
    /// 誤差100m以内
    case hundredMeters
    /// 誤差1km以内
    case kilometer
    /// 誤差3km以内
    case threeKilometers

    /// CLLocationAccuracy。
    var cLLocationAccuracy: CLLocationAccuracy? {
        switch self {
        case .none:
            return nil
        case .bestForNavigation:
            return kCLLocationAccuracyBestForNavigation
        case .best:
            return kCLLocationAccuracyBest
        case .nearestTenMeters:
            return kCLLocationAccuracyNearestTenMeters
        case .hundredMeters:
            return kCLLocationAccuracyHundredMeters
        case .kilometer:
            return kCLLocationAccuracyKilometer
        case .threeKilometers:
            return kCLLocationAccuracyThreeKilometers
        }
    }

    /// 説明文。
    var description: String {
        switch self {
        case .none:
            return "none"
        case .bestForNavigation:
            return "bestForNavigation"
        case .best:
            return "best"
        case .nearestTenMeters:
            return "nearestTenMeters"
        case .hundredMeters:
            return "hundredMeters"
        case .kilometer:
            return "kilometer"
        case .threeKilometers:
            return "threeKilometers"
        }
    }
}
