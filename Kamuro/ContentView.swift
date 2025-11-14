//
//  ContentView.swift
//  Kamuro
//
//  Created by tsuyoshi nishigaki on 2025/10/15.
//

import SwiftUI

// アプリケーションのメインコンテンツビュー
// KamuroAppから呼び出される最初のビュー
struct ContentView: View {
    // 位置情報マネージャー - KamuroAppから環境オブジェクトとして注入される
    // @EnvironmentObject: 親ビューから受け取る共有オブジェクト
    // 影響範囲: このビュー以下の全ての子ビューで使用可能
    @EnvironmentObject var locationManager: LocationManager

    // 設定マネージャー - KamuroAppから環境オブジェクトとして注入される
    // @EnvironmentObject: 親ビューから受け取る共有オブジェクト
    // 影響範囲: このビュー以下の全ての子ビューで使用可能
    @EnvironmentObject var settingsManager: SettingsManager

    // ビューの本体部分を定義
    var body: some View {
        // スプラッシュスクリーンビューを表示
        // アプリ起動時に0.7秒間ロゴを表示し、その後メイン画面へ遷移
        // 影響範囲: アプリ起動時の最初の画面表示とメイン画面への遷移
        SplashScreenView()
            // 環境オブジェクトを子ビューに渡す
            .environmentObject(locationManager)
            .environmentObject(settingsManager)
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
        .environmentObject(SettingsManager())
}
