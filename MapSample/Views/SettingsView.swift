//
//  SettingsView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/10/04.
//

import SwiftUI

/// 設定画面。
/// - Note: 中身（足跡履歴、このアプリについて、ライセンス表示）は今後実装する
struct SettingsView: View {

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Coming Soon",
                systemImage: "gearshape",
                description: Text("Footprint history and app information will be available here.")
            )
            .navigationTitle("SETTINGS")
            .mainNavigationBarStyle()
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
