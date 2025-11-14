# KAMURO - 花火撮影位置計算アプリ

## 概要
花火の音から撮影位置を逆算するiOSアプリです。花火の開花を見た時刻と音が聞こえた時刻の差から、撮影地点と打上地点の距離を計算します。

## 主な機能
- 打上地点の位置設定（地図検索・タップ選択・現在地使用）
- 時間差と気温による距離計算
- 地図上での結果表示と距離円の可視化
- 多言語対応（日本語・英語、将来16言語まで拡張予定）
- SNSシェア機能（X、note、LINE）
- App Store評価リクエスト

## 技術仕様

### 距離計算式
```
音速 = 331.5 + 0.6 × 気温(℃)
距離 = 音速 × 時間差(秒)
```

### 対応環境
- iOS 18.0以降
- iPhone専用（iPadは非対応）

### 使用フレームワーク
- SwiftUI - UI構築
- MapKit - 地図表示と検索
- CoreLocation - GPS位置情報取得
- StoreKit - App Store評価

## プロジェクト構成

### コアファイル
- **KamuroApp.swift** - アプリエントリーポイント、環境オブジェクト管理
- **ContentView.swift** - ルートビュー、スプラッシュスクリーン呼び出し
- **SplashScreenView.swift** - 起動画面（0.7秒表示後にメイン画面へ遷移）

### マネージャークラス
- **LocationManager.swift** - GPS位置情報の取得・管理
  - 精度: 100m（kCLLocationAccuracyHundredMeters）
  - パフォーマンス最適化: アプリ起動時に位置情報取得開始
  - スレッドセーフ: @MainActorで全処理をメインスレッドで実行

- **SettingsManager.swift** - アプリ設定管理
  - 言語設定の保存・読み込み
  - UserDefaultsとの連携

- **LocalizationManager.swift** - 多言語対応
  - 現在対応: 日本語、英語
  - 全テキストのローカライゼーション辞書管理
  - UserDefaultsに言語設定を永続化

### ビューファイル

#### メイン画面
- **InputFormView.swift** - 入力フォーム画面
  - 打上地点の選択（地図/現在地）
  - 時間差・気温の入力
  - 距離計算の実行
  - 結果表示

#### 地図関連
- **MapSearchView.swift** - 地図検索・選択画面
  - MKLocalSearchによる地名検索
  - 中央固定ピンで位置選択
  - SimpleMapView（UIViewRepresentable）で地図表示

- **ResultMapView.swift** - 計算結果表示画面
  - 打上地点マーカー表示
  - 距離情報カード
  - SimpleResultMapView（UIViewRepresentable）で地図表示

- **MapCircleView.swift** - 距離円表示画面
  - MKCircleオーバーレイで円を描画
  - 打上地点マーカー（炎アイコン）
  - MapViewWithCircle（UIViewRepresentable）で地図+円表示

#### 設定画面
- **SettingsView.swift** - 設定画面
  - 言語設定
  - バージョン情報（VersionInfoView）
  - アプリについて（AboutAppView）
  - SNSシェア（X、note、LINE）
  - App Store評価リクエスト

## アーキテクチャ

### データフロー
```
KamuroApp
  ├─ ContentView
  │   └─ SplashScreenView (0.7秒)
  │       └─ NavigationView
  │           └─ InputFormView (メイン画面)
  │               ├─ MapSearchView (地図検索)
  │               ├─ ResultMapView (結果)
  │               │   └─ MapCircleView (円表示)
  │               └─ SettingsView (設定)
  │                   ├─ VersionInfoView
  │                   └─ AboutAppView
```

### 環境オブジェクト
- **LocationManager** - KamuroAppで生成、全ビューに注入
- **SettingsManager** - KamuroAppで生成、全ビューに注入
  - LocalizationManagerを内包

## パフォーマンス最適化

### 位置情報取得の高速化
1. アプリ起動時（KamuroApp.onAppear）に位置情報取得開始
2. GPS精度を100mに設定（バッテリー消費と速度のバランス）
3. 既に位置情報がある場合は再取得しない

### 地図表示の最適化
- UIViewRepresentableでMapKitのMKMapViewを直接使用
- iOS 17で非推奨となったSwiftUI MapからMKMapViewへ移行
- アノテーションビューの再利用でメモリ効率化

## 多言語対応

### 対応言語
- 日本語（ja）
- 英語（en）

### 追加予定言語
将来的に16言語まで拡張予定

### ローカライゼーションキー
主要なキーは LocalizationManager.swift の translations 辞書に定義

## 今後の改修ガイド

### ロゴ画像の配置
Assets.xcassets/AppLogo.imageset/ に以下のファイルを配置:
- AppLogo.png (1x)
- AppLogo@2x.png (2x)
- AppLogo@3x.png (3x)

### 新しい言語の追加
1. LocalizationManager.Language enum に言語を追加
2. translations 辞書に新言語の翻訳を追加
3. displayName に言語のネイティブ表示名を追加

### 計算式の変更
InputFormView.swift の calculateDistance() 関数を修正

### GPS精度の変更
LocationManager.swift の manager.desiredAccuracy を変更
- kCLLocationAccuracyBest - 最高精度（遅い）
- kCLLocationAccuracyHundredMeters - 100m精度（現在の設定）
- kCLLocationAccuracyKilometer - 1km精度（最速）

## 注意事項

### 位置情報の利用
- Info.plist に NSLocationWhenInUseUsageDescription が必要
- 現在の説明文: "撮影位置を特定するために、打上地点の設定で位置情報を使用します。"

### デプロイメント
- 最小対応バージョン: iOS 18.0
- 対応デバイス: iPhoneのみ（TARGETED_DEVICE_FAMILY = 1）
- Mac CatalystとvisionOSは非対応

### プライバシー
- 位置情報は端末内でのみ使用
- 外部サーバーへの送信なし

## ライセンス
（ライセンス情報を記載）

## 開発者
Tsuyoshi Nishigaki

## 更新履歴
- バージョン 1.0 (2025/10/15) - 初回リリース
