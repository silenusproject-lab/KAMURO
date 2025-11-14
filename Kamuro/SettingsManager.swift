import Foundation
import Combine

// アプリ全体の設定を管理するクラス
// ObservableObject: Combineフレームワークのプロトコル、状態変更を監視可能にする
// 影響範囲: アプリ全体で設定情報を共有・管理
// 使用箇所: 言語設定、アプリの各種設定を一元管理
class SettingsManager: ObservableObject {
    // 多言語対応マネージャー
    // @Published: 値が変更されたときに自動的にビューを更新する
    // LocalizationManager: 言語設定とローカライズされた文字列を管理
    // 影響範囲: アプリ全体の表示言語を制御
    // 使用箇所: InputFormView, SettingsView, MapSearchView, ResultMapViewなど全ての画面
    @Published var localizationManager = LocalizationManager()

    // 初期化処理
    // 影響範囲: SettingsManagerインスタンス作成時に実行される
    // タイミング: KamuroApp起動時に1度だけ実行
    init() {
        // 保存されている設定を読み込む
        loadSettings()
    }

    // 設定を読み込む
    // UserDefaultsから保存された設定を読み込む
    // 影響範囲: 前回の設定（言語など）を復元
    // 修正時の注意: 将来的に設定項目が増えた場合、ここに読み込み処理を追加
    func loadSettings() {
        // LocalizationManagerが自動的にUserDefaultsから言語設定を読み込む
        // LocalizationManager.init()内でUserDefaultsから言語設定を取得している
        // 現在は明示的な処理は不要だが、将来の拡張性のためメソッドを用意
    }

    // 設定を保存する
    // 現在の設定をUserDefaultsに保存
    // 影響範囲: 設定を永続化し、次回起動時に復元可能にする
    // 修正時の注意: 将来的に設定項目が増えた場合、ここに保存処理を追加
    func saveSettings() {
        // LocalizationManagerが自動的にUserDefaultsに言語設定を保存する
        // LocalizationManager.currentLanguageのsetterでUserDefaultsに保存している
        // 現在は明示的な処理は不要だが、将来の拡張性のためメソッドを用意
    }
}
