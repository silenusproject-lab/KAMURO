import SwiftUI
import Social
import StoreKit

// 設定画面ビュー
// アプリの設定（言語、情報表示、シェア、評価）を一元管理する画面
// 使用箇所: InputFormViewの設定ボタンから表示
struct SettingsView: View {
    // 設定マネージャー - InputFormViewから環境オブジェクトとして注入される
    // 影響範囲: 言語設定の管理、ローカライズ文字列の取得
    // 使用箇所: 言語Picker、全てのテキスト表示
    @EnvironmentObject var settingsManager: SettingsManager

    // 画面を閉じるためのアクション - SwiftUI環境変数
    // 影響範囲: 閉じるボタンで画面を閉じる
    @Environment(\.dismiss) private var dismiss

    // ビューの本体部分を定義
    var body: some View {
        // NavigationStack: iOS 16以降の新しいナビゲーション方式
        // 影響範囲: 子画面（バージョン情報、アプリについて）への遷移を管理
        // 修正時の注意: NavigationStackはNavigationViewより推奨（iOS 16+）
        NavigationStack {
            // Form: 設定画面用の標準的なリストUIを提供
            // 影響範囲: iOS標準の設定画面のような見た目を実現
            Form {
                // 言語設定セクション - アプリ表示言語の選択
                // 現在: 日本語、英語の2言語対応（将来14言語まで拡張予定）
                // 影響範囲: 選択した言語でアプリ全体のテキストが変更される
                Section {
                    // セクションヘッダー - 地球儀アイコンと「言語」ラベル
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                        Text(localizedString("language"))
                            .fontWeight(.medium)
                    }

                    // 言語選択Picker - ドロップダウンメニュー形式
                    // selection: 現在選択されている言語とバインディング
                    // 影響範囲: 言語変更時にアプリ全体のテキストが即座に更新される
                    // 修正時の注意: LocalizationManagerで対応言語を追加する必要がある
                    Picker(localizedString("language"), selection: $settingsManager.localizationManager.currentLanguage) {
                        // 対応言語を全てリスト表示
                        // allCases: LocalizationManager.Languageの全ケースを取得
                        // 影響範囲: 新しい言語を追加するとここに自動的に表示される
                        ForEach(LocalizationManager.Language.allCases, id: \.self) { language in
                            // 言語のネイティブ表示名（例: 日本語、English）
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    // 言語変更時の処理
                    // onChange: currentLanguageが変更されたときに呼ばれる
                    // 影響範囲: 設定をUserDefaultsに保存
                    .onChange(of: settingsManager.localizationManager.currentLanguage) { _, _ in
                        settingsManager.saveSettings()
                    }
                }

                // 情報セクション - バージョン情報とアプリの説明を表示
                // 影響範囲: VersionInfoViewとAboutAppViewへの遷移
                Section {
                    // セクションヘッダー - 情報アイコンと「情報」ラベル
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.green)
                        Text(localizedString("information"))
                            .fontWeight(.medium)
                    }

                    // バージョン情報画面へのナビゲーションリンク
                    // 影響範囲: タップでVersionInfoViewを表示
                    NavigationLink {
                        VersionInfoView()
                            .environmentObject(settingsManager)
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                            Text(localizedString("version_info"))
                        }
                    }

                    // アプリについて画面へのナビゲーションリンク
                    // 影響範囲: タップでAboutAppView（仕様、注意事項など）を表示
                    NavigationLink {
                        AboutAppView()
                            .environmentObject(settingsManager)
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text(localizedString("about_app"))
                        }
                    }
                }

                // シェアセクション - SNSへのアプリ共有機能
                // 対応: X (Twitter)、note、LINE
                // 影響範囲: アプリの宣伝・共有をサポート
                Section {
                    // セクションヘッダー - シェアアイコンと「シェア」ラベル
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.purple)
                        Text(localizedString("share"))
                            .fontWeight(.medium)
                    }

                    // Xシェアボタン
                    // 影響範囲: タップでX (Twitter)アプリまたはWebへ遷移
                    // 動作: Xアプリがあれば起動、なければWeb版を開く
                    Button(action: shareToX) {
                        HStack {
                            Image(systemName: "x.square.fill")
                            Text("X (Twitter)")
                        }
                    }

                    // noteシェアボタン
                    // 影響範囲: タップでnoteアプリまたはWebへ遷移
                    // 動作: noteアプリがあれば起動、なければWeb版を開く
                    Button(action: shareToNote) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("note")
                        }
                    }

                    // LINEシェアボタン
                    // 影響範囲: タップでLINEアプリでシェア
                    // 動作: LINEアプリがあればシェア画面を開く、なければ汎用シェアシート
                    Button(action: shareToLINE) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("LINE")
                        }
                    }
                }

                // アプリ評価セクション - App Storeでの評価をリクエスト
                // 影響範囲: タップでApp Storeの評価ダイアログを表示
                // 修正時の注意: iOS 18以降はAppStore.requestReview、それ以前はSKStoreReviewController
                Section {
                    Button(action: rateApp) {
                        HStack {
                            // 星アイコン
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(localizedString("rate_app"))
                                .fontWeight(.medium)
                            Spacer()
                            // 右矢印（遷移を示す）
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            // ナビゲーションバーのタイトル設定
            .navigationTitle(localizedString("settings"))
            // タイトル表示モード: large（大きいタイトル、スクロールで小さくなる）
            .navigationBarTitleDisplayMode(.large)
            // ツールバー設定 - ナビゲーションバーにボタンを追加
            .toolbar {
                // 右上に閉じるボタンを配置
                ToolbarItem(placement: .navigationBarTrailing) {
                    // 閉じるボタン - InputFormViewに戻る
                    Button(localizedString("close")) {
                        dismiss()
                    }
                }
            }
        }
    }

    // ローカライズされた文字列を取得する関数
    // settingsManager.localizationManagerから多言語対応文字列を取得
    // 引数: key - ローカライゼーションキー（例: "settings"）
    // 戻り値: 現在の言語設定に応じた文字列
    // 影響範囲: ビュー内の全てのテキスト表示に使用
    // 修正時の注意: キーが存在しない場合はキー名がそのまま表示される
    private func localizedString(_ key: String) -> String {
        return settingsManager.localizationManager.localizedString(for: key)
    }

    // Xシェア機能 - X (Twitter)へアプリ情報をシェア
    // 影響範囲: Xアプリまたはブラウザでシェア画面を開く
    // 動作フロー:
    //   1. Xアプリがインストール済みなら、アプリ内でシェア投稿画面を開く
    //   2. なければブラウザでX Web版のシェア画面を開く
    // 修正時の注意: share_textキーの内容がツイート本文になる
    private func shareToX() {
        let text = localizedString("share_text")
        if let url = URL(string: "twitter://post?message=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                if let webURL = URL(string: "https://twitter.com/intent/tweet?text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                    UIApplication.shared.open(webURL)
                }
            }
        }
    }

    // noteシェア機能
    private func shareToNote() {
        if let url = URL(string: "note://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                if let webURL = URL(string: "https://note.com/") {
                    UIApplication.shared.open(webURL)
                }
            }
        }
    }

    // LINEシェア機能
    private func shareToLINE() {
        let text = localizedString("share_text")
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://line.me/R/msg/text/?\(encodedText)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                shareGeneric(text: text)
            }
        }
    }

    // 汎用シェア機能
    private func shareGeneric(text: String) {
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }

    // アプリ評価リクエスト
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}

// バージョン情報表示ビュー
struct VersionInfoView: View {
    @EnvironmentObject var settingsManager: SettingsManager

    var body: some View {
        Form {
            Section {
                HStack {
                    Image("Image")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.orange)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("KAMURO")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(localizedString("version"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle(localizedString("version_info"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func localizedString(_ key: String) -> String {
        return settingsManager.localizationManager.localizedString(for: key)
    }
}

// アプリについて表示ビュー
struct AboutAppView: View {
    @EnvironmentObject var settingsManager: SettingsManager

    var body: some View {
        Form {
            // アプリ説明セクション - 最初に表示
            Section {
                Text(localizedString("app_description"))
                    .font(.body)
            }

            // 仕様セクション
            Section(localizedString("specification")) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "function")
                            .foregroundColor(.blue)
                        Text(localizedString("sound_speed_info"))
                            .fontWeight(.medium)
                    }

                    Text(localizedString("sound_speed_desc"))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.green)
                        Text(localizedString("location_info"))
                            .fontWeight(.medium)
                    }

                    Text(localizedString("location_desc"))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }

            // 注意事項セクション
            Section(localizedString("notice_title")) {
                VStack(alignment: .leading, spacing: 8) {
                    Label(localizedString("gps_accuracy"), systemImage: "exclamationmark.triangle")
                        .foregroundColor(.orange)

                    Label(localizedString("network_requirement"), systemImage: "wifi.exclamationmark")
                        .foregroundColor(.orange)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(localizedString("about_app"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func localizedString(_ key: String) -> String {
        return settingsManager.localizationManager.localizedString(for: key)
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
}
