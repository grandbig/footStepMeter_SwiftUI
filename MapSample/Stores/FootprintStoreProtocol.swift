//
//  FootprintStoreProtocol.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/06/15.
//

import CoreLocation
import Foundation

/// 足跡データの永続化操作を定義する。
protocol FootprintStoreProtocol {
    /// 位置情報から足跡を作成して保存する。
    /// - Parameters:
    ///   - title: 計測タイトル
    ///   - location: 位置情報
    func createFootprint(title: String, location: CLLocation) throws

    /// 指定した計測タイトルに紐づく足跡一覧を取得する。
    /// - Parameter title: 計測タイトル
    /// - Returns: 足跡一覧
    func footprints(title: String) throws -> [Footprint]

    /// 計測タイトル別の足跡サマリ一覧を取得する。
    /// - Returns: タイトル別の足跡サマリ一覧
    func routeSummaries() throws -> [FootprintRouteSummary]

    /// 指定した計測タイトルの足跡が存在するかどうかを返す。
    /// - Parameter title: 計測タイトル
    /// - Returns: 足跡が存在する場合はtrue
    func exists(title: String) throws -> Bool

    /// 指定した計測タイトルに紐づく足跡を削除する。
    /// - Parameter title: 計測タイトル
    func delete(title: String) throws
}
