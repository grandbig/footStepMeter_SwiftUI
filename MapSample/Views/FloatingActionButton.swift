//
//  FloatingActionButton.swift
//  MapSample
//
//  Created by Takahiro Kato on 2026/10/04.
//

import SwiftUI

/// 地図の上に浮かべて表示する円形のボタン。
struct FloatingActionButton: View {

    /// ボタンに表示する画像（アセット名）。
    let imageName: String
    /// VoiceOver などで読み上げるラベル。
    let accessibilityLabel: String
    /// 画像の色。
    var foregroundColor: Color = .white
    /// 背景色。
    var backgroundColor: Color = Color("main")
    /// ボタンの直径。
    var diameter: CGFloat = 64
    /// タップ時の処理。
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(imageName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: diameter * 0.4, height: diameter * 0.4)
                .foregroundStyle(foregroundColor)
                .frame(width: diameter, height: diameter)
                .background(backgroundColor, in: Circle())
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        FloatingActionButton(imageName: "view", accessibilityLabel: "FOOT VIEW", foregroundColor: Color("main"), backgroundColor: .white, diameter: 48) {}
        FloatingActionButton(imageName: "play", accessibilityLabel: "START") {}
        FloatingActionButton(imageName: "stop", accessibilityLabel: "STOP", backgroundColor: .red) {}
    }
    .padding()
}
