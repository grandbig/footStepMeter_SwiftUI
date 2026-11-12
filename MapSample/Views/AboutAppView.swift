//
//  AboutAppView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/11/12.
//

import SwiftUI

/// このアプリについて画面。アプリの使い方とバージョンを表示する。
struct AboutAppView: View {

    var body: some View {
        List {
            Section("How to measure your footprints") {
                Text("1. Tap the START button on the MAP tab")
                Text("2. Select the accuracy")
                Text("3. Enter a title")
            }
            Section("How to stop measuring") {
                Text("1. Tap the STOP button on the MAP tab")
                Text("2. Tap OK on the confirmation")
            }
            Section("Show the latest footprints") {
                Text("Tap the FOOT VIEW button on the MAP tab. Tap it again to hide them.")
            }
            Section("Check your footprint history") {
                Text("Select FOOTPRINT HISTORY on the SETTINGS tab.")
            }
            Section {
                LabeledContent("Version", value: Self.version)
            }
        }
        .navigationTitle("ABOUT APP")
        .mainNavigationBarStyle()
    }

    /// アプリのバージョン（例: 1.0 (1)）。
    private static var version: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "-"
        let build = info?["CFBundleVersion"] as? String ?? "-"
        return "\(version) (\(build))"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AboutAppView()
    }
}
