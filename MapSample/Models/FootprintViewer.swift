//
//  FootprintViewer.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/10/03.
//

import CoreLocation
import Foundation

/// FOOT VIEW で地図に表示する足跡を管理する。
/// - Note: メインスレッドから利用する（表示する足跡を View が購読するため）
final class FootprintViewer: ObservableObject {

    /// 足跡を表示できない理由。
    enum ShowError: Error, Equatable {
        /// 位置情報の計測中。
        case recording
        /// 表示する足跡がない。
        case noFootprints

        /// ユーザーに表示するメッセージ。
        var message: String {
            switch self {
            case .recording:
                return "You need to stop measuring location information."
            case .noFootprints:
                return "There are no footprints to show.\nPlease measure location information and try again."
            }
        }
    }

    /// 表示する足跡どうしの最小距離。
    /// - Note: 立ち止まっている間に同じ場所へ重なって記録された足跡を描画しないため
    static let minimumDistance: CLLocationDistance = 5

    /// 地図に表示している足跡。
    @Published private(set) var footprints: [Footprint] = []

    /// 足跡を表示しているかどうか。
    var isShowing: Bool {
        !footprints.isEmpty
    }

    private let store: FootprintStoreProtocol

    /// - Parameter store: 足跡の取得元
    init(store: FootprintStoreProtocol) {
        self.store = store
    }

    /// 直近に計測したタイトルの足跡の表示/非表示を切り替える。
    /// - Parameters:
    ///   - title: アプリ起動後に計測したタイトル（未計測の場合は nil。その場合は保存済みの最新タイトルを使う）
    ///   - isRecording: 位置情報の計測中かどうか
    func toggle(title: String?, isRecording: Bool) throws {
        guard !isRecording else { throw ShowError.recording }
        guard !isShowing else {
            hide()
            return
        }
        guard let title = try title ?? store.latestTitle() else { throw ShowError.noFootprints }

        let footprints = try store.footprints(title: title)
        guard !footprints.isEmpty else { throw ShowError.noFootprints }
        self.footprints = Self.thinned(footprints)
    }

    /// 足跡を非表示にする。
    func hide() {
        footprints = []
    }

    /// 直前に残した足跡から最小距離未満の足跡を取り除く。
    /// - Parameter footprints: 記録順の足跡
    /// - Returns: 間引いた足跡
    private static func thinned(_ footprints: [Footprint]) -> [Footprint] {
        var result: [Footprint] = []
        var lastLocation: CLLocation?
        for footprint in footprints {
            let location = CLLocation(latitude: footprint.latitude, longitude: footprint.longitude)
            if let lastLocation, location.distance(from: lastLocation) < minimumDistance {
                continue
            }
            result.append(footprint)
            lastLocation = location
        }
        return result
    }
}
