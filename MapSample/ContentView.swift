//
//  ContentView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2024/05/04.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var manager = LocationManager()

    var body: some View {
        NavigationStack {
            MapView()
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("main"), for: .navigationBar, .bottomBar)
            .toolbar(.visible, for: .navigationBar, .bottomBar)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    VStack {
                        Image("play")
                        Text("START")
                            .font(.footnote)
                    }
                    Spacer()
                    VStack {
                        Image("stop")
                        Text("STOP")
                            .font(.footnote)
                    }
                    Spacer()
                    VStack {
                        Image("view")
                        Text("FOOT VIEW")
                            .font(.footnote)
                    }
                    Spacer()
                    VStack {
                        Image("settings")
                        Text("SETTINGS")
                            .font(.footnote)
                    }
                }
            }
        }
        .tint(.black)
    }

    init() {
        setUpToolbarBackgroundColor()
    }

    private func setUpToolbarBackgroundColor() {
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color("main"))
        UIToolbar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}
