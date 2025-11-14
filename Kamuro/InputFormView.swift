import SwiftUI
import CoreLocation
import MapKit

// メイン操作画面 - 打上地点、時間差、気温を入力して距離を計算
// このビューはアプリの中核機能を提供し、花火の打上地点から観測者までの距離を計算する
// 計算原理: 音速（331.5 + 0.6 × 気温）× 時間差 = 距離
struct InputFormView: View {
    // 位置情報マネージャー - KamuroAppから環境オブジェクトとして注入される
    // 影響範囲: ユーザーの現在位置を取得し、「現在地を使用」ボタンで利用
    // 使用箇所: 現在地使用ボタン、位置情報エラー表示
    @EnvironmentObject var locationManager: LocationManager

    // 設定マネージャー - KamuroAppから環境オブジェクトとして注入される
    // 影響範囲: 多言語対応（日本語/英語）、設定画面の表示
    // 使用箇所: 全てのテキスト表示、設定画面遷移
    @EnvironmentObject var settingsManager: SettingsManager

    // 打上地点座標 - ユーザーが選択した花火の打上位置
    // @State: このビュー内で管理される状態変数
    // CLLocationCoordinate2D: 緯度・経度を持つ座標型
    // 影響範囲: 距離計算、結果表示画面、地図表示の基準点
    // 修正時の注意: nilの場合は計算ボタンが無効化される
    @State private var launchCoordinate: CLLocationCoordinate2D?

    // 時間差（秒） - 花火が見えてから音が聞こえるまでの時間
    // @State: ユーザー入力を管理する状態変数
    // String型: テキストフィールド入力のため文字列で管理（計算時にDoubleに変換）
    // 影響範囲: 距離計算の主要パラメータ
    // 修正時の注意: 空文字列または数値以外の場合は計算ボタンが無効化される
    @State private var timeLag: String = ""

    // 気温（℃） - 現在の気温（音速計算に使用）
    // @State: ユーザー入力を管理する状態変数
    // String型: テキストフィールド入力のため文字列で管理（計算時にDoubleに変換）
    // 影響範囲: 音速計算（331.5 + 0.6 × 気温）に使用
    // 修正時の注意: デフォルト値は"15"（一般的な外気温）
    // 重要: 気温により音速が変化するため、正確な測定には重要なパラメータ
    @State private var temperature: String = ""

    // 計算結果の距離（メートル） - 打上地点から観測者までの距離
    // @State: 計算後に結果を保持する状態変数
    // Double?: 計算前はnil、計算後は実数値を保持
    // 影響範囲: 結果表示セクション、結果地図画面
    // 修正時の注意: nilの場合は結果セクションが非表示になる
    @State private var calculatedDistance: Double?

    // 地図選択画面の表示状態 - MapSearchViewのシート表示を制御
    // @State: シートの表示/非表示を管理するブール値
    // 影響範囲: 「地図で選択」ボタンのアクション、シート表示制御
    // 修正時の注意: trueになるとMapSearchViewがシートとして表示される
    @State private var showLaunchMap = false

    // 設定画面の表示状態 - SettingsViewのシート表示を制御
    // @State: シートの表示/非表示を管理するブール値
    // 影響範囲: ナビゲーションバーの設定ボタン、シート表示制御
    // 修正時の注意: trueになるとSettingsViewがシートとして表示される
    @State private var showSettings = false

    // 結果表示画面の表示状態 - ResultMapViewのシート表示を制御
    // @State: シートの表示/非表示を管理するブール値
    // 影響範囲: 計算完了後の結果地図表示
    // 修正時の注意: trueになるとResultMapViewがシートとして表示される
    @State private var showResult = false

    // ビューの本体部分を定義
    // Form: iOS標準のフォームレイアウト（設定画面風のUIを提供）
    var body: some View {
        Form {
            // 打上地点セクション - 花火の打上位置を設定
            // 2つの選択方法を提供: 1) 地図で選択、2) 現在地を使用
            // 影響範囲: 選択された座標が距離計算と結果表示に使用される
            Section {
                // セクションヘッダー - 炎アイコンで打上地点を視覚的に表現
                HStack {
                    // 打上地点を表す炎アイコン
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    // セクションタイトル（多言語対応）
                    Text(localizedString("launch_point"))
                        .fontWeight(.medium)
                }

                // 地図選択ボタン - MapSearchViewを表示して地図上で位置を選択
                // 影響範囲: showLaunchMapをtrueにしてシートを表示
                // 使用箇所: 打上地点が事前に分かっている場合、地図で正確に指定
                Button(action: { showLaunchMap = true }) {
                    HStack {
                        Image(systemName: "map")
                        Text(localizedString("select_on_map"))
                    }
                }

                // 現在地使用ボタン - ユーザーの現在位置を打上地点として設定
                // 影響範囲: locationManager.userLocationからlaunchCoordinateに座標をコピー
                // 使用箇所: 打上地点の近くにいる場合、素早く位置を設定
                // 修正時の注意: locationManager.userLocationがnilの場合は何もしない
                Button(action: {
                    if let location = locationManager.userLocation {
                        launchCoordinate = location.coordinate
                    }
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text(localizedString("use_current_location"))
                    }
                }

                // 選択された座標の表示 - 緯度・経度を小さいフォントで表示
                // 条件分岐: 座標が選択されている場合は緯度経度を表示、未選択の場合は「未選択」を表示
                // 影響範囲: ユーザーに現在の選択状態を視覚的に確認させる
                if let coord = launchCoordinate {
                    // 緯度・経度を縦に並べて表示
                    VStack(alignment: .leading, spacing: 4) {
                        // 緯度表示（例: 緯度: 35.6812）
                        Text(String(format: localizedString("latitude_format"), coord.latitude))
                        // 経度表示（例: 経度: 139.7671）
                        Text(String(format: localizedString("longitude_format"), coord.longitude))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                } else {
                    // 未選択時のメッセージ表示
                    Text(localizedString("not_selected"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 時間差・気温入力セクション - 距離計算に必要なパラメータを入力
            // 時間差: 花火が見えてから音が聞こえるまでの時間（秒）
            // 気温: 現在の気温（音速計算に使用）
            // 影響範囲: 両方の値が正しく入力されると計算ボタンが有効化される
            Section {
                // セクションヘッダー - 時計アイコンで時間関連の入力を表現
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                    Text(localizedString("time_difference"))
                        .fontWeight(.medium)
                }

                // タイムラグ入力フィールド - 秒単位で小数点入力可能
                // HStack: ラベルと入力フィールドを左右に配置
                HStack {
                    // 左側のラベル（例: 時間差 (秒)）
                    Text(localizedString("time_lag_seconds"))
                    Spacer()
                    // 右側の入力フィールド
                    // キーボードタイプ: decimalPad（数値と小数点のみ）
                    // プレースホルダー: "0.0"
                    // 幅: 100ポイント固定
                    // 影響範囲: 入力値は計算時にDouble型に変換される
                    // 修正時の注意: 数値以外の入力は計算時にエラーとなる
                    TextField("0.0", text: $timeLag)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }

                // 気温入力フィールド - 摂氏温度を整数または小数で入力
                // HStack: ラベルと入力フィールドを左右に配置
                HStack {
                    // 左側のラベル（例: 気温 (℃)）
                    Text(localizedString("temperature_celsius"))
                    Spacer()
                    // 右側の入力フィールド
                    // キーボードタイプ: decimalPad（数値と小数点のみ）
                    // デフォルト値: "15"（一般的な外気温）
                    // 幅: 100ポイント固定
                    // 影響範囲: 音速計算式（331.5 + 0.6 × 気温）に使用
                    // 修正時の注意: 気温が変わると音速が変化し、計算結果に影響
                    TextField("15", text: $temperature)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }

                // 気温の重要性説明 - ユーザーに気温の影響を説明
                // caption: 小さいフォントで補足情報を表示
                // 影響範囲: ユーザーに正確な気温入力の重要性を伝える
                Text(localizedString("temperature_info"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 計算ボタンセクション - 距離を計算して結果画面を表示
            // canCalculate(): 全ての入力が有効な場合のみボタンが有効化
            // 影響範囲: 計算実行後、結果セクションと結果地図画面が表示される
            Section {
                // 計算実行ボタン
                // action: calculateDistance関数を呼び出し
                Button(action: calculateDistance) {
                    HStack {
                        // 関数アイコン（計算を表す）
                        Image(systemName: "function")
                        // ボタンラベル（例: 計算する）
                        Text(localizedString("calculate"))
                        Spacer()
                        // 右向き矢印（アクションを示唆）
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                }
                // 背景色: 有効時は青、無効時は灰色
                // 影響範囲: ユーザーに計算可能かどうかを視覚的に伝える
                .listRowBackground(
                    canCalculate() ? Color.blue : Color.gray
                )
                // 無効化制御: canCalculate()がfalseの場合はボタンを無効化
                // 修正時の注意: 打上地点、時間差、気温の全てが有効な場合のみ有効化
                .disabled(!canCalculate())
            }

            // 計算結果セクション - 計算完了後に表示される
            // 条件分岐: calculatedDistanceがnilでない場合のみ表示
            // 影響範囲: 計算結果を大きく目立つように表示し、ユーザーに確認させる
            if let distance = calculatedDistance {
                Section {
                    // セクションヘッダー - 定規アイコンで距離測定を表現
                    HStack {
                        Image(systemName: "ruler")
                            .foregroundColor(.green)
                        Text(localizedString("calculation_result"))
                            .fontWeight(.medium)
                    }

                    // 距離表示 - アイコン付きラベルで大きく表示
                    // Label: テキストとアイコンを組み合わせたUI要素
                    // フォント: title3（大きめのフォント）
                    // 太さ: semibold（やや太い）
                    // 影響範囲: ユーザーに計算結果を視覚的に強調して伝える
                    Label(String(format: localizedString("distance_format"), distance),
                          systemImage: "arrow.left.and.right")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        }
        // ナビゲーションバーのタイトル設定
        // タイトル: localizedString("input")（多言語対応）
        // 表示モード: large（大きいタイトル、スクロールで小さくなる）
        .navigationTitle(localizedString("input"))
        .navigationBarTitleDisplayMode(.large)
        // ツールバー設定 - ナビゲーションバーにボタンを追加
        .toolbar {
            // 右上に設定ボタンを配置
            ToolbarItem(placement: .navigationBarTrailing) {
                // 設定ボタン - SettingsViewを表示
                // 影響範囲: showSettingsをtrueにしてシートを表示
                Button(action: { showSettings = true }) {
                    // 歯車アイコン（設定を表す）
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.primary)
                }
            }
        }
        // 打上地点選択シート - MapSearchViewをシートとして表示
        // isPresented: showLaunchMapがtrueの時に表示
        // 影響範囲: 地図で選択された座標がlaunchCoordinateに設定される
        .sheet(isPresented: $showLaunchMap) {
            NavigationView {
                // 地図検索ビュー
                // selectedCoordinate: バインディングで座標を親ビューと共有
                MapSearchView(selectedCoordinate: $launchCoordinate)
                    .navigationTitle(localizedString("launch_point"))
                    .environmentObject(settingsManager)
            }
        }
        // 設定シート - SettingsViewをシートとして表示
        // isPresented: showSettingsがtrueの時に表示
        // 影響範囲: 言語設定、アプリ情報、シェア機能を提供
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settingsManager)
        }
        // 結果表示シート - ResultMapViewをシートとして表示
        // isPresented: showResultがtrueの時に表示
        // 条件: calculatedDistanceとlaunchCoordinateが両方存在する場合のみ表示
        // 影響範囲: 計算結果を地図上で視覚的に表示
        .sheet(isPresented: $showResult) {
            if let distance = calculatedDistance, let coord = launchCoordinate {
                ResultMapView(launchCoordinate: coord, distance: distance)
                    .environmentObject(settingsManager)
            }
        }
        // ビューが表示された時の処理
        // 影響範囲: 画面表示時に位置情報の取得を開始
        // 修正時の注意: バッテリー消費とのトレードオフを考慮
        .onAppear {
            locationManager.startUpdatingLocation()
        }
        // ビューが非表示になった時の処理
        // 影響範囲: 画面非表示時に位置情報の取得を停止してバッテリーを節約
        // 修正時の注意: 他の画面で位置情報が必要な場合は削除しない
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
        // 位置情報エラーアラート - エラー発生時にダイアログを表示
        // isPresented: locationManager.locationErrorがnilでない場合に表示
        // 影響範囲: ユーザーに位置情報取得失敗を通知
        .alert(localizedString("error_title"), isPresented: .constant(locationManager.locationError != nil)) {
            // OKボタン - エラーメッセージをクリア
            Button(localizedString("ok")) {
                locationManager.locationError = nil
            }
        } message: {
            // エラーメッセージ本文
            Text(locationManager.locationError ?? "")
        }
    }

    // ローカライズされた文字列を取得する関数
    // settingsManager.localizationManagerから多言語対応文字列を取得
    // 引数: key - ローカライゼーションキー（例: "launch_point"）
    // 戻り値: 現在の言語設定に応じた文字列
    // 影響範囲: ビュー内の全てのテキスト表示に使用
    // 修正時の注意: キーが存在しない場合はキー名がそのまま表示される
    private func localizedString(_ key: String) -> String {
        return settingsManager.localizationManager.localizedString(for: key)
    }

    // 計算可能かチェックする関数 - 全ての入力が有効かを検証
    // 検証項目:
    //   1. 打上地点が選択されているか
    //   2. 時間差が0より大きい数値か
    //   3. 気温が有効な数値か
    // 戻り値: true（計算可能）、false（計算不可）
    // 影響範囲: 計算ボタンの有効/無効状態を制御
    // 修正時の注意: 検証条件を変更すると計算ボタンの動作が変わる
    private func canCalculate() -> Bool {
        // 打上地点が選択されているか確認
        guard launchCoordinate != nil else { return false }
        // 時間差が有効な数値かつ0より大きいか確認
        guard let timeLagValue = Double(timeLag), timeLagValue > 0 else { return false }
        // 気温が有効な数値か確認
        guard let _ = Double(temperature) else { return false }
        return true
    }

    // 距離を計算する関数 - 音速と時間差から距離を算出
    // 計算式: 距離 = 音速 × 時間差
    // 音速計算式: 331.5 + 0.6 × 気温(℃)
    // 影響範囲: calculatedDistanceを更新し、結果セクションと結果地図を表示
    // 修正時の注意: 音速計算式は物理法則に基づくため、変更時は科学的根拠を確認
    private func calculateDistance() {
        // 入力値をDouble型に変換（失敗時は処理を中断）
        guard let timeLagValue = Double(timeLag),
              let tempValue = Double(temperature) else { return }

        // 音速計算: 331.5 + 0.6 × 気温(℃)
        // 331.5: 0℃での音速（m/s）
        // 0.6: 気温1℃あたりの音速変化量（m/s/℃）
        // 影響範囲: 気温が高いほど音速が速くなり、同じ時間差でも距離が長くなる
        let soundSpeed = 331.5 + 0.6 * tempValue

        // 距離 = 音速 × 時間
        // 単位: メートル（m）
        // 影響範囲: この値が結果セクションと結果地図に表示される
        calculatedDistance = soundSpeed * timeLagValue

        // 結果画面を表示
        // 影響範囲: ResultMapViewがシートとして表示される
        showResult = true
    }
}
