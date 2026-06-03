//
//  Footprint.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/06/03.
//

import Foundation
import SwiftData

/// 足跡。
@Model
final class Footprint {
    /// 一意なID。
    @Attribute(.unique) var id: UUID
    /// 計測タイトル。
    var title: String
    /// 緯度。
    var latitude: Double
    /// 経度。
    var longitude: Double
    /// 水平精度。
    var accuracy: Double
    /// 速度。
    var speed: Double
    /// 方角。
    var direction: Double
    /// 作成日時。
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        latitude: Double,
        longitude: Double,
        accuracy: Double,
        speed: Double,
        direction: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
        self.speed = speed
        self.direction = direction
        self.createdAt = createdAt
    }
}
