//
//  FootprintViewerTests.swift
//  MapSampleTests
//
//  Created by Takahiro Kato on 2026/10/03.
//

import CoreLocation
import SwiftData
import XCTest
@testable import MapSample

final class FootprintViewerTests: XCTestCase {
    private var container: ModelContainer!
    private var store: FootprintViewerStoreStub!
    private var viewer: FootprintViewer!

    override func setUpWithError() throws {
        // Footprint を生成するために、読み込み済みのコンテナを用意しておく
        container = try ModelContainer(
            for: Footprint.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        store = FootprintViewerStoreStub()
        viewer = FootprintViewer(store: store)
    }

    override func tearDownWithError() throws {
        viewer = nil
        store = nil
        container = nil
    }

    func testToggleShowsFootprintsOfTitle() throws {
        let footprints = [makeFootprint(title: "route"), makeFootprint(title: "route")]
        store.footprintsByTitle = ["route": footprints]

        try viewer.toggle(title: "route", isRecording: false)

        XCTAssertTrue(viewer.isShowing)
        XCTAssertEqual(viewer.footprints.map(\.id), footprints.map(\.id))
        XCTAssertEqual(store.requestedTitles, ["route"])
    }

    func testToggleAgainHidesFootprints() throws {
        store.footprintsByTitle = ["route": [makeFootprint(title: "route")]]
        try viewer.toggle(title: "route", isRecording: false)

        try viewer.toggle(title: "route", isRecording: false)

        XCTAssertFalse(viewer.isShowing)
        XCTAssertTrue(viewer.footprints.isEmpty)
        XCTAssertEqual(store.requestedTitles, ["route"])
    }

    func testToggleWhileRecordingThrows() {
        store.footprintsByTitle = ["route": [makeFootprint(title: "route")]]

        XCTAssertThrowsError(try viewer.toggle(title: "route", isRecording: true)) { error in
            XCTAssertEqual(error as? FootprintViewer.ShowError, .recording)
        }
        XCTAssertFalse(viewer.isShowing)
        XCTAssertTrue(store.requestedTitles.isEmpty)
    }

    func testToggleWithoutTitleThrows() {
        XCTAssertThrowsError(try viewer.toggle(title: nil, isRecording: false)) { error in
            XCTAssertEqual(error as? FootprintViewer.ShowError, .noFootprints)
        }
        XCTAssertFalse(viewer.isShowing)
        XCTAssertTrue(store.requestedTitles.isEmpty)
    }

    func testToggleWithoutSavedFootprintsThrows() {
        XCTAssertThrowsError(try viewer.toggle(title: "route", isRecording: false)) { error in
            XCTAssertEqual(error as? FootprintViewer.ShowError, .noFootprints)
        }
        XCTAssertFalse(viewer.isShowing)
    }

    func testTogglePropagatesStoreError() {
        store.fetchError = FootprintViewerStoreStub.StubError()

        XCTAssertThrowsError(try viewer.toggle(title: "route", isRecording: false)) { error in
            XCTAssertTrue(error is FootprintViewerStoreStub.StubError)
        }
        XCTAssertFalse(viewer.isShowing)
    }

    func testHideClearsFootprints() throws {
        store.footprintsByTitle = ["route": [makeFootprint(title: "route")]]
        try viewer.toggle(title: "route", isRecording: false)

        viewer.hide()

        XCTAssertFalse(viewer.isShowing)
        XCTAssertTrue(viewer.footprints.isEmpty)
    }

    private func makeFootprint(title: String) -> Footprint {
        Footprint(title: title, latitude: 35.0, longitude: 139.0, accuracy: 5, speed: 1, direction: 90)
    }
}

/// テスト用の足跡取得元。
private final class FootprintViewerStoreStub: FootprintStoreProtocol {
    struct StubError: Error {}

    var footprintsByTitle: [String: [Footprint]] = [:]
    var fetchError: Error?
    private(set) var requestedTitles: [String] = []

    func createFootprint(title: String, location: CLLocation) throws {}

    func footprints(title: String) throws -> [Footprint] {
        requestedTitles.append(title)
        if let fetchError {
            throw fetchError
        }
        return footprintsByTitle[title] ?? []
    }

    func routeSummaries() throws -> [FootprintRouteSummary] {
        []
    }

    func exists(title: String) throws -> Bool {
        footprintsByTitle[title] != nil
    }

    func delete(title: String) throws {}
}
