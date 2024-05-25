//
//  PickerView.swift
//  MapSample
//
//  Created by Takahiro Kato on 2024/05/25.
//

import SwiftUI

/// ピッカー
struct PickerView: View {
    /// 選択した計測精度の値。
    @Binding var selection: Int
    /// ピッカーが表示されている状態かどうか。
    @Binding var isShowing: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            // ピッカーの上部に表示するボタングループ
            HStack {
                // Cancelタップで非表示化 & 選択精度をリセット
                Button {
                    isShowing = false
                    selection = 0
                } label: {
                    Text("Cancel")
                        .tint(.blue)
                }
                .frame(height: 44.0)
                .padding(.horizontal, 16.0)
                Spacer()
                // Doneタップで非表示化
                Button {
                    isShowing = false
                } label: {
                    // TODO: ContentViewにDoneタップを渡す？
                    // ここでタイトル入力のアラートを出す？
                    Text("Done")
                        .tint(.blue)
                }
                .frame(height: 44.0)
                .padding(.horizontal, 16.0)
            }
            .background(Color("backgroundColor"))

            Picker("計測する精度を選択", selection: $selection) {
                ForEach(LocationAccuracy.allCases.filter { $0 != .none }, id: \.self) {
                    Text($0.description)
                }
            }
            // TODO: 文字色が変更できない
            // UISegmentedControl.appearance に設定するしかないかも？
            // https://stackoverflow.com/questions/64068112/swiftui-picker-item-foregroundcolor-not-working
            .background(Color("backgroundColor"))
            .pickerStyle(.wheel)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .labelsHidden()
        }
    }
}

#Preview {
    @State var selection = 0
    @State var isShowing = true

    return PickerView(selection: $selection, isShowing: $isShowing)
}
