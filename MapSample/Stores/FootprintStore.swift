//
//  FootprintStore.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/10/03.
//

import CoreLocation
import Foundation
import SwiftData

/// SwiftDataを用いて足跡データを永続化する。
final class FootprintStore: FootprintStoreProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createFootprint(title: String, location: CLLocation) throws {
        let footprint = Footprint(
            title: title,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            accuracy: location.horizontalAccuracy,
            speed: location.speed,
            direction: location.course,
            createdAt: location.timestamp
        )
        modelContext.insert(footprint)
        try modelContext.save()
    }

    func footprints(title: String) throws -> [Footprint] {
        let descriptor = FetchDescriptor<Footprint>(
            predicate: #Predicate { $0.title == title },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return try modelContext.fetch(descriptor)
    }

    func routeSummaries() throws -> [FootprintRouteSummary] {
        let descriptor = FetchDescriptor<Footprint>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let footprints = try modelContext.fetch(descriptor)

        // 直近に記録したタイトルが先頭になるよう、初出順を保ったまま件数を集計する。
        var titles: [String] = []
        var counts: [String: Int] = [:]
        for footprint in footprints {
            if counts[footprint.title] == nil {
                titles.append(footprint.title)
            }
            counts[footprint.title, default: 0] += 1
        }
        return titles.map { FootprintRouteSummary(title: $0, count: counts[$0, default: 0]) }
    }

    func exists(title: String) throws -> Bool {
        let descriptor = FetchDescriptor<Footprint>(
            predicate: #Predicate { $0.title == title }
        )
        return try modelContext.fetchCount(descriptor) > 0
    }

    func delete(title: String) throws {
        try modelContext.delete(
            model: Footprint.self,
            where: #Predicate { $0.title == title }
        )
        try modelContext.save()
    }
}
