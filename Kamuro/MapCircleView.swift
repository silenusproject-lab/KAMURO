import SwiftUI
import MapKit

// AppleMap上に距離の円を表示するビュー
// 打上地点を中心に、計算された距離を半径とする円を地図上に描画
// オーバーレイ機能を使用してオレンジ色の半透明の円を表示
// 使用箇所: ResultMapViewの「地図で表示」ボタンからフルスクリーンで表示
struct MapCircleView: View {
    // 画面を閉じるためのアクション - SwiftUI環境変数
    // 影響範囲: 閉じるボタンで画面を閉じる
    @Environment(\.dismiss) private var dismiss

    // 設定マネージャー - ResultMapViewから環境オブジェクトとして注入される
    // 影響範囲: 多言語対応（日本語/英語）のテキスト表示
    // 使用箇所: タイトル、ボタンラベル、説明テキスト
    @EnvironmentObject var settingsManager: SettingsManager

    // 計算された距離（メートル） - ResultMapViewから渡される
    // 影響範囲: 円の半径、距離表示テキスト
    // 修正時の注意: この値が円のサイズを決定する
    let distance: Double

    // 打上地点座標 - ResultMapViewから渡される
    // 影響範囲: 円の中心位置、地図の中心位置、マーカー表示位置
    // 修正時の注意: この座標を中心に円が描画される
    let launchCoordinate: CLLocationCoordinate2D

    // ビューの本体部分を定義
    // NavigationView: ナビゲーション機能を提供（タイトル、閉じるボタンなど）
    var body: some View {
        NavigationView {
            // ZStack: 地図とUI要素を重ねて表示
            ZStack {
                // MapKitのネイティブ機能を使用して円を描画
                // MapViewWithCircle: 円オーバーレイを持つ地図ビュー
                // centerCoordinate: 円の中心座標
                // radius: 円の半径（メートル）
                // ignoresSafeArea: セーフエリアを無視して画面全体に表示
                // 影響範囲: 地図上にオレンジ色の半透明の円が表示される
                MapViewWithCircle(centerCoordinate: launchCoordinate, radius: distance)
                    .ignoresSafeArea()

                // 距離情報の表示 - 下部に重ねて表示
                // VStack: 内容を縦に並べる
                VStack {
                    Spacer()
                    // 情報カード - 距離情報と説明を含む
                    VStack(alignment: .leading, spacing: 12) {
                        // ヘッダー - 定規アイコンとタイトル
                        HStack {
                            Image(systemName: "ruler")
                                .foregroundColor(.green)
                            Text(localizedString("calculation_result"))
                                .fontWeight(.medium)
                        }

                        // 距離表示と説明
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                // 距離表示 - 大きく目立つフォントで表示
                                // フォント: title2（大きめ）
                                // 太さ: bold（太字）
                                Text(String(format: localizedString("distance_format"), distance))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                // 円の説明 - 小さいフォントで補足情報
                                // 例: 「この円は打上地点からの距離を示しています」
                                // 影響範囲: ユーザーに円の意味を説明
                                Text(localizedString("circle_description"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
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
            .navigationTitle(localizedString("map_with_circle"))
            // タイトル表示モード: inline（小さいタイトル）
            .navigationBarTitleDisplayMode(.inline)
            // ツールバー設定 - ナビゲーションバーにボタンを追加
            .toolbar {
                // 右上に閉じるボタンを配置
                ToolbarItem(placement: .navigationBarTrailing) {
                    // 閉じるボタン - 画面を閉じる
                    // 影響範囲: ResultMapViewに戻る
                    Button(localizedString("close")) {
                        dismiss()
                    }
                }
            }
        }
    }

    // ローカライズされた文字列を取得する関数
    // settingsManager.localizationManagerから多言語対応文字列を取得
    // 引数: key - ローカライゼーションキー（例: "map_with_circle"）
    // 戻り値: 現在の言語設定に応じた文字列
    // 影響範囲: ビュー内の全てのテキスト表示に使用
    // 修正時の注意: キーが存在しない場合はキー名がそのまま表示される
    private func localizedString(_ key: String) -> String {
        return settingsManager.localizationManager.localizedString(for: key)
    }
}

// MapKitのネイティブ機能を使用した地図表示（円オーバーレイ付き）
// SwiftUIでMapKitのMKMapViewと円オーバーレイを使用するためのラッパー
// UIViewRepresentable: UIKitのビューをSwiftUIで使用可能にするプロトコル
// 影響範囲: MapCircleViewで円と打上地点マーカーを表示
struct MapViewWithCircle: UIViewRepresentable {
    // 円の中心座標 - 打上地点の座標
    // 影響範囲: 円の中心位置、地図の中心位置
    let centerCoordinate: CLLocationCoordinate2D

    // 円の半径（メートル） - 計算された距離
    // 影響範囲: 円のサイズ、地図の表示範囲
    let radius: Double

    // UIViewを作成する関数 - SwiftUIから呼ばれる初期化処理
    // 戻り値: MKMapView（MapKitの地図ビュー）
    // 影響範囲: 地図ビューの初期設定、円オーバーレイと打上地点マーカーの追加
    // 修正時の注意: この関数は一度だけ呼ばれる（初回表示時）
    func makeUIView(context: Context) -> MKMapView {
        // MKMapViewのインスタンスを作成
        let mapView = MKMapView()
        // デリゲートを設定（オーバーレイとアノテーションのカスタマイズのため）
        mapView.delegate = context.coordinator
        // ユーザー位置表示を無効化（結果表示では不要）
        mapView.showsUserLocation = false

        // 円オーバーレイを追加
        // MKCircle: 中心座標と半径を指定して円を作成
        // 影響範囲: 地図上に円が描画される
        let circle = MKCircle(center: centerCoordinate, radius: radius)
        // 地図に円オーバーレイを追加
        mapView.addOverlay(circle)

        // 打上地点のアノテーション（マーカー）を追加
        // MKPointAnnotation: 地図上の特定の座標にマーカーを表示
        let annotation = MKPointAnnotation()
        // マーカーの座標を設定
        annotation.coordinate = centerCoordinate
        // マーカーのタイトルを設定（タップ時に表示）
        // 修正時の注意: 多言語対応が必要な場合はローカライズ処理を追加
        annotation.title = "打上地点"
        // 地図にアノテーションを追加
        // 影響範囲: 地図上に打上地点のマーカーが表示される
        mapView.addAnnotation(annotation)

        // 円全体が見えるように地図の表示範囲を設定
        // latitudinalMeters/longitudinalMeters: メートル単位で範囲を指定
        // radius * 2.5: 円の半径の2.5倍の範囲を表示（余裕を持たせる）
        // 影響範囲: 円全体が画面内に収まるようにズームレベルを調整
        // 修正時の注意: 2.5を小さくするとズームイン、大きくするとズームアウト
        let region = MKCoordinateRegion(
            center: centerCoordinate,
            latitudinalMeters: radius * 2.5,
            longitudinalMeters: radius * 2.5
        )
        // 初期表示領域を設定（アニメーションなし）
        mapView.setRegion(region, animated: false)

        return mapView
    }

    // UIViewを更新する関数 - SwiftUIの状態変更時に呼ばれる
    // 引数: uiView - 更新対象のMKMapView
    // 影響範囲: 必要に応じて地図を更新（現在は未実装）
    // 修正時の注意: 円の半径や中心位置の動的更新が必要な場合はここに処理を追加
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 更新時の処理（必要に応じて）
        // 現在は特に更新処理なし（静的な円表示のため）
    }

    // コーディネーターを作成する関数 - デリゲート処理を担当
    // 戻り値: Coordinator（MKMapViewDelegateを実装）
    // 影響範囲: オーバーレイとアノテーションのカスタマイズを行う
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MapViewのデリゲート処理を行うコーディネーター
    // MKMapViewDelegate: オーバーレイとアノテーションの表示方法をカスタマイズするプロトコル
    // 影響範囲: 円の色・透明度、打上地点マーカーの見た目を定義
    class Coordinator: NSObject, MKMapViewDelegate {
        // 親ビューへの参照
        var parent: MapViewWithCircle

        // 初期化処理
        // 引数: parent - MapViewWithCircleのインスタンス
        init(_ parent: MapViewWithCircle) {
            self.parent = parent
        }

        // 円オーバーレイのレンダリング
        // MKMapViewDelegateのデリゲートメソッド
        // 引数:
        //   mapView - 地図ビュー
        //   overlay - 描画するオーバーレイ
        // 戻り値: オーバーレイのレンダラー
        // 影響範囲: 円の色、透明度、線の太さを設定
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            // オーバーレイが円の場合
            if let circle = overlay as? MKCircle {
                // 円のレンダラーを作成
                let renderer = MKCircleRenderer(circle: circle)
                // 円の枠線の色をオレンジに設定
                // 影響範囲: 円の輪郭が目立つオレンジ色で描画される
                renderer.strokeColor = UIColor.orange
                // 円の塗りつぶし色を半透明のオレンジに設定
                // withAlphaComponent(0.2): 20%の不透明度（80%透明）
                // 影響範囲: 円の内部が薄いオレンジ色で塗りつぶされ、地図が透けて見える
                renderer.fillColor = UIColor.orange.withAlphaComponent(0.2)
                // 円の枠線の太さを3ポイントに設定
                // 修正時の注意: 太くすると枠線が目立つ、細くすると見えにくくなる
                renderer.lineWidth = 3
                return renderer
            }
            // 円以外のオーバーレイの場合はデフォルトのレンダラーを返す
            return MKOverlayRenderer(overlay: overlay)
        }

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
            // 影響範囲: 打上地点を視覚的に目立たせ、円の色と統一
            annotationView?.markerTintColor = .orange
            // マーカー内のアイコンを炎に設定
            // 影響範囲: 打上地点であることを視覚的に示す
            annotationView?.glyphImage = UIImage(systemName: "flame.fill")

            return annotationView
        }
    }
}
