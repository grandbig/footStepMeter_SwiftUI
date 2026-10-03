//
//  FootprintViewer.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/10/03.
//

import Foundation

/// FOOT VIEW で地図に表示する足跡を管理する。
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
    ///   - title: 直近に計測したタイトル（未計測の場合は nil）
    ///   - isRecording: 位置情報の計測中かどうか
    func toggle(title: String?, isRecording: Bool) throws {
        guard !isRecording else { throw ShowError.recording }
        guard !isShowing else {
            hide()
            return
        }
        guard let title else { throw ShowError.noFootprints }

        let footprints = try store.footprints(title: title)
        guard !footprints.isEmpty else { throw ShowError.noFootprints }
        self.footprints = footprints
    }

    /// 足跡を非表示にする。
    func hide() {
        footprints = []
    }
}
