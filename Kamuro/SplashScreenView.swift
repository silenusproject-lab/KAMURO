import SwiftUI

// スプラッシュスクリーン（起動画面）のビュー
// アプリ起動時に表示され、0.7秒後にメイン画面へ自動遷移する
// デザイン: SENRINアプリのスプラッシュスクリーンを参考に実装
struct SplashScreenView: View {
    // 画面の表示状態を管理する変数
    // @State: このビュー内でのみ使用される状態変数
    // true: メイン画面を表示、false: スプラッシュ画面を表示
    // 影響範囲: スプラッシュ画面とメイン画面の切り替えを制御
    @State private var isActive = false

    // 位置情報マネージャー - ContentViewから環境オブジェクトとして注入される
    // 影響範囲: メイン画面（InputFormView）で位置情報を使用可能にする
    @EnvironmentObject var locationManager: LocationManager

    // 設定マネージャー - ContentViewから環境オブジェクトとして注入される
    // 影響範囲: メイン画面（InputFormView）で設定情報を使用可能にする
    @EnvironmentObject var settingsManager: SettingsManager

    // ビューの本体部分を定義
    var body: some View {
        // 条件分岐によるビュー切り替えのグループ化
        Group {
            // isActiveがtrueの場合 - スプラッシュ期間終了後（0.7秒経過後）
            if isActive {
                // メイン画面へ遷移
                // NavigationView: ナビゲーション機能を提供（画面遷移、ツールバーなど）
                // 影響範囲: InputFormView以下で画面遷移やナビゲーションバーを使用可能
                NavigationView {
                    // 入力フォーム画面を表示 - アプリのメイン機能
                    InputFormView()
                        // 環境オブジェクトを子ビューに渡す
                        .environmentObject(locationManager)
                        .environmentObject(settingsManager)
                }
            } else {
                // スプラッシュ画面を表示 - アプリ起動直後の0.7秒間
                // VStack: 垂直方向のスタックレイアウト（縦方向に要素を配置）
                VStack {
                    // 上部の余白を作成 - ロゴを中央やや上寄りに配置するため
                    Spacer()

                    // アプリのロゴ画像を表示
                    // 画像名: "AppLogo"
                    // アセット: Assets.xcassets/AppLogo.imageset/
                    // 修正時の注意: ロゴ画像を変更する場合は、以下のファイルを配置
                    //   - AppLogo.png (1x)
                    //   - AppLogo@2x.png (2x)
                    //   - AppLogo@3x.png (3x)
                    Image("Image")
                        // 画像のリサイズを有効化
                        .resizable()
                        // アスペクト比を維持してフィット
                        .scaledToFit()
                        // ロゴサイズを150x150に固定
                        // 修正時の注意: サイズ変更時はアプリ名テキストとのバランスを考慮
                        .frame(width: 150, height: 150)
                        // ロゴ下部に10ポイントの余白
                        // 修正時の注意: アプリ名との間隔調整に影響
                        .padding(.bottom, 10)

                    // アプリ名テキストを表示
                    // 修正時の注意: "KAMURO"を変更する場合はアプリ全体の名称変更が必要
                    Text("KAMURO")
                        // フォントスタイル設定: サイズ24、中太字、丸みのあるデザイン
                        // 修正時の注意: サイズ変更時はロゴサイズとのバランスを考慮
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        // 文字色をシステム標準色に設定
                        // 影響範囲: ライト/ダークモード自動対応（白背景では黒、黒背景では白）
                        .foregroundColor(.primary)
                        // 文字間隔を2ポイント広げる - 視認性向上のため
                        // 修正時の注意: 間隔変更時は全体的な見た目への影響を確認
                        .tracking(2)

                    // 中央の余白を作成
                    Spacer()
                    // 追加の下部余白 - 全体を上寄せ気味に配置するため
                    // 修正時の注意: 削除すると中央配置になる
                    Spacer()
                }
                // フレームサイズを画面全体に設定
                // 影響範囲: スプラッシュ画面が画面全体を覆う
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // 背景色をシステム標準背景色に設定
                // 影響範囲: ライト/ダークモード自動対応（ライトモードでは白、ダークモードでは黒）
                .background(Color(.systemBackground))
                // セーフエリアを無視して画面全体に表示
                // 影響範囲: ノッチやホームバー領域まで背景が表示される
                .ignoresSafeArea()
            }
        }
        // ビューが表示された時の処理
        .onAppear {
            // 0.7秒後に画面切り替えを実行
            // DispatchQueue.main.asyncAfter: メインスレッドで遅延実行
            // 修正時の注意: 秒数変更時はユーザー体験への影響を考慮
            //   - 短すぎる: ロゴが見づらい
            //   - 長すぎる: アプリ起動が遅く感じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                // アニメーション付きで状態を変更
                // withAnimation: 画面遷移をスムーズにする
                // 影響範囲: フェードイン/フェードアウト効果で画面が切り替わる
                withAnimation {
                    // メイン画面への切り替えフラグを設定
                    isActive = true
                }
            }
        }
    }
}
