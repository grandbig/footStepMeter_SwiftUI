//
//  MapView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2024/05/04.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State var position: MapCameraPosition = .userLocation(fallback: .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 35.689247, longitude: 139.812784), distance: 1000)))

    var body: some View {
        Map(initialPosition: position)
            .tint(.blue)
    }
}

#Preview {
    MapView()
}
