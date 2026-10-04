//
//  SettingsView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/10/04.
//

import SwiftUI

/// 設定画面。
/// - Note: 中身（足跡履歴、このアプリについて）は今後実装する
struct SettingsView: View {

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Coming Soon",
                systemImage: "gearshape",
                description: Text("Footprint history and app information will be available here.")
            )
            .navigationTitle("SETTINGS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("main"), for: .navigationBar)
            // 地図と違いバーの下に流れる内容がないため、背景色を常に表示する
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
