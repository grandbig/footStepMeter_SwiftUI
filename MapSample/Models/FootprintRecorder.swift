//
//  FootprintRecorder.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/10/03.
//

import Combine
import CoreLocation
import Foundation

/// 計測中に取得した位置情報を足跡として記録する。
/// - Note: メインスレッドから利用する。位置情報の通知もメインスレッドで受け取る前提（`LocationManager` をメインスレッドで生成し、保存先に `ModelContainer.mainContext` を使うため）
final class FootprintRecorder: ObservableObject {

    /// 記録を開始できない理由。
    enum StartError: Error, Equatable {
        /// タイトルが空。
        case emptyTitle
        /// 同名のタイトルが既に存在する。
        case duplicateTitle

        /// ユーザーに表示するメッセージ。
        var message: String {
            switch self {
            case .emptyTitle:
                return "Please enter a title."
            case .duplicateTitle:
                return "The same title already exists. Please change the title."
            }
        }
    }

    /// 直近に記録を開始した計測タイトル。
    @Published private(set) var title: String?
    /// 記録中かどうか。
    @Published private(set) var isRecording = false
    /// 直近の計測タイトルで保存した足跡の数。
    @Published private(set) var count = 0

    private let store: FootprintStoreProtocol
    private var cancellable: AnyCancellable?

    /// - Parameters:
    ///   - store: 足跡の保存先
    ///   - locations: 取得した位置情報の通知
    init(store: FootprintStoreProtocol, locations: AnyPublisher<[CLLocation], Never>) {
        self.store = store
        cancellable = locations.sink { [weak self] locations in
            self?.record(locations)
        }
    }

    /// 記録を開始する。
    /// - Parameter title: 計測タイトル（前後の空白は取り除く）
    func start(title: String) throws {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw StartError.emptyTitle }
        guard try !store.exists(title: title) else { throw StartError.duplicateTitle }

        self.title = title
        count = 0
        isRecording = true
    }

    /// 記録を終了する。
    func stop() {
        isRecording = false
    }

    /// 記録中であれば、位置情報を足跡として保存する。
    /// - Parameter locations: 取得した位置情報
    private func record(_ locations: [CLLocation]) {
        guard isRecording, let title else { return }

        for location in locations {
            do {
                try store.createFootprint(title: title, location: location)
                count += 1
            } catch {
                print("Failed to save footprint: \(error)")
            }
        }
    }
}
