//
//  MapSampleApp.swift
//  MapSample
//
//  Created by Takahiro Kato on 2024/05/04.
//

import SwiftData
import SwiftUI

@main
struct MapSampleApp: App {

    /// 足跡の保存領域。
    private let container: ModelContainer
    /// 位置情報の管理を担う。
    private let locationManager = LocationManager()
    /// 計測中の位置情報を足跡として記録する。
    private let recorder: FootprintRecorder

    init() {
        do {
            container = try ModelContainer(for: Footprint.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        recorder = FootprintRecorder(
            store: FootprintStore(modelContext: container.mainContext),
            locations: locationManager.locationsPublisher
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView(manager: locationManager, recorder: recorder)
        }
        .modelContainer(container)
    }
}
