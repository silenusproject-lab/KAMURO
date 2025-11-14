import SwiftUI
import MapKit

// 地図上で場所を検索・選択するビュー
// このビューは地図の中央にピンを固定表示し、地図をドラッグして位置を選択する仕組み
// 検索機能により、地名や住所で素早く目的地に移動可能
// 使用箇所: InputFormViewの「地図で選択」ボタンから表示
struct MapSearchView: View {
    // 画面を閉じるためのアクション - SwiftUI環境変数
    // 影響範囲: キャンセルボタンや確定ボタンで画面を閉じる
    @Environment(\.dismiss) private var dismiss

    // 設定マネージャー - InputFormViewから環境オブジェクトとして注入される
    // 影響範囲: 多言語対応（日本語/英語）のテキスト表示
    // 使用箇所: 検索バー、ボタンラベル
    @EnvironmentObject var settingsManager: SettingsManager

    // 選択された座標を親ビュー（InputFormView）とバインディング
    // @Binding: 親ビューのlaunchCoordinateと双方向データバインディング
    // 影響範囲: ここで選択した座標が親ビューのlaunchCoordinateに反映される
    // 修正時の注意: 確定ボタン押下時にregion.centerの値が設定される
    @Binding var selectedCoordinate: CLLocationCoordinate2D?

    // 地図の表示領域 - 中心座標とズームレベルを管理
    // @State: 地図のドラッグやズーム操作で動的に変化
    // MKCoordinateRegion: 中心座標（center）と表示範囲（span）を持つ
    // 影響範囲: 地図の表示位置とズームレベルを制御
    // 修正時の注意: この値の変更は地図の再描画をトリガーする
    @State private var region: MKCoordinateRegion

    // 検索テキスト - 検索バーに入力される文字列
    // @State: ユーザー入力で動的に変化
    // 影響範囲: 検索実行時にMKLocalSearchのクエリとして使用
    // 使用箇所: 検索バーのテキストフィールド
    @State private var searchText = ""

    // 検索結果リスト - MKLocalSearchから返された場所のリスト
    // @State: 検索実行後に結果が格納される
    // [MKMapItem]: 地名、住所、座標などの情報を持つ配列
    // 影響範囲: 検索結果リストの表示/非表示、結果タップ時の地図移動
    // 修正時の注意: 空配列の場合は検索結果リストが非表示になる
    @State private var searchResults: [MKMapItem] = []

    // 検索中フラグ - 検索API実行中かどうかを示す
    // @State: 検索開始時にtrue、完了時にfalseに変化
    // 影響範囲: ローディングインジケーター表示などに使用可能（現在未使用）
    // 使用箇所: searchLocation関数内でtrue/falseを切り替え
    @State private var isSearching = false

    // 初期化処理 - 地図の初期表示位置を設定
    // 引数:
    //   selectedCoordinate: 親ビューから渡される選択座標のバインディング
    //   initialCenter: 初期表示の中心座標（オプション）
    // 影響範囲: 地図の初期表示位置を決定
    // 優先順位: 1) 既存の選択座標 > 2) initialCenter > 3) 東京駅（デフォルト）
    // 修正時の注意: デフォルト座標（東京）を変更する場合はここを修正
    init(selectedCoordinate: Binding<CLLocationCoordinate2D?>, initialCenter: CLLocationCoordinate2D? = nil) {
        // バインディングを設定
        self._selectedCoordinate = selectedCoordinate

        // 初期表示位置を決定（既存座標 > 初期中心 > 東京駅）
        // 東京駅の座標: 緯度35.6812, 経度139.7671
        let initialCoordinate = selectedCoordinate.wrappedValue ?? initialCenter ?? CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)

        // 地図の初期表示領域を設定
        // span: 0.05度（約5.5km四方）の範囲を表示
        // 修正時の注意: spanを小さくするとズームイン、大きくするとズームアウト
        _region = State(initialValue: MKCoordinateRegion(
            center: initialCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    // ビューの本体部分を定義
    // ZStack: 複数のビューを重ねて表示（地図、ピン、検索バー、確定ボタン）
    var body: some View {
        ZStack {
            // 地図表示 - SimpleMapViewを使用してMapKitの地図を表示
            // region: 地図の中心座標とズームレベルをバインディング
            // showsUserLocation: ユーザーの現在位置を青い点で表示
            // ignoresSafeArea: セーフエリアを無視して画面全体に表示
            // 影響範囲: 地図のドラッグ・ズーム操作でregionが更新される
            SimpleMapView(region: $region, showsUserLocation: true)
                .ignoresSafeArea()

            // 中央の固定ピン - 地図の中心位置を示すマーカー
            // 地図をドラッグしてもピンは中央に固定され、ピン位置が選択座標となる
            // デザイン: 赤い大きなピンアイコン（サイズ40）
            // 影響範囲: ユーザーに「地図の中心が選択位置」であることを視覚的に示す
            VStack {
                Spacer()
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                Spacer()
            }

            // 上部の検索バーと検索結果リスト
            // VStack: 検索バーと検索結果を縦に並べる
            VStack {
                HStack {
                    // 検索フィールド - 地名や住所を検索
                    // HStack: 虫眼鏡アイコン、テキストフィールド、クリアボタンを横に並べる
                    HStack {
                        // 虫眼鏡アイコン（検索を表す）
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        // 検索テキスト入力フィールド
                        // onSubmit: Enterキー押下時にsearchLocation()を実行
                        // 影響範囲: 入力後にEnterキーで検索が実行される
                        TextField(localizedString("search_location"), text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onSubmit {
                                searchLocation()
                            }
                        // クリアボタン - 検索テキストが空でない場合のみ表示
                        // 影響範囲: タップで検索テキストと検索結果をクリア
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                .padding()

                // 検索結果リスト - 検索実行後に表示される
                // 条件分岐: searchResultsが空でない場合のみ表示
                // 影響範囲: 検索結果をタップすると地図がその位置に移動
                if !searchResults.isEmpty {
                    ScrollView {
                        // 検索結果を縦に並べる
                        VStack(alignment: .leading, spacing: 0) {
                            // 各検索結果をボタンとして表示
                            ForEach(searchResults, id: \.self) { item in
                                // 検索結果タップ時の処理
                                // 影響範囲: selectSearchResult()を呼び出して地図を移動
                                Button(action: {
                                    selectSearchResult(item)
                                }) {
                                    // 検索結果の表示内容
                                    // 上段: 地名（例: 東京駅）
                                    // 下段: 住所（例: 東京都千代田区丸の内1-9-1）
                                    VStack(alignment: .leading, spacing: 4) {
                                        // 地名表示
                                        Text(item.name ?? "")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        // 住所表示（存在する場合のみ）
                                        if let address = item.placemark.title {
                                            Text(address)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .background(Color(.systemBackground))
                                // 区切り線
                                Divider()
                            }
                        }
                    }
                    // 検索結果リストの最大高さを200ポイントに制限
                    // 修正時の注意: 高さを変更すると検索結果の表示領域が変わる
                    .frame(maxHeight: 200)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }

                Spacer()
            }

            // 下部の確定ボタン - 選択位置を確定して画面を閉じる
            // VStack + HStack: 右下に配置
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    // 確定ボタン
                    // 影響範囲: 地図の中心座標をselectedCoordinateに設定して画面を閉じる
                    Button(action: {
                        // 地図の中心座標を選択座標として設定
                        // region.center: 現在の地図の中心座標
                        // 影響範囲: 親ビュー（InputFormView）のlaunchCoordinateが更新される
                        selectedCoordinate = region.center
                        // 画面を閉じる
                        dismiss()
                    }) {
                        HStack {
                            // チェックマークアイコン（確定を表す）
                            Image(systemName: "checkmark")
                            // ボタンラベル（例: 位置を確定）
                            Text(localizedString("confirm_location"))
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
        // ナビゲーションバーのタイトル表示モード
        // inline: 小さいタイトル（スクロールしても変わらない）
        .navigationBarTitleDisplayMode(.inline)
        // ツールバー設定 - ナビゲーションバーにボタンを追加
        .toolbar {
            // 左上にキャンセルボタンを配置
            ToolbarItem(placement: .navigationBarLeading) {
                // キャンセルボタン - 選択をキャンセルして画面を閉じる
                // 影響範囲: selectedCoordinateを変更せずに画面を閉じる
                Button(localizedString("cancel")) {
                    dismiss()
                }
            }
        }
    }

    // ローカライズされた文字列を取得する関数
    // settingsManager.localizationManagerから多言語対応文字列を取得
    // 引数: key - ローカライゼーションキー（例: "search_location"）
    // 戻り値: 現在の言語設定に応じた文字列
    // 影響範囲: ビュー内の全てのテキスト表示に使用
    // 修正時の注意: キーが存在しない場合はキー名がそのまま表示される
    private func localizedString(_ key: String) -> String {
        return settingsManager.localizationManager.localizedString(for: key)
    }

    // 場所を検索する関数 - MKLocalSearchを使用して地名・住所を検索
    // MapKitの検索APIを使用し、現在の地図表示領域を検索範囲とする
    // 影響範囲: searchResultsに検索結果が格納され、検索結果リストが表示される
    // 修正時の注意: 検索は非同期処理のため、結果取得まで時間がかかる場合がある
    private func searchLocation() {
        // 検索テキストが空の場合は処理を中断
        guard !searchText.isEmpty else { return }

        // 検索中フラグを設定
        isSearching = true
        // 検索リクエストを作成
        let request = MKLocalSearch.Request()
        // 検索クエリを設定（地名や住所の自然言語検索）
        // 例: "東京駅"、"渋谷区"、"富士山"など
        request.naturalLanguageQuery = searchText
        // 検索範囲を現在の地図表示領域に設定
        // 影響範囲: 地図の表示範囲内を優先的に検索
        request.region = region

        // 検索を実行
        let search = MKLocalSearch(request: request)
        // 非同期で検索開始
        // 影響範囲: 検索完了後にクロージャが呼ばれる
        search.start { response, error in
            // 検索中フラグをクリア
            isSearching = false
            // 検索結果がある場合
            if let response = response {
                // 検索結果を保存
                // 影響範囲: searchResultsが更新され、検索結果リストが表示される
                searchResults = response.mapItems
            }
        }
    }

    // 検索結果を選択する関数 - 検索結果をタップした時の処理
    // 引数: item - 選択されたMKMapItem（地名、座標、住所などの情報を含む）
    // 影響範囲: 地図を選択位置に移動し、ズームインする
    // 修正時の注意: span（ズームレベル）を変更すると、選択後のズーム倍率が変わる
    private func selectSearchResult(_ item: MKMapItem) {
        // 選択された場所の座標を取得
        let coordinate = item.placemark.coordinate
        // 地図をその位置に移動してズームイン
        // span: 0.01度（約1.1km四方）に設定してズームイン
        // 修正時の注意: spanを小さくするとよりズームイン、大きくするとズームアウト
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        // 検索結果リストをクリア（選択後は非表示）
        searchResults = []
        // 検索テキストを選択した場所の名前に更新
        // 影響範囲: 検索バーに選択した場所の名前が表示される
        searchText = item.name ?? ""
    }
}

// シンプルな地図表示用のUIViewRepresentable
// SwiftUIでMapKitのMKMapViewを使用するためのラッパー
// UIViewRepresentable: UIKitのビューをSwiftUIで使用可能にするプロトコル
// 影響範囲: MapSearchViewで地図を表示するために使用
struct SimpleMapView: UIViewRepresentable {
    // 地図の表示領域 - 親ビューとバインディング
    // @Binding: MapSearchViewのregionと双方向データバインディング
    // 影響範囲: 地図のドラッグ・ズームでregionが更新され、親ビューに反映される
    @Binding var region: MKCoordinateRegion

    // ユーザーの現在位置を表示するかどうか
    // true: 青い点でユーザー位置を表示
    // 影響範囲: 地図上にユーザーの現在位置が表示される
    let showsUserLocation: Bool

    // UIViewを作成する関数 - SwiftUIから呼ばれる初期化処理
    // 戻り値: MKMapView（MapKitの地図ビュー）
    // 影響範囲: 地図ビューの初期設定を行う
    // 修正時の注意: この関数は一度だけ呼ばれる（初回表示時）
    func makeUIView(context: Context) -> MKMapView {
        // MKMapViewのインスタンスを作成
        let mapView = MKMapView()
        // ユーザー位置表示の設定
        mapView.showsUserLocation = showsUserLocation
        // デリゲートを設定（地図の変更イベントを受け取るため）
        mapView.delegate = context.coordinator
        // 初期表示領域を設定（アニメーションなし）
        mapView.setRegion(region, animated: false)
        return mapView
    }

    // UIViewを更新する関数 - SwiftUIの状態変更時に呼ばれる
    // 引数: mapView - 更新対象のMKMapView
    // 影響範囲: regionの変更を地図に反映
    // 修正時の注意: 頻繁に呼ばれる可能性があるため、不要な更新を避ける
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // regionが変更されたら地図を更新
        // 各座標・spanの値を比較して変更があるかチェック
        // 影響範囲: 変更がある場合のみアニメーション付きで地図を更新
        if mapView.region.center.latitude != region.center.latitude ||
           mapView.region.center.longitude != region.center.longitude ||
           mapView.region.span.latitudeDelta != region.span.latitudeDelta ||
           mapView.region.span.longitudeDelta != region.span.longitudeDelta {
            // アニメーション付きで地図を更新
            mapView.setRegion(region, animated: true)
        }
    }

    // コーディネーターを作成する関数 - デリゲート処理を担当
    // 戻り値: Coordinator（MKMapViewDelegateを実装）
    // 影響範囲: 地図のイベント処理を行う
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // コーディネータークラス - MKMapViewのデリゲート処理を実装
    // MKMapViewDelegate: 地図の変更イベントを受け取るプロトコル
    // 影響範囲: 地図のドラッグ・ズーム操作を検知してregionを更新
    class Coordinator: NSObject, MKMapViewDelegate {
        // 親ビューへの参照
        var parent: SimpleMapView

        // 初期化処理
        // 引数: parent - SimpleMapViewのインスタンス
        init(_ parent: SimpleMapView) {
            self.parent = parent
        }

        // 地図の表示領域が変更された時の処理
        // MKMapViewDelegateのデリゲートメソッド
        // 引数:
        //   mapView - 変更があった地図ビュー
        //   animated - アニメーションがあったかどうか
        // 影響範囲: 地図のドラッグ・ズーム後にregionを更新
        // 修正時の注意: この処理により親ビューのregionが更新される
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // 地図の新しい表示領域を親ビューのregionに反映
            // 影響範囲: MapSearchViewのregionが更新される
            parent.region = mapView.region
        }
    }
}
