//
//  MainNavigationBarStyle.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/10/04.
//

import SwiftUI

extension View {

    /// アプリ共通のナビゲーションバーの見た目（青い背景に白い文字）を設定する。
    /// - Returns: ナビゲーションバーの見た目を設定したView
    func mainNavigationBarStyle() -> some View {
        self.navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("main"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar(.visible, for: .navigationBar)
    }
}
