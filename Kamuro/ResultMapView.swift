import SwiftUI
import MapKit

// 計算結果をマップで表示するビュー
// 打上地点のアノテーション（マーカー）を表示し、距離情報を重ねて表示
// 「地図で表示」ボタンでMapCircleViewに遷移し、距離の円を可視化
// 使用箇所: InputFormViewの計算実行後にシートとして表示
struct ResultMapView: View {
    // 画面を閉じるためのアクション - SwiftUI環境変数
    // 影響範囲: 閉じるボタンで画面を閉じる
    @Environment(\.dismiss) private var dismiss

    // 設定マネージャー - InputFormViewから環境オブジェクトとして注入される
    // 影響範囲: 多言語対応（日本語/英語）のテキスト表示
    // 使用箇所: ボタンラベル、結果表示テキスト
    @EnvironmentObject var settingsManager: SettingsManager

    // 打上地点座標 - InputFormViewから渡される
    // 影響範囲: 地図の中心位置、アノテーション表示位置
    // 修正時の注意: この座標を中心に地図が表示される
    let launchCoordinate: CLLocationCoordinate2D

    // 計算された距離（メートル） - InputFormViewから渡される
    // 影響範囲: 結果表示、地図の表示範囲（ズームレベル）
    // 修正時の注意: この値に応じて地図の表示範囲が自動調整される
    let distance: Double

    // 地図の表示領域 - 中心座標とズームレベルを管理
    // @State: 地図の表示状態を保持
    // 影響範囲: 地図の初期表示範囲を距離に応じて設定
    // 修正時の注意: 距離が大きいほど広い範囲を表示
    @State private var region: MKCoordinateRegion

    // 円表示画面の表示状態 - MapCircleViewのフルスクリーン表示を制御
    // @State: フルスクリーンカバーの表示/非表示を管理
    // 影響範囲: 「地図で表示」ボタンのアクション
    // 修正時の注意: trueになるとMapCircleViewがフルスクリーンで表示される
    @State private var showCircle = false

    // 初期化処理 - 距離に応じて地図の表示範囲を自動調整
    // 引数:
    //   launchCoordinate: 打上地点の座標
    //   distance: 計算された距離（メートル）
    // 影響範囲: 地図の初期表示範囲を決定
    // 修正時の注意: span係数（2.5）を変更すると表示範囲が変わる
    init(launchCoordinate: CLLocationCoordinate2D, distance: Double) {
        self.launchCoordinate = launchCoordinate
        self.distance = distance

        // 距離に応じて地図の表示範囲を調整
        // 計算式: 距離(m) / 111000(1度あたりのメートル) * 2.5(余裕係数)
        // 緯度1度 ≒ 111km ≒ 111000m
        // 2.5倍: 打上地点を中心に距離の2.5倍の範囲を表示（余裕を持たせる）
        // 影響範囲: 距離が大きいほどズームアウト、小さいほどズームイン
        // 修正時の注意: 2.5を小さくするとズームイン、大きくするとズームアウト
        let span = MKCoordinateSpan(
            latitudeDelta: distance / 111000 * 2.5, // 緯度1度≒111km
            longitudeDelta: distance / 111000 * 2.5
        )
        // 地図の初期表示領域を設定
        _region = State(initialValue: MKCoordinateRegion(
            center: launchCoordinate,
            span: span
        ))
    }

    // ビューの本体部分を定義
    // NavigationView: ナビゲーション機能を提供（タイトル、閉じるボタンなど）
    var body: some View {
        NavigationView {
            // ZStack: 地図とUI要素を重ねて表示
            ZStack {
                // 地図表示 - SimpleResultMapViewを使用して打上地点のマーカーを表示
                // region: 地図の表示領域をバインディング
                // launchCoordinate: 打上地点の座標（マーカー表示位置）
                // ignoresSafeArea: セーフエリアを無視して画面全体に表示
                // 影響範囲: 地図上に打上地点のオレンジ色のマーカーが表示される
                SimpleResultMapView(region: $region, launchCoordinate: launchCoordinate)
                    .ignoresSafeArea()

                // 距離情報の表示 - 下部に重ねて表示
                // VStack: 内容を縦に並べる
                VStack {
                    Spacer()
                    // 情報カード - 距離情報とボタンを含む
                    VStack(alignment: .leading, spacing: 12) {
                        // ヘッダー - 定規アイコンとタイトル
                        HStack {
                            Image(systemName: "ruler")
                                .foregroundColor(.green)
                            Text(localizedString("calculation_result"))
                                .fontWeight(.medium)
                        }

                        // 距離表示 - 大きく目立つフォントで表示
                        // フォント: title2（大きめ）
                        // 太さ: bold（太字）
                        // 影響範囲: ユーザーに計算結果を視覚的に強調して伝える
                        Text(String(format: localizedString("distance_format"), distance))
                            .font(.title2)
                            .fontWeight(.bold)

                        // 地図で表示ボタン - MapCircleViewへ遷移
                        // 影響範囲: タップでshowCircleをtrueにし、距離の円を表示
                        Button(action: { showCircle = true }) {
                            HStack {
                                // 地図+円アイコン
                                Image(systemName: "map.circle")
                                // ボタンラベル（例: 地図で表示）
                                Text(localizedString("view_on_map"))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        .padding(.top, 4)
                    }
                    // カードのスタイリング
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding()
                }
            }
            // ナビゲーションバーのタイトル設定
            .navigationTitle(localizedString("calculation_result"))
            // タイトル表示モード: inline（小さいタイトル）
            .navigationBarTitleDisplayMode(.inline)
            // ツールバー設定 - ナビゲーションバーにボタンを追加
            .toolbar {
                // 右上に閉じるボタンを配置
                ToolbarItem(placement: .navigationBarTrailing) {
                    // 閉じるボタン - 画面を閉じる
                    // 影響範囲: InputFormViewに戻る
                    Button(localizedString("close")) {
                        dismiss()
                    }
                }
            }
            // 円表示画面のフルスクリーンカバー - MapCircleViewをフルスクリーンで表示
            // isPresented: showCircleがtrueの時に表示
            // 影響範囲: 距離の円を地図上に可視化
            .fullScreenCover(isPresented: $showCircle) {
                MapCircleView(distance: distance, launchCoordinate: launchCoordinate)
                    .environmentObject(settingsManager)
            }
        }
    }

    // ローカライズされた文字列を取得する関数
    // settingsManager.localizationManagerから多言語対応文字列を取得
    // 引数: key - ローカライゼーションキー（例: "calculation_result"）
    // 戻り値: 現在の言語設定に応じた文字列
    // 影響範囲: ビュー内の全てのテキスト表示に使用
    // 修正時の注意: キーが存在しない場合はキー名がそのまま表示される
    private func localizedString(_ key: String) -> String {
        return settingsManager.localizationManager.localizedString(for: key)
    }
}

// 結果表示用のシンプルな地図ビュー
// SwiftUIでMapKitのMKMapViewを使用するためのラッパー
// UIViewRepresentable: UIKitのビューをSwiftUIで使用可能にするプロトコル
// 影響範囲: ResultMapViewで打上地点のマーカー付き地図を表示
struct SimpleResultMapView: UIViewRepresentable {
    // 地図の表示領域 - 親ビューとバインディング
    // @Binding: ResultMapViewのregionと双方向データバインディング
    // 影響範囲: 地図の表示範囲を親ビューから制御
    @Binding var region: MKCoordinateRegion

    // 打上地点座標 - マーカー表示位置
    // 影響範囲: この座標にオレンジ色の炎アイコンマーカーを表示
    let launchCoordinate: CLLocationCoordinate2D

    // UIViewを作成する関数 - SwiftUIから呼ばれる初期化処理
    // 戻り値: MKMapView（MapKitの地図ビュー）
    // 影響範囲: 地図ビューの初期設定と打上地点マーカーの追加
    // 修正時の注意: この関数は一度だけ呼ばれる（初回表示時）
    func makeUIView(context: Context) -> MKMapView {
        // MKMapViewのインスタンスを作成
        let mapView = MKMapView()
        // ユーザー位置表示を無効化（結果表示では不要）
        mapView.showsUserLocation = false
        // 初期表示領域を設定（アニメーションなし）
        mapView.setRegion(region, animated: false)

        // 打上地点のアノテーション（マーカー）を追加
        // MKPointAnnotation: 地図上の特定の座標にマーカーを表示
        let annotation = MKPointAnnotation()
        // マーカーの座標を設定
        annotation.coordinate = launchCoordinate
        // マーカーのタイトルを設定（タップ時に表示）
        // 修正時の注意: 多言語対応が必要な場合はローカライズ処理を追加
        annotation.title = "打上地点"
        // 地図にアノテーションを追加
        // 影響範囲: 地図上に打上地点のマーカーが表示される
        mapView.addAnnotation(annotation)

        // デリゲートを設定（アノテーションのカスタマイズのため）
        mapView.delegate = context.coordinator

        return mapView
    }

    // UIViewを更新する関数 - SwiftUIの状態変更時に呼ばれる
    // 引数: mapView - 更新対象のMKMapView
    // 影響範囲: 必要に応じて地図を更新（現在は未実装）
    // 修正時の注意: regionの変更を反映する場合はここに処理を追加
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 必要に応じて更新
        // 現在は特に更新処理なし（静的な結果表示のため）
    }

    // コーディネーターを作成する関数 - デリゲート処理を担当
    // 戻り値: Coordinator（MKMapViewDelegateを実装）
    // 影響範囲: アノテーション（マーカー）のカスタマイズを行う
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // コーディネータークラス - MKMapViewのデリゲート処理を実装
    // MKMapViewDelegate: アノテーションの表示方法をカスタマイズするプロトコル
    // 影響範囲: 打上地点マーカーの見た目を定義
    class Coordinator: NSObject, MKMapViewDelegate {
        // アノテーションビューのカスタマイズ
        // MKMapViewDelegateのデリゲートメソッド
        // 引数:
        //   mapView - 地図ビュー
        //   annotation - 表示するアノテーション
        // 戻り値: カスタマイズされたMKAnnotationView
        // 影響範囲: マーカーの色とアイコンを設定
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // ユーザー位置アノテーションの場合はデフォルト表示
            guard !(annotation is MKUserLocation) else { return nil }

            // 再利用識別子
            let identifier = "LaunchPoint"
            // 既存のアノテーションビューを再利用（パフォーマンス最適化）
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            // アノテーションビューの作成または再利用
            if annotationView == nil {
                // 新規作成
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                // コールアウト（タップ時の情報表示）を有効化
                annotationView?.canShowCallout = true
            } else {
                // 再利用時はアノテーションを更新
                annotationView?.annotation = annotation
            }

            // マーカーの色をオレンジに設定
            // 影響範囲: 打上地点を視覚的に目立たせる
            annotationView?.markerTintColor = .orange
            // マーカー内のアイコンを炎に設定
            // 影響範囲: 打上地点であることを視覚的に示す
            annotationView?.glyphImage = UIImage(systemName: "flame.fill")

            return annotationView
        }
    }
}
