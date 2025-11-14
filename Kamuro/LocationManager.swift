import Foundation
import CoreLocation
import Combine

// 位置情報を管理するクラス
// CoreLocationフレームワークを使用してGPS位置情報を取得・管理する
// @MainActor: このクラスの全てのプロパティとメソッドはメインスレッドで実行される
// 影響範囲: UI更新に関わる位置情報の更新を安全に行える
@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // CLLocationManagerのインスタンス - CoreLocationの中核となるオブジェクト
    // private: このクラス内でのみアクセス可能
    // 影響範囲: GPS機能の制御（位置情報取得、権限リクエストなど）
    private let manager = CLLocationManager()

    // ユーザーの現在位置
    // @Published: 値が変更されたときに自動的にビューを更新する
    // CLLocation: 緯度・経度・高度・精度などの位置情報を含む
    // 影響範囲: この値が更新されると、位置情報を使用している全てのビューが再描画される
    // 使用箇所: InputFormView（打上地点設定）、MapSearchView（地図の中心位置）
    @Published var userLocation: CLLocation?

    // 位置情報のエラーメッセージ
    // @Published: エラー発生時に自動的にビューを更新する
    // 影響範囲: エラーメッセージを表示するビューに通知される
    // 使用箇所: 位置情報取得失敗時のエラー表示
    @Published var locationError: String?

    // 初期化処理
    // override: NSObjectのinitをオーバーライド
    // 影響範囲: LocationManagerインスタンス作成時に実行される
    override init() {
        super.init()
        // デリゲートを自身に設定 - 位置情報更新イベントを受け取るため
        manager.delegate = self

        // 精度を下げて高速化（100mの精度で十分）
        // kCLLocationAccuracyHundredMeters: 100m精度（バッテリー消費を抑制）
        // 他の選択肢:
        //   - kCLLocationAccuracyBest: 最高精度（数m）だが遅い
        //   - kCLLocationAccuracyKilometer: 1km精度（最も速い）
        // 修正時の注意: 精度を上げるとバッテリー消費と取得時間が増加
        // 影響範囲: 位置情報取得の速度と精度のトレードオフ
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        // バックグラウンドでの更新を無効化
        // true: アプリが非アクティブ時に位置情報更新を自動停止
        // 影響範囲: バッテリー消費を抑制
        // 修正時の注意: falseにするとバックグラウンドでも位置情報を取得し続ける
        manager.pausesLocationUpdatesAutomatically = true
    }

    // 位置情報の権限をリクエスト
    // "使用中のみ許可"の権限をユーザーにリクエストする
    // 影響範囲: 初回実行時にシステムダイアログを表示
    // 修正時の注意: Info.plistにNSLocationWhenInUseUsageDescriptionが必要
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    // 位置情報の更新を開始
    // 継続的に位置情報を取得する（移動に応じて更新）
    // パフォーマンス最適化: 既に位置情報がある場合は更新しない
    // 影響範囲: GPS機能が有効化され、位置情報の更新が開始される
    // 修正時の注意: 条件分岐を削除すると常に位置情報を取得し続ける
    func startUpdatingLocation() {
        // 既に位置情報がある場合は更新しない（高速化）
        // userLocation == nil: 初回取得時のみ実行
        // 影響範囲: 地図表示や現在地ボタンの応答速度向上
        if userLocation == nil {
            manager.startUpdatingLocation()
        }
    }

    // 即座に位置情報を取得（一度だけ）
    // startUpdatingLocationと異なり、1回だけ位置情報を取得して停止
    // 影響範囲: バッテリー消費を最小限に抑えたい場合に使用
    // 使用箇所: 現在地ボタンを押したときなど、一度だけ位置情報が必要な場合
    func requestLocationOnce() {
        manager.requestLocation()
    }

    // 位置情報の更新を停止
    // GPS機能を停止してバッテリー消費を抑制
    // 影響範囲: 位置情報の更新が停止される
    // 使用箇所: 位置情報が不要になったとき（現在は未使用）
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    // 位置情報が更新されたときの処理
    // CLLocationManagerDelegateのデリゲートメソッド
    // nonisolated: このメソッドはバックグラウンドスレッドで呼ばれる可能性がある
    // 影響範囲: 位置情報取得成功時に自動的に呼ばれる
    // 修正時の注意: Task { @MainActor in }でメインスレッドに切り替えている
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // メインスレッドで位置情報を更新
        // Task { @MainActor in }: バックグラウンドスレッドからメインスレッドへの切り替え
        // 影響範囲: UI更新を安全に行うためのスレッド管理
        Task { @MainActor in
            // 最新の位置情報を保存
            // locations.last: 配列の最後の要素（最新の位置情報）
            // 影響範囲: userLocationが更新され、@Publishedにより全ての監視ビューが更新される
            userLocation = locations.last
        }
    }

    // 位置情報の取得に失敗したときの処理
    // CLLocationManagerDelegateのデリゲートメソッド
    // nonisolated: このメソッドはバックグラウンドスレッドで呼ばれる可能性がある
    // 影響範囲: 位置情報取得失敗時に自動的に呼ばれる
    // 失敗理由: GPS無効、権限拒否、ネットワークエラーなど
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // メインスレッドでエラーメッセージを更新
        Task { @MainActor in
            // エラーメッセージをローカライズされた文字列で保存
            // error.localizedDescription: システムが提供するエラーメッセージ
            // 影響範囲: locationErrorが更新され、エラー表示ビューに通知される
            locationError = error.localizedDescription
        }
    }

    // 位置情報の権限状態が変更されたときの処理
    // CLLocationManagerDelegateのデリゲートメソッド
    // nonisolated: このメソッドはバックグラウンドスレッドで呼ばれる可能性がある
    // 影響範囲: ユーザーが権限設定を変更したときに自動的に呼ばれる
    // タイミング: アプリ起動時、設定アプリで権限変更時
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // メインスレッドで権限状態に応じた処理を実行
        Task { @MainActor in
            // 権限状態による分岐処理
            switch manager.authorizationStatus {
            // 位置情報の使用が許可されている場合
            case .authorizedWhenInUse, .authorizedAlways:
                // 位置情報の取得を開始
                // 影響範囲: GPS機能が有効化される
                self.startUpdatingLocation()

            // 位置情報の使用が拒否または制限されている場合
            case .denied, .restricted:
                // エラーメッセージを設定
                // 影響範囲: ユーザーにエラーメッセージを表示
                // 修正時の注意: メッセージは多言語対応が必要な場合、LocalizationManagerを使用
                self.locationError = "位置情報の利用が許可されていません"

            // 権限がまだリクエストされていない場合
            case .notDetermined:
                // 権限をリクエスト
                // 影響範囲: システムダイアログを表示
                self.requestAuthorization()

            // 将来追加される可能性のある権限状態に対応
            @unknown default:
                // 何もしない
                break
            }
        }
    }
}
