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
        do {
            try modelContext.save()
        } catch {
            // 保存に失敗した足跡がコンテキストに残らないよう取り消す。
            modelContext.delete(footprint)
            throw error
        }
    }

    func footprints(title: String) throws -> [Footprint] {
        let descriptor = FetchDescriptor<Footprint>(
            predicate: predicate(title: title),
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return try modelContext.fetch(descriptor)
    }

    func routeSummaries() throws -> [FootprintRouteSummary] {
        var descriptor = FetchDescriptor<Footprint>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.propertiesToFetch = [\.title]
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
            predicate: predicate(title: title)
        )
        return try modelContext.fetchCount(descriptor) > 0
    }

    func delete(title: String) throws {
        do {
            try modelContext.delete(
                model: Footprint.self,
                where: predicate(title: title)
            )
            try modelContext.save()
        } catch {
            // 保存に失敗した削除がコンテキストに残らないよう取り消す。
            modelContext.rollback()
            throw error
        }
    }

    private func predicate(title: String) -> Predicate<Footprint> {
        #Predicate { $0.title == title }
    }
}
