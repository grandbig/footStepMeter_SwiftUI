//
//  ContentView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2024/05/04.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var manager = LocationManager()

    /// 選択した計測精度。
    @State private var selection = 1
    /// ピッカーの表示/非表示フラグ。
    @State private var isShowingPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                MapView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color("main"), for: .navigationBar)
                    .toolbar(.visible, for: .navigationBar)
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            VStack {
                                Image("play")
                                    .setUpToolbarImageStyle(isEnabled: true, onTapGesture: { isShowingPicker.toggle() })
                                Text("START")
                                    .setUpToolbarTextStyle(isEnabled: true, onTapGesture: { isShowingPicker.toggle() })
                            }
                            Spacer()
                            VStack {
                                Image("stop")
                                    .setUpToolbarImageStyle(isEnabled: false, onTapGesture: {})
                                Text("STOP")
                                    .setUpToolbarTextStyle(isEnabled: false, onTapGesture: {})
                            }
                            Spacer()
                            VStack {
                                Image("view")
                                    .setUpToolbarImageStyle(isEnabled: true, onTapGesture: {})
                                Text("FOOT VIEW")
                                    .setUpToolbarTextStyle(isEnabled: true, onTapGesture: {})
                            }
                            Spacer()
                            VStack {
                                Image("settings")
                                    .setUpToolbarImageStyle(isEnabled: true, onTapGesture: {})
                                Text("SETTINGS")
                                    .setUpToolbarTextStyle(isEnabled: true, onTapGesture: {})
                            }
                        }
                    }

                PickerView(selection: $selection, isShowing: $isShowingPicker)
                    .animation(.linear, value: isShowingPicker)
                    .offset(y: isShowingPicker ? 0 : UIScreen.main.bounds.height)
            }
        }
        .tint(.black)
    }

    init() {
        setUpToolbarBackgroundColor()
    }
    
    /// UIToolbarの背景色を設定する。
    /// - Note: toolbarBackground では「.bottomBar」を指定しても背景色を変更できないため、この処理を実行する
    private func setUpToolbarBackgroundColor() {
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color("main"))
        UIToolbar.appearance().scrollEdgeAppearance = appearance
    }
}

extension Image {

    func setUpToolbarImageStyle(isEnabled: Bool, onTapGesture: @escaping () -> Void) -> some View {
        self.renderingMode(.template)
            .foregroundStyle(isEnabled ? .white : .gray)
            .onTapGesture {
                onTapGesture()
            }
    }
}

extension Text {

    func setUpToolbarTextStyle(isEnabled: Bool, onTapGesture: @escaping () -> Void) -> some View {
        self.font(.footnote)
            .foregroundStyle(isEnabled ? .white : .gray)
            .onTapGesture {
                onTapGesture()
            }
    }
}

#Preview {
    ContentView()
}
