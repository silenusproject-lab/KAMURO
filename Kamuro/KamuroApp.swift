//
//  KamuroApp.swift
//  Kamuro
//
//  Created by tsuyoshi nishigaki on 2025/10/15.
//

import SwiftUI

// アプリケーションのエントリーポイント - @mainアトリビュートで指定
// このstructがアプリ全体のライフサイクルを管理する
@main
struct KamuroApp: App {
    // 位置情報マネージャー - GPS位置情報の取得・管理を担当
    // @StateObject: アプリケーション全体で共有される状態オブジェクト
    // 影響範囲: アプリ全体で位置情報を取得・利用可能にする
    // 修正時の注意: このオブジェクトはアプリ起動時に1度だけ初期化される
    @StateObject private var locationManager = LocationManager()

    // 設定マネージャー - アプリの設定（言語設定など）を管理
    // @StateObject: アプリケーション全体で共有される状態オブジェクト
    // 影響範囲: アプリ全体で設定情報を参照・変更可能にする
    // 修正時の注意: このオブジェクトはアプリ起動時に1度だけ初期化される
    @StateObject private var settingsManager = SettingsManager()

    // アプリケーションのシーン構成を定義
    // Scene: アプリの画面やウィンドウを管理する単位
    var body: some Scene {
        // WindowGroup: 標準的なアプリウィンドウを作成
        // iOSでは単一ウィンドウ、iPadOSやmacOSでは複数ウィンドウ対応
        WindowGroup {
            // ルートビューとしてContentViewを表示
            ContentView()
                // locationManagerを環境オブジェクトとして注入
                // 影響範囲: ContentView以下の全ての子ビューでlocationManagerにアクセス可能
                // 使用方法: @EnvironmentObjectでアクセス
                .environmentObject(locationManager)
                // settingsManagerを環境オブジェクトとして注入
                // 影響範囲: ContentView以下の全ての子ビューでsettingsManagerにアクセス可能
                // 使用方法: @EnvironmentObjectでアクセス
                .environmentObject(settingsManager)
                // ビューが表示された時の処理
                .onAppear {
                    // アプリ起動時に位置情報の権限をリクエスト
                    // 影響範囲: ユーザーに位置情報の使用許可ダイアログを表示
                    // 修正時の注意: Info.plistにNSLocationWhenInUseUsageDescriptionが必要
                    locationManager.requestAuthorization()

                    // アプリ起動時に位置情報取得を開始（パフォーマンス最適化）
                    // 影響範囲: 画面表示前から位置情報取得を開始することで、
                    //          地図表示や現在地ボタンの応答速度を向上
                    // 修正時の注意: この処理により、アプリ起動時に位置情報が事前取得される
                    locationManager.startUpdatingLocation()
                }
        }
    }
}
