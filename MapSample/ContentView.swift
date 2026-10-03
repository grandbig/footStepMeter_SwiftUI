//
//  ContentView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2024/05/04.
//

import SwiftData
import SwiftUI

struct ContentView: View {

    /// 位置情報の管理を担う。
    let manager: LocationManager
    /// 計測中の位置情報を足跡として記録する。
    @ObservedObject var recorder: FootprintRecorder

    /// 選択した計測精度。
    @State private var selection = 1
    /// ピッカーの表示/非表示フラグ。
    @State private var isShowingPicker = false
    /// ピッカーの「Done」ボタンがタップされたかどうか。
    @State private var isTappedPickerDoneButton = false
    /// タイトル。
    @State private var title: String = ""
    /// ツールバーの項目がタップされたかどうか。
    @State private var isTappedItemOnToolbar = false
    /// ツールバーの「STOP」項目がタップされたかどうか。
    @State private var isTappedStopItemOnToolbar = false
    /// ツールバーの「START」項目が有効状態かどうか。
    @State private var isStartItemOnToolbarEnabled = true
    /// エラーアラートの表示フラグ。
    @State private var isShowingErrorAlert = false
    /// エラーアラートに表示するメッセージ。
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            NavigationStack {
                MapView()
                    .navigationTitle(recorder.count > 0 ? String(recorder.count) : "")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color("main"), for: .navigationBar)
                    .toolbar(.visible, for: .navigationBar)
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            VStack {
                                Image("play")
                                    .setUpToolbarImageStyle(isEnabled: .constant(isStartItemOnToolbarEnabled), onTapGesture: { isShowingPicker.toggle() })
                                Text("START")
                                    .setUpToolbarTextStyle(isEnabled: .constant(isStartItemOnToolbarEnabled), onTapGesture: { isShowingPicker.toggle() })
                            }.disabled(!isStartItemOnToolbarEnabled)
                            Spacer()
                            VStack {
                                Image("stop")
                                    .setUpToolbarImageStyle(isEnabled: .constant(!isStartItemOnToolbarEnabled), onTapGesture: { isTappedStopItemOnToolbar.toggle() })
                                Text("STOP")
                                    .setUpToolbarTextStyle(isEnabled: .constant(!isStartItemOnToolbarEnabled), onTapGesture: { isTappedStopItemOnToolbar.toggle() })
                            }.disabled(isStartItemOnToolbarEnabled)
                            Spacer()
                            VStack {
                                Image("view")
                                    .setUpToolbarImageStyle(onTapGesture: {})
                                Text("FOOT VIEW")
                                    .setUpToolbarTextStyle(onTapGesture: {})
                            }
                            Spacer()
                            VStack {
                                Image("settings")
                                    .setUpToolbarImageStyle(onTapGesture: {})
                                Text("SETTINGS")
                                    .setUpToolbarTextStyle(onTapGesture: {})
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
            confirmAlertBeforeStartUpdatingLocations
        }, message: {
            Text("Please Enter a title")
        })
        .alert("Confirm", isPresented: $isTappedStopItemOnToolbar, actions: {
            confirmAlertBeforeStopUpdatingLocations
        }, message: {
            Text("Do you want to stop measuring location information?")
        })
        .alert("Error", isPresented: $isShowingErrorAlert, actions: {
            Button("OK") {}
        }, message: {
            Text(errorMessage)
        })
    }

    init(manager: LocationManager, recorder: FootprintRecorder) {
        self.manager = manager
        self.recorder = recorder
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
    
    /// 位置情報の取得開始前のConfirmアラート。
    private var confirmAlertBeforeStartUpdatingLocations: some View {
        Group {
            TextField("Title", text: $title)
            Button(action: {
                isTappedPickerDoneButton = false
            }, label: {
                Text("Cancel")
            })
            Button(action: {
                isTappedPickerDoneButton = false
                startMeasuring()
            }, label: {
                Text("OK")
            })
        }
    }

    /// 位置情報の取得終了前のConfirmアラート。
    private var confirmAlertBeforeStopUpdatingLocations: some View {
        Group {
            Button(action: {
            }, label: {
                Text("Cancel")
            })
            Button(action: {
                isStartItemOnToolbarEnabled = true
                // 位置情報の計測を終了する
                manager.stopUpdatingLocation()
                recorder.stop()
            }, label: {
                Text("OK")
            })
        }
    }

    /// 足跡の記録と位置情報の計測を開始する。
    /// - Note: タイトルが空、または同名のタイトルが既に存在する場合は、エラーアラートを表示して開始しない
    private func startMeasuring() {
        guard let accuracy = LocationAccuracy(rawValue: selection), accuracy != .none else { return }

        do {
            try recorder.start(title: title)
        } catch let error as FootprintRecorder.StartError {
            showErrorAlert(message: error.message)
            return
        } catch {
            showErrorAlert(message: "An unexpected error occurred.")
            return
        }

        isStartItemOnToolbarEnabled = false
        manager.startUpdateingLocation(accuracy: accuracy)
    }

    /// エラーアラートを表示する。
    /// - Parameter message: 表示するメッセージ
    private func showErrorAlert(message: String) {
        errorMessage = message
        isShowingErrorAlert = true
    }
}

// MARK: - Image

extension Image {
    
    /// Toolbarの項目として設定された画像にスタイルとジェスチャを設定する
    /// - Parameters:
    ///   - isEnabled: 有効状態かどうか
    ///   - onTapGesture: タップ時のジェスチャ
    /// - Returns: スタイルとジェスチャが設定された画像
    func setUpToolbarImageStyle(isEnabled: Binding<Bool>? = nil, onTapGesture: @escaping () -> Void) -> some View {
        self.renderingMode(.template)
            .foregroundStyle(isEnabled?.wrappedValue ?? true ? .white : .gray)
            .onTapGesture {
                onTapGesture()
            }
    }
}

// MARK: - Text

extension Text {
    
    /// Toolbarの項目として設定されたテキストにスタイルとジェスチャを設定する
    /// - Parameters:
    ///   - isEnabled: 有効状態かどうか
    ///   - onTapGesture: タップ時のジェスチャ
    /// - Returns: スタイルとジェスチャが設定されたテキスト
    func setUpToolbarTextStyle(isEnabled: Binding<Bool>? = nil, onTapGesture: @escaping () -> Void) -> some View {
        self.font(.footnote)
            .foregroundStyle(isEnabled?.wrappedValue ?? true ? .white : .gray)
            .onTapGesture {
                onTapGesture()
            }
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(for: Footprint.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let manager = LocationManager()
    let recorder = FootprintRecorder(
        store: FootprintStore(modelContext: container.mainContext),
        locations: manager.locationsPublisher
    )
    return ContentView(manager: manager, recorder: recorder)
        .modelContainer(container)
}

// MARK: - TODO

// 1. Toolbarの「FOOT VIEW」をタップしたら、保存した位置情報を取得してマップにマッピングする
// 2. すでにマッピングされている状態でToolbarの「FOOT VIEW」をタップしたら、マップからマッピング情報を削除する
// 3. Toolbarの「SETTINGS」をタップしたら、設定画面を表示する
// 4. 設定画面の実装（足跡履歴の表示、アプリの利用方法、ライセンスの表示）
