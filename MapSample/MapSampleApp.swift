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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Footprint.self)
    }
}
