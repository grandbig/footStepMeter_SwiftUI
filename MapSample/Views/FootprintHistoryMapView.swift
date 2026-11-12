//
//  FootprintHistoryMapView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/11/12.
//

import MapKit
import SwiftData
import SwiftUI

/// 履歴マップ画面。選択したタイトルの足跡を、最初の足跡を中心にして地図に表示する。
struct FootprintHistoryMapView: View {

    /// 表示する計測タイトル。
    let title: String
    /// 表示する足跡の取得元。
    let history: FootprintHistory

    /// 表示する足跡（読み込む前は nil）。
    @State private var footprints: [Footprint]?
    /// エラーアラートの表示フラグ。
    @State private var isShowingErrorAlert = false

    var body: some View {
        content
            .navigationTitle(title)
            .mainNavigationBarStyle()
            .onAppear(perform: load)
            .alert("Error", isPresented: $isShowingErrorAlert, actions: {
                Button("OK") {}
            }, message: {
                Text("Failed to load the footprints.")
            })
    }

    @ViewBuilder
    private var content: some View {
        if let footprints, let first = footprints.first {
            // 地図の初期位置は最初に作ったときだけ使われるため、足跡を読み込んでから地図を作る
            MapView(footprints: footprints, initialPosition: Self.cameraPosition(centeredOn: first))
        } else if footprints != nil {
            ContentUnavailableView(
                "No Footprints",
                systemImage: "shoeprints.fill",
                description: Text("The footprints of this title have been deleted.")
            )
        } else {
            // 読み込み前でも onAppear が呼ばれるよう、空のビューを置く
            Color.clear
        }
    }

    /// 足跡を読み込む。
    /// - Note: 計測中のタイトルは地図のタブで足跡が増えるため、表示するたびに読み込み直す（地図の位置は変えない）。読み込みに失敗した場合は、エラーアラートを表示する
    private func load() {
        do {
            footprints = try history.footprints(title: title)
        } catch {
            isShowingErrorAlert = true
        }
    }

    /// 足跡を中心にしたカメラ位置。
    /// - Parameter footprint: 中心にする足跡
    /// - Returns: カメラ位置
    private static func cameraPosition(centeredOn footprint: Footprint) -> MapCameraPosition {
        let center = CLLocationCoordinate2D(latitude: footprint.latitude, longitude: footprint.longitude)
        return .camera(MapCamera(centerCoordinate: center, distance: 1000))
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(for: Footprint.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let store = FootprintStore(modelContext: container.mainContext)
    return NavigationStack {
        FootprintHistoryMapView(title: "route", history: FootprintHistory(store: store))
    }
    .modelContainer(container)
}
