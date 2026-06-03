//
//  FootprintRouteSummary.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/06/03.
//

import Foundation

/// タイトル別の足跡サマリ。
struct FootprintRouteSummary: Identifiable, Equatable {
    /// 一意なID。
    let id: String
    /// 計測タイトル。
    let title: String
    /// タイトルに紐づく足跡数。
    let count: Int

    init(title: String, count: Int) {
        self.id = title
        self.title = title
        self.count = count
    }
}
