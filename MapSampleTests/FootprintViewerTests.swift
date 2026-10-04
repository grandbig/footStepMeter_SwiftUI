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
        let footprints = [makeFootprint(title: "route", latitude: 35.000), makeFootprint(title: "route", latitude: 35.001)]
        store.footprintsByTitle = ["route": footprints]

        try viewer.toggle(title: "route", isRecording: false)

        XCTAssertTrue(viewer.isShowing)
        XCTAssertEqual(viewer.footprints.map(\.id), footprints.map(\.id))
        XCTAssertEqual(store.requestedTitles, ["route"])
    }

    func testToggleShowsOnlyRequestedTitle() throws {
        let route = makeFootprint(title: "route", latitude: 35.000)
        store.footprintsByTitle = ["route": [route], "other": [makeFootprint(title: "other", latitude: 35.001)]]

        try viewer.toggle(title: "route", isRecording: false)

        XCTAssertEqual(viewer.footprints.map(\.id), [route.id])
    }

    func testToggleWithoutTitleShowsLatestSavedTitle() throws {
        let latest = makeFootprint(title: "latest", latitude: 35.000)
        store.footprintsByTitle = ["latest": [latest]]
        store.latest = "latest"

        try viewer.toggle(title: nil, isRecording: false)

        XCTAssertEqual(viewer.footprints.map(\.id), [latest.id])
        XCTAssertEqual(store.requestedTitles, ["latest"])
    }

    func testToggleThinsFootprintsCloserThanMinimumDistance() throws {
        // 緯度 0.00001 度は約 1.1m、0.001 度は約 111m
        let first = makeFootprint(title: "route", latitude: 35.00000)
        let near = makeFootprint(title: "route", latitude: 35.00001)
        let far = makeFootprint(title: "route", latitude: 35.00100)
        let nearFar = makeFootprint(title: "route", latitude: 35.00101)
        store.footprintsByTitle = ["route": [first, near, far, nearFar]]

        try viewer.toggle(title: "route", isRecording: false)

        XCTAssertEqual(viewer.footprints.map(\.id), [first.id, far.id])
    }

    func testToggleAgainHidesFootprints() throws {
        store.footprintsByTitle = ["route": [makeFootprint(title: "route", latitude: 35.0)]]
        try viewer.toggle(title: "route", isRecording: false)

        try viewer.toggle(title: "route", isRecording: false)

        XCTAssertFalse(viewer.isShowing)
        XCTAssertTrue(viewer.footprints.isEmpty)
        XCTAssertEqual(store.requestedTitles, ["route"])
    }

    func testToggleWhileShowingHidesRegardlessOfTitle() throws {
        store.footprintsByTitle = [
            "route": [makeFootprint(title: "route", latitude: 35.0)],
            "other": [makeFootprint(title: "other", latitude: 35.1)],
        ]
        try viewer.toggle(title: "route", isRecording: false)

        try viewer.toggle(title: "other", isRecording: false)

        XCTAssertFalse(viewer.isShowing)
        XCTAssertEqual(store.requestedTitles, ["route"])
    }

    func testToggleWhileRecordingThrows() {
        store.footprintsByTitle = ["route": [makeFootprint(title: "route", latitude: 35.0)]]

        XCTAssertThrowsError(try viewer.toggle(title: "route", isRecording: true)) { error in
            XCTAssertEqual(error as? FootprintViewer.ShowError, .recording)
        }
        XCTAssertFalse(viewer.isShowing)
        XCTAssertTrue(store.requestedTitles.isEmpty)
    }

    func testToggleWhileRecordingKeepsShownFootprints() throws {
        store.footprintsByTitle = ["route": [makeFootprint(title: "route", latitude: 35.0)]]
        try viewer.toggle(title: "route", isRecording: false)

        XCTAssertThrowsError(try viewer.toggle(title: "route", isRecording: true)) { error in
            XCTAssertEqual(error as? FootprintViewer.ShowError, .recording)
        }
        XCTAssertTrue(viewer.isShowing)
        XCTAssertEqual(store.requestedTitles, ["route"])
    }

    func testToggleWithoutAnyTitleThrows() {
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
        XCTAssertEqual(store.requestedTitles, ["route"])
    }

    func testTogglePropagatesStoreError() {
        store.fetchError = FootprintViewerStoreStub.StubError()

        XCTAssertThrowsError(try viewer.toggle(title: "route", isRecording: false)) { error in
            XCTAssertTrue(error is FootprintViewerStoreStub.StubError)
        }
        XCTAssertFalse(viewer.isShowing)
        XCTAssertEqual(store.requestedTitles, ["route"])
    }

    func testHideClearsFootprints() throws {
        store.footprintsByTitle = ["route": [makeFootprint(title: "route", latitude: 35.0)]]
        try viewer.toggle(title: "route", isRecording: false)

        viewer.hide()

        XCTAssertFalse(viewer.isShowing)
        XCTAssertTrue(viewer.footprints.isEmpty)
    }

    func testHideWhenNotShowingKeepsEmpty() {
        viewer.hide()

        XCTAssertFalse(viewer.isShowing)
        XCTAssertTrue(viewer.footprints.isEmpty)
    }

    private func makeFootprint(title: String, latitude: Double) -> Footprint {
        Footprint(title: title, latitude: latitude, longitude: 139.0, accuracy: 5, speed: 1, direction: 90)
    }
}

/// テスト用の足跡取得元。
private final class FootprintViewerStoreStub: FootprintStoreProtocol {
    struct StubError: Error {}

    var footprintsByTitle: [String: [Footprint]] = [:]
    var latest: String?
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

    func latestTitle() throws -> String? {
        latest
    }

    func exists(title: String) throws -> Bool {
        footprintsByTitle[title] != nil
    }

    func delete(title: String) throws {}
}
