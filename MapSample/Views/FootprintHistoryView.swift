//
//  FootprintHistoryView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/11/12.
//

import SwiftData
import SwiftUI

/// 足跡履歴一覧画面。保存済みの足跡をタイトルごとに件数付きで表示し、選んだタイトルの履歴マップへ遷移する。
struct FootprintHistoryView: View {

    /// 一覧に表示する足跡のサマリを管理する。
    @ObservedObject var history: FootprintHistory

    /// エラーアラートの表示フラグ。
    @State private var isShowingErrorAlert = false

    var body: some View {
        Group {
            if history.summaries.isEmpty {
                ContentUnavailableView(
                    "No Footprints",
                    systemImage: "shoeprints.fill",
                    description: Text("Measured footprints will appear here.")
                )
            } else {
                List(history.summaries) { summary in
                    NavigationLink {
                        FootprintHistoryMapView(title: summary.title, history: history)
                    } label: {
                        FootprintHistoryRow(summary: summary)
                    }
                }
            }
        }
        .navigationTitle("FOOTPRINT HISTORY")
        .mainNavigationBarStyle()
        // 計測は地図のタブで進むため、表示するたびに最新の内容を読み込む
        .onAppear(perform: reload)
        .alert("Error", isPresented: $isShowingErrorAlert, actions: {
            Button("OK") {}
        }, message: {
            Text("Failed to load the footprint history.")
        })
    }

    /// 保存済みの足跡を読み込み直す。
    /// - Note: 読み込みに失敗した場合は、エラーアラートを表示する
    private func reload() {
        do {
            try history.reload()
        } catch {
            isShowingErrorAlert = true
        }
    }
}

/// 足跡履歴一覧の1行。
private struct FootprintHistoryRow: View {

    /// 表示するサマリ。
    let summary: FootprintRouteSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(summary.title)
            Text("count: \(summary.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(for: Footprint.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let store = FootprintStore(modelContext: container.mainContext)
    return NavigationStack {
        FootprintHistoryView(history: FootprintHistory(store: store))
    }
    .modelContainer(container)
}
