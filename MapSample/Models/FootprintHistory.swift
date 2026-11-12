//
//  FootprintHistory.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/11/12.
//

import Foundation

/// 足跡履歴一覧と履歴マップに表示する足跡を管理する。
/// - Note: メインスレッドから利用する（一覧を View が購読するため）
final class FootprintHistory: ObservableObject {

    /// タイトル別の足跡サマリ（直近に記録したタイトルが先頭）。
    @Published private(set) var summaries: [FootprintRouteSummary] = []

    private let store: FootprintStoreProtocol

    /// - Parameter store: 足跡の取得元
    init(store: FootprintStoreProtocol) {
        self.store = store
    }

    /// 保存済みの足跡からサマリを読み込み直す。
    /// - Note: 読み込みに失敗した場合は、直前に読み込んだサマリを残す
    func reload() throws {
        summaries = try store.routeSummaries()
    }

    /// 履歴マップに表示する、指定したタイトルの足跡を取得する。
    /// - Parameter title: 計測タイトル
    /// - Returns: 記録順の足跡（立ち止まっている間に重なって記録された足跡は間引く）
    func footprints(title: String) throws -> [Footprint] {
        FootprintThinner.thinned(try store.footprints(title: title))
    }
}
