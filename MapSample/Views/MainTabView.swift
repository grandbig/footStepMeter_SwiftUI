//
//  MainTabView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/10/04.
//

import SwiftData
import SwiftUI

/// アプリのルート画面。マップと設定をタブで切り替える。
struct MainTabView: View {

    /// 位置情報の管理を担う。
    let manager: LocationManager
    /// 計測中の位置情報を足跡として記録する。
    let recorder: FootprintRecorder
    /// FOOT VIEW で地図に表示する足跡を管理する。
    let viewer: FootprintViewer

    var body: some View {
        TabView {
            ContentView(manager: manager, recorder: recorder, viewer: viewer)
                .tabItem {
                    Label("MAP", systemImage: "map")
                }
            SettingsView()
                .tabItem {
                    Label("SETTINGS", systemImage: "gearshape")
                }
        }
        .tint(Color("main"))
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(for: Footprint.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let store = FootprintStore(modelContext: container.mainContext)
    let manager = LocationManager()
    let recorder = FootprintRecorder(store: store, locations: manager.locationsPublisher)
    return MainTabView(manager: manager, recorder: recorder, viewer: FootprintViewer(store: store))
        .modelContainer(container)
}
