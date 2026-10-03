//
//  MapView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2024/05/04.
//

import SwiftUI
import MapKit

/// マップ。
struct MapView: View {

    /// 表示する足跡。
    var footprints: [Footprint] = []

    /// マップに対するカメラ位置。
    @State var position: MapCameraPosition = .userLocation(fallback: .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 35.689247, longitude: 139.812784), distance: 1000)))
    /// 詳細を表示している足跡のID。
    @State private var selectedFootprintID: UUID?

    var body: some View {
        Map(initialPosition: position) {
            ForEach(footprints, id: \.id) { footprint in
                Annotation(footprint.coordinateText, coordinate: footprint.coordinate) {
                    FootprintAnnotationView(footprint: footprint, isSelected: selectedFootprintID == footprint.id)
                        .onTapGesture {
                            selectedFootprintID = selectedFootprintID == footprint.id ? nil : footprint.id
                        }
                }
                .annotationTitles(.hidden)
            }
        }
        .tint(.blue)
    }
}

/// 地図上の足跡。
private struct FootprintAnnotationView: View {

    /// 表示する足跡。
    let footprint: Footprint
    /// 詳細を表示するかどうか。
    let isSelected: Bool

    var body: some View {
        Image("footprint")
            // 方角が取得できなかった場合（負の値）は回転させない
            .rotationEffect(.degrees(max(footprint.direction, 0)))
            .overlay(alignment: .bottom) {
                if isSelected {
                    VStack(spacing: 2) {
                        Text(footprint.coordinateText)
                        Text(verbatim: "accuracy: \(footprint.accuracy)")
                    }
                    .font(.caption)
                    .padding(6)
                    .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 2)
                    .fixedSize()
                    .offset(y: -40)
                }
            }
    }
}

// MARK: - Footprint

private extension Footprint {

    /// 座標。
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// 小数点以下6桁で表した座標の文字列。
    var coordinateText: String {
        String(format: "%.6f, %.6f", latitude, longitude)
    }
}

#Preview {
    MapView()
}
