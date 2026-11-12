//
//  FootprintHistoryTests.swift
//  MapSampleTests
//
//  Created by Takahiro Kato on 2026/11/12.
//

import CoreLocation
import SwiftData
import XCTest
@testable import MapSample

final class FootprintHistoryTests: XCTestCase {
    private var container: ModelContainer!
    private var store: FootprintHistoryStoreStub!
    private var history: FootprintHistory!

    override func setUpWithError() throws {
        // Footprint を生成するために、読み込み済みのコンテナを用意しておく
        container = try ModelContainer(
            for: Footprint.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        store = FootprintHistoryStoreStub()
        history = FootprintHistory(store: store)
    }

    override func tearDownWithError() throws {
        history = nil
        store = nil
        container = nil
    }

    func testInitiallyHasNoSummaries() {
        XCTAssertTrue(history.summaries.isEmpty)
    }

    func testReloadLoadsSummariesInStoreOrder() throws {
        let summaries = [
            FootprintRouteSummary(title: "latest", count: 3),
            FootprintRouteSummary(title: "older", count: 10),
        ]
        store.summaries = summaries

        try history.reload()

        XCTAssertEqual(history.summaries, summaries)
    }

    func testReloadReflectsChangesSinceLastLoad() throws {
        store.summaries = [FootprintRouteSummary(title: "route", count: 1)]
        try history.reload()

        store.summaries = [
            FootprintRouteSummary(title: "new", count: 2),
            FootprintRouteSummary(title: "route", count: 5),
        ]
        try history.reload()

        XCTAssertEqual(history.summaries, store.summaries)
    }

    func testReloadWithoutSavedFootprintsClearsSummaries() throws {
        store.summaries = [FootprintRouteSummary(title: "route", count: 1)]
        try history.reload()

        store.summaries = []
        try history.reload()

        XCTAssertTrue(history.summaries.isEmpty)
    }

    func testReloadPropagatesStoreErrorAndKeepsPreviousSummaries() throws {
        let summaries = [FootprintRouteSummary(title: "route", count: 1)]
        store.summaries = summaries
        try history.reload()

        store.fetchError = FootprintHistoryStoreStub.StubError()

        XCTAssertThrowsError(try history.reload()) { error in
            XCTAssertTrue(error is FootprintHistoryStoreStub.StubError)
        }
        XCTAssertEqual(history.summaries, summaries)
    }

    func testFootprintsReturnsFootprintsOfTitleInOrder() throws {
        let footprints = [makeFootprint(title: "route", latitude: 35.000), makeFootprint(title: "route", latitude: 35.001)]
        store.footprintsByTitle = ["route": footprints, "other": [makeFootprint(title: "other", latitude: 35.002)]]

        let result = try history.footprints(title: "route")

        XCTAssertEqual(result.map(\.id), footprints.map(\.id))
        XCTAssertEqual(store.requestedTitles, ["route"])
    }

    func testFootprintsThinsFootprintsCloserThanMinimumDistance() throws {
        // 緯度 0.00001 度は約 1.1m、0.001 度は約 111m
        let first = makeFootprint(title: "route", latitude: 35.00000)
        let near = makeFootprint(title: "route", latitude: 35.00001)
        let far = makeFootprint(title: "route", latitude: 35.00100)
        store.footprintsByTitle = ["route": [first, near, far]]

        let result = try history.footprints(title: "route")

        XCTAssertEqual(result.map(\.id), [first.id, far.id])
    }

    func testFootprintsWithoutSavedFootprintsReturnsEmpty() throws {
        XCTAssertTrue(try history.footprints(title: "route").isEmpty)
    }

    func testFootprintsPropagatesStoreError() {
        store.fetchError = FootprintHistoryStoreStub.StubError()

        XCTAssertThrowsError(try history.footprints(title: "route")) { error in
            XCTAssertTrue(error is FootprintHistoryStoreStub.StubError)
        }
    }

    private func makeFootprint(title: String, latitude: Double) -> Footprint {
        Footprint(title: title, latitude: latitude, longitude: 139.0, accuracy: 5, speed: 1, direction: 90)
    }
}

/// テスト用の足跡取得元。
private final class FootprintHistoryStoreStub: FootprintStoreProtocol {
    struct StubError: Error {}

    var summaries: [FootprintRouteSummary] = []
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
        if let fetchError {
            throw fetchError
        }
        return summaries
    }

    func latestTitle() throws -> String? {
        summaries.first?.title
    }

    func exists(title: String) throws -> Bool {
        summaries.contains { $0.title == title }
    }

    func delete(title: String) throws {}
}
