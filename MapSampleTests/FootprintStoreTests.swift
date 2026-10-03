//
//  FootprintStoreTests.swift
//  MapSampleTests
//
//  Created by Takahiro Kato on 2026/10/03.
//

import CoreLocation
import SwiftData
import XCTest
@testable import MapSample

final class FootprintStoreTests: XCTestCase {
    private var container: ModelContainer!
    private var store: FootprintStore!

    override func setUpWithError() throws {
        container = try ModelContainer(
            for: Footprint.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        store = FootprintStore(modelContext: ModelContext(container))
    }

    override func tearDownWithError() throws {
        store = nil
        container = nil
    }

    func testCreateFootprintSavesLocation() throws {
        let timestamp = Date(timeIntervalSince1970: 1_000)
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 35.681, longitude: 139.767),
            altitude: 0,
            horizontalAccuracy: 5,
            verticalAccuracy: 0,
            course: 90,
            speed: 1.5,
            timestamp: timestamp
        )

        try store.createFootprint(title: "route", location: location)

        let footprints = try store.footprints(title: "route")
        XCTAssertEqual(footprints.count, 1)
        let footprint = try XCTUnwrap(footprints.first)
        XCTAssertEqual(footprint.title, "route")
        XCTAssertEqual(footprint.latitude, 35.681)
        XCTAssertEqual(footprint.longitude, 139.767)
        XCTAssertEqual(footprint.accuracy, 5)
        XCTAssertEqual(footprint.speed, 1.5)
        XCTAssertEqual(footprint.direction, 90)
        XCTAssertEqual(footprint.createdAt, timestamp)
    }

    func testCreateFootprintAllowsSameTitle() throws {
        try store.createFootprint(title: "route", location: makeLocation(timestamp: 1))
        try store.createFootprint(title: "route", location: makeLocation(timestamp: 2))

        XCTAssertEqual(try store.footprints(title: "route").count, 2)
    }

    func testExists() throws {
        try store.createFootprint(title: "route", location: makeLocation(timestamp: 1))

        XCTAssertTrue(try store.exists(title: "route"))
        XCTAssertFalse(try store.exists(title: "other"))
    }

    func testFootprintsReturnsOnlyMatchingTitleInCreatedOrder() throws {
        try store.createFootprint(title: "route", location: makeLocation(timestamp: 2))
        try store.createFootprint(title: "other", location: makeLocation(timestamp: 3))
        try store.createFootprint(title: "route", location: makeLocation(timestamp: 1))

        let footprints = try store.footprints(title: "route")

        XCTAssertEqual(footprints.map(\.title), ["route", "route"])
        XCTAssertEqual(
            footprints.map(\.createdAt),
            [Date(timeIntervalSince1970: 1), Date(timeIntervalSince1970: 2)]
        )
    }

    func testRouteSummariesReturnsCountPerTitleInRecentOrder() throws {
        try store.createFootprint(title: "old", location: makeLocation(timestamp: 1))
        try store.createFootprint(title: "old", location: makeLocation(timestamp: 2))
        try store.createFootprint(title: "new", location: makeLocation(timestamp: 3))

        XCTAssertEqual(
            try store.routeSummaries(),
            [
                FootprintRouteSummary(title: "new", count: 1),
                FootprintRouteSummary(title: "old", count: 2),
            ]
        )
    }

    func testRouteSummariesIsEmptyWithoutFootprints() throws {
        XCTAssertEqual(try store.routeSummaries(), [])
    }

    func testDeleteRemovesOnlyMatchingTitle() throws {
        try store.createFootprint(title: "route", location: makeLocation(timestamp: 1))
        try store.createFootprint(title: "route", location: makeLocation(timestamp: 2))
        try store.createFootprint(title: "other", location: makeLocation(timestamp: 3))

        try store.delete(title: "route")

        XCTAssertFalse(try store.exists(title: "route"))
        XCTAssertTrue(try store.footprints(title: "route").isEmpty)
        XCTAssertEqual(try store.footprints(title: "other").count, 1)
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
