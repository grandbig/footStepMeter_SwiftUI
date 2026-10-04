//
//  FootprintRecorderTests.swift
//  MapSampleTests
//
//  Created by Takahiro Kato on 2026/10/03.
//

import Combine
import CoreLocation
import XCTest
@testable import MapSample

final class FootprintRecorderTests: XCTestCase {
    private var store: FootprintStoreStub!
    private var locations: PassthroughSubject<[CLLocation], Never>!
    private var recorder: FootprintRecorder!

    override func setUpWithError() throws {
        store = FootprintStoreStub()
        locations = PassthroughSubject()
        recorder = FootprintRecorder(store: store, locations: locations.eraseToAnyPublisher())
    }

    override func tearDownWithError() throws {
        recorder = nil
        locations = nil
        store = nil
    }

    func testStartWithEmptyTitleThrows() {
        XCTAssertThrowsError(try recorder.start(title: "")) { error in
            XCTAssertEqual(error as? FootprintRecorder.StartError, .emptyTitle)
        }
        XCTAssertThrowsError(try recorder.start(title: "  \n")) { error in
            XCTAssertEqual(error as? FootprintRecorder.StartError, .emptyTitle)
        }
        XCTAssertFalse(recorder.isRecording)
        XCTAssertTrue(store.checkedTitles.isEmpty)
    }

    func testStartWithDuplicateTitleThrows() {
        store.existingTitles = ["route"]

        XCTAssertThrowsError(try recorder.start(title: "route")) { error in
            XCTAssertEqual(error as? FootprintRecorder.StartError, .duplicateTitle)
        }
        XCTAssertFalse(recorder.isRecording)
        XCTAssertNil(recorder.title)
    }

    func testStartWithPaddedDuplicateTitleThrows() {
        store.existingTitles = ["route"]

        XCTAssertThrowsError(try recorder.start(title: " route ")) { error in
            XCTAssertEqual(error as? FootprintRecorder.StartError, .duplicateTitle)
        }
        XCTAssertEqual(store.checkedTitles, ["route"])
    }

    func testStartPropagatesStoreError() {
        store.existsError = FootprintStoreStub.StubError()

        XCTAssertThrowsError(try recorder.start(title: "route")) { error in
            XCTAssertTrue(error is FootprintStoreStub.StubError)
        }
        XCTAssertFalse(recorder.isRecording)
        XCTAssertNil(recorder.title)
    }

    func testStartTrimsTitle() throws {
        try recorder.start(title: " route ")

        XCTAssertTrue(recorder.isRecording)
        XCTAssertEqual(recorder.title, "route")
        XCTAssertEqual(store.checkedTitles, ["route"])
    }

    func testRecordsLocationsWhileRecording() throws {
        try recorder.start(title: "route")

        locations.send([makeLocation(timestamp: 1), makeLocation(timestamp: 2)])
        locations.send([makeLocation(timestamp: 3)])

        XCTAssertEqual(recorder.count, 3)
        XCTAssertEqual(store.created.map(\.title), ["route", "route", "route"])
        XCTAssertEqual(
            store.created.map(\.location.timestamp),
            [1, 2, 3].map { Date(timeIntervalSince1970: $0) }
        )
    }

    func testIgnoresLocationsBeforeStart() throws {
        locations.send([makeLocation(timestamp: 1)])

        XCTAssertEqual(recorder.count, 0)
        XCTAssertTrue(store.created.isEmpty)
    }

    func testStopsSavingAfterStop() throws {
        try recorder.start(title: "route")
        locations.send([makeLocation(timestamp: 1)])
        recorder.stop()
        locations.send([makeLocation(timestamp: 2)])

        XCTAssertFalse(recorder.isRecording)
        XCTAssertEqual(recorder.count, 1)
        XCTAssertEqual(store.created.map(\.location.timestamp), [Date(timeIntervalSince1970: 1)])
    }

    func testIgnoresEmptyLocations() throws {
        try recorder.start(title: "route")

        locations.send([])

        XCTAssertEqual(recorder.count, 0)
        XCTAssertTrue(store.created.isEmpty)
    }

    func testContinuesRecordingAfterSaveFailure() throws {
        try recorder.start(title: "route")

        store.createError = FootprintStoreStub.StubError()
        locations.send([makeLocation(timestamp: 1)])
        store.createError = nil
        locations.send([makeLocation(timestamp: 2)])

        XCTAssertTrue(recorder.isRecording)
        XCTAssertEqual(recorder.count, 1)
        XCTAssertEqual(store.created.map(\.location.timestamp), [Date(timeIntervalSince1970: 2)])
    }

    func testStartResetsCountForNewTitle() throws {
        try recorder.start(title: "first")
        locations.send([makeLocation(timestamp: 1)])
        recorder.stop()

        try recorder.start(title: "second")
        locations.send([makeLocation(timestamp: 2)])

        XCTAssertEqual(recorder.title, "second")
        XCTAssertEqual(recorder.count, 1)
        XCTAssertEqual(store.created.map(\.title), ["first", "second"])
    }

    private func makeLocation(timestamp: TimeInterval) -> CLLocation {
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 35.0, longitude: 139.0),
            altitude: 0,
            horizontalAccuracy: 10,
            verticalAccuracy: 0,
            course: 0,
            speed: 0,
            timestamp: Date(timeIntervalSince1970: timestamp)
        )
    }
}

/// テスト用の足跡保存先。
private final class FootprintStoreStub: FootprintStoreProtocol {
    struct StubError: Error {}

    var existingTitles: Set<String> = []
    var existsError: Error?
    var createError: Error?
    private(set) var checkedTitles: [String] = []
    private(set) var created: [(title: String, location: CLLocation)] = []

    func createFootprint(title: String, location: CLLocation) throws {
        if let createError {
            throw createError
        }
        created.append((title, location))
    }

    func footprints(title: String) throws -> [Footprint] {
        []
    }

    func routeSummaries() throws -> [FootprintRouteSummary] {
        []
    }

    func latestTitle() throws -> String? {
        nil
    }

    func exists(title: String) throws -> Bool {
        checkedTitles.append(title)
        if let existsError {
            throw existsError
        }
        return existingTitles.contains(title)
    }

    func delete(title: String) throws {}
}
