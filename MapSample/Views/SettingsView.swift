//
//  SettingsView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/10/04.
//

import SwiftData
import SwiftUI

/// 設定画面。足跡履歴とこのアプリについての画面へ遷移する。
struct SettingsView: View {

    /// 足跡履歴一覧に表示する足跡のサマリを管理する。
    let history: FootprintHistory

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    FootprintHistoryView(history: history)
                } label: {
                    Label("FOOTPRINT HISTORY", systemImage: "shoeprints.fill")
                }
                NavigationLink {
                    AboutAppView()
                } label: {
                    Label("ABOUT APP", systemImage: "info.circle")
                }
            }
            .navigationTitle("SETTINGS")
            .mainNavigationBarStyle()
        }
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(for: Footprint.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let store = FootprintStore(modelContext: container.mainContext)
    return SettingsView(history: FootprintHistory(store: store))
        .modelContainer(container)
}
