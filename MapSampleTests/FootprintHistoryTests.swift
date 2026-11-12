//
//  FootprintHistoryTests.swift
//  MapSampleTests
//
//  Created by Takahiro Kato on 2026/11/12.
//

import CoreLocation
import XCTest
@testable import MapSample

final class FootprintHistoryTests: XCTestCase {
    private var store: FootprintHistoryStoreStub!
    private var history: FootprintHistory!

    override func setUpWithError() throws {
        store = FootprintHistoryStoreStub()
        history = FootprintHistory(store: store)
    }

    override func tearDownWithError() throws {
        history = nil
        store = nil
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
}

/// テスト用の足跡取得元。
private final class FootprintHistoryStoreStub: FootprintStoreProtocol {
    struct StubError: Error {}

    var summaries: [FootprintRouteSummary] = []
    var fetchError: Error?

    func createFootprint(title: String, location: CLLocation) throws {}

    func footprints(title: String) throws -> [Footprint] {
        []
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
