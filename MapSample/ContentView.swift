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
    /// FOOT VIEW で地図に表示する足跡を管理する。
    @ObservedObject var viewer: FootprintViewer

    /// 選択した計測精度。
    @State private var selection = 1
    /// ピッカーの表示/非表示フラグ。
    @State private var isShowingPicker = false
    /// ピッカーの「Done」ボタンがタップされたかどうか。
    @State private var isTappedPickerDoneButton = false
    /// タイトル。
    @State private var title: String = ""
    /// 計測中に計測ボタン（停止）がタップされたかどうか。
    @State private var isTappedStopButton = false
    /// エラーアラートの表示フラグ。
    @State private var isShowingErrorAlert = false
    /// エラーアラートに表示するメッセージ。
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            NavigationStack {
                MapView(footprints: viewer.footprints)
                    .overlay(alignment: .bottomTrailing) {
                        floatingActionButtons
                    }
                    .navigationTitle(recorder.count > 0 ? String(recorder.count) : "")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color("main"), for: .navigationBar)
                    .toolbar(.visible, for: .navigationBar)
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
        .alert("Confirm", isPresented: $isTappedStopButton, actions: {
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

    /// 地図の右下に縦に並べる操作ボタン。
    /// - Note: 下が計測の開始/停止、上が FOOT VIEW の表示/非表示
    private var floatingActionButtons: some View {
        VStack(spacing: 16) {
            FloatingActionButton(
                imageName: "view",
                accessibilityLabel: "FOOT VIEW",
                foregroundColor: viewer.isShowing ? .white : Color("main"),
                backgroundColor: viewer.isShowing ? Color("main") : .white,
                diameter: 48,
                action: toggleFootprints
            )
            FloatingActionButton(
                imageName: recorder.isRecording ? "stop" : "play",
                accessibilityLabel: recorder.isRecording ? "STOP" : "START",
                backgroundColor: recorder.isRecording ? .red : Color("main"),
                action: tapMeasureButton
            )
        }
        .padding()
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
                // 位置情報の計測を終了する
                manager.stopUpdatingLocation()
                recorder.stop()
            }, label: {
                Text("OK")
            })
        }
    }

    /// 計測ボタンがタップされたときの処理。
    /// - Note: 計測中でなければ精度のピッカーを、計測中であれば停止の確認アラートを表示する
    private func tapMeasureButton() {
        if recorder.isRecording {
            isTappedStopButton = true
        } else {
            isShowingPicker = true
        }
    }

    /// 足跡の記録と位置情報の計測を開始する。
    /// - Note: 精度が未選択、タイトルが空、または同名のタイトルが既に存在する場合は、エラーアラートを表示して開始しない
    private func startMeasuring() {
        guard let accuracy = LocationAccuracy(rawValue: selection), accuracy != .none else {
            showErrorAlert(message: "Please select the accuracy.")
            return
        }

        do {
            try recorder.start(title: title)
        } catch let error as FootprintRecorder.StartError {
            showErrorAlert(message: error.message)
            return
        } catch {
            showErrorAlert(message: "An unexpected error occurred.")
            return
        }

        // 新しい計測を始めるので、表示中の足跡は消す
        viewer.hide()
        manager.startUpdateingLocation(accuracy: accuracy)
    }

    /// 直近に計測したタイトルの足跡の表示/非表示を切り替える。
    /// - Note: 計測中、または表示する足跡がない場合は、エラーアラートを表示する
    private func toggleFootprints() {
        do {
            try viewer.toggle(title: recorder.title, isRecording: recorder.isRecording)
        } catch let error as FootprintViewer.ShowError {
            showErrorAlert(message: error.message)
        } catch {
            showErrorAlert(message: "An unexpected error occurred.")
        }
    }

    /// エラーアラートを表示する。
    /// - Parameter message: 表示するメッセージ
    private func showErrorAlert(message: String) {
        errorMessage = message
        isShowingErrorAlert = true
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(for: Footprint.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let store = FootprintStore(modelContext: container.mainContext)
    let manager = LocationManager()
    let recorder = FootprintRecorder(store: store, locations: manager.locationsPublisher)
    return ContentView(manager: manager, recorder: recorder, viewer: FootprintViewer(store: store))
        .modelContainer(container)
}
