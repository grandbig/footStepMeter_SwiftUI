//
//  ContentView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2024/05/04.
//

import SwiftUI

struct ContentView: View {

    /// 位置情報の管理を担う。
    @ObservedObject var manager = LocationManager()

    /// 選択した計測精度。
    @State private var selection = 1
    /// ピッカーの表示/非表示フラグ。
    @State private var isShowingPicker = false
    /// ピッカーの「Done」ボタンがタップされたかどうか。
    @State private var isTappedPickerDoneButton = false
    /// タイトル。
    @State private var title: String = ""

    var body: some View {
        ZStack {
            NavigationStack {
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
            }
            .tint(.black)

            PickerView(selection: $selection, isShowing: $isShowingPicker, isTappedDoneButton: $isTappedPickerDoneButton)
                .animation(.linear, value: isShowingPicker)
                .offset(y: isShowingPicker ? 0 : UIScreen.main.bounds.height)
        }
        .alert("Confirm", isPresented: $isTappedPickerDoneButton, actions: {
            TextField("Title", text: $title)
            Button(action: {
                isTappedPickerDoneButton = false
            }, label: {
                Text("Cancel")
            })
            Button(action: {
                isTappedPickerDoneButton = false
                // TODO: 計測開始処理
            }, label: {
                Text("OK")
            })
        }, message: {
            Text("Please Enter a title")
        })
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

// MARK: - Image

extension Image {

    func setUpToolbarImageStyle(isEnabled: Bool, onTapGesture: @escaping () -> Void) -> some View {
        self.renderingMode(.template)
            .foregroundStyle(isEnabled ? .white : .gray)
            .onTapGesture {
                onTapGesture()
            }
    }
}

// MARK: - Text

extension Text {

    func setUpToolbarTextStyle(isEnabled: Bool, onTapGesture: @escaping () -> Void) -> some View {
        self.font(.footnote)
            .foregroundStyle(isEnabled ? .white : .gray)
            .onTapGesture {
                onTapGesture()
            }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
