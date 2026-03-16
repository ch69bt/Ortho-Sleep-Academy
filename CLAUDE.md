# ORTHO SLEEP ACADEMY — CLAUDE.md

> 睡眠の質改善をサポートするスマートフォン向け照度計アプリ
> Flutter（iOS / Android）

---

## プロジェクト概要

| 項目 | 内容 |
|---|---|
| アプリ名 | ORTHO SLEEP ACADEMY |
| 目的 | 起床時の日光浴・日中の光量確認・夜間の光量抑制を支援 |
| プラットフォーム | iOS / Android |
| 言語 | 日本語のみ |
| Bundle ID | `com.orthosleepacademy.app` |
| Dart パッケージ名 | `ortho_sleep_academy` |
| バージョン | 1.0.0+1（新 Bundle ID でリスタート） |

---

## 技術スタック

| レイヤー | 技術 |
|---|---|
| フレームワーク | Flutter 3.x（Dart 3.x） |
| iOS 照度取得 | AVFoundation（MethodChannel / EventChannel） |
| Android 照度取得 | SensorManager TYPE_LIGHT（MethodChannel / EventChannel） |
| 通知 | flutter_local_notifications + timezone + flutter_timezone |
| 広告 | google_mobile_ads（AdMob バナーのみ） |
| シェア | share_plus + path_provider（スクリーンショット保存） |
| 設定永続化 | shared_preferences |
| URL起動 | url_launcher |
| 権限管理 | permission_handler |
| Android センサー | sensors_plus（パッケージ追加済み、実装は MethodChannel 統一） |

---

## ディレクトリ構成

```
lib/
├── main.dart                     # エントリーポイント（AdMob初期化）
├── app.dart                      # MaterialApp・テーマ定義（OrthoSleepAcademyApp）
├── constants/
│   ├── colors.dart               # カラーパレット
│   ├── text_styles.dart          # タイポグラフィ（heading/body含む）
│   └── lux_thresholds.dart       # 光量基準値・時間帯定義・アドバイステキスト
├── models/
│   └── lux_feedback.dart         # 時間帯判定・フィードバックモデル
├── services/
│   ├── lux_service.dart          # 照度取得（プラットフォーム分岐）
│   ├── notification_service.dart # 通知スケジュール管理
│   └── settings_service.dart     # shared_preferencesラッパー（isPremium含む）
├── screens/
│   ├── main_screen.dart          # メイン計測画面
│   ├── settings_screen.dart      # 設定画面
│   └── exam_screen.dart          # 睡眠健康チェック試験画面（課金機能 scaffold）
└── widgets/
    ├── lux_display.dart          # Lux値表示
    ├── lux_gauge.dart            # 対数スケールゲージ
    ├── advice_card.dart          # アドバイス・フィードバックカード
    ├── time_period_label.dart    # 時間帯ラベル・アイコン
    ├── ad_banner.dart            # AdMobバナー
    └── premium_gate.dart         # 課金前ロック状態UI

ios/Runner/
├── LuxMeasurementPlugin.swift    # AVFoundationでlux算出（独自実装）
├── AppDelegate.swift             # プラグイン登録
└── Info.plist                    # カメラ権限・GADApplicationIdentifier

android/app/src/main/
├── kotlin/com/orthosleepacademy/app/MainActivity.kt  # SensorManagerでlux取得
└── AndroidManifest.xml           # 権限・AdMob App ID
```

---

## 重要な設計・実装メモ

### iOS lux算出式
```
EV100 = log2(N² / t) - log2(ISO / 100)
lux   = 2.5 × 2^EV100

N = 1.78（iPhoneの標準カメラFナンバー）
t = 露出時間（秒）
```
- `+` ではなく **`-`** が正しい（ISOは大きいほど暗い環境 → luxを下げる方向）
- MethodChannel名: `com.ortholutxmeter/lux`（Bundle ID 変更後も変更なし）
- EventChannel名: `com.ortholutxmeter/lux_stream`（同上）

### 光量基準値
| 時間帯 | 時刻 | 基準値 |
|---|---|---|
| 朝 | 起床時刻〜11:59 | 2,500 lux 以上 |
| 昼 | 12:00〜17:59 | 基準なし（参考表示） |
| 夜 | 18:00〜 / 0:00〜起床時刻前 | 50 lux 以下 |
| 上限 | — | 300,000 lux |

### 時間帯判定ロジック（LuxFeedback.evaluate）
```
1. 18:00以降          → 夜
2. 0:00〜起床時刻前   → 夜（深夜〜早朝）
3. 起床時刻〜11:59    → 朝
4. 12:00〜17:59       → 昼
```
- 起床時刻は SettingsService から取得（デフォルト 07:00）
- MainScreen は 1 分ごとのタイマーで時間帯を再評価

### 通知仕様
| 通知ID | 種類 | タイミング | メッセージ |
|---|---|---|---|
| 1 | 起床通知 | 設定した起床時刻 | 「朝の光を浴びる時間ですよ」 |
| 2 | 就寝前通知 | 就寝時刻の **45分前** | 「あと45分で就寝時間です。光を抑え、寝る準備をしましょう」 |

- 毎日繰り返し（`matchDateTimeComponents: DateTimeComponents.time`）
- タイムゾーン対応：`flutter_timezone` で端末のタイムゾーンを取得
- 通知チャンネルID: `wake_channel`（起床）/ `sleep_channel`（就寝前）

### シェア機能
- `RepaintBoundary` でメイン計測エリアをキャプチャ（pixelRatio: 3.0）
- PNG として `getTemporaryDirectory()` に保存し `share_plus` で共有
- テキスト: `「現在の照度：{lux} lux【ORTHO SLEEP ACADEMY】」`

### AdMob ID
| | App ID | Ad Unit ID |
|---|---|---|
| iOS | `ca-app-pub-7430026135431315~4840039616` | `ca-app-pub-7430026135431315/9683104503` |
| Android | `ca-app-pub-7430026135431315~8587712935` | `ca-app-pub-7430026135431315/7300483745` |

---

## 課金機能（将来実装）

### 概要
試験画面（睡眠健康チェック試験）への受験資格を買い切り課金で提供予定。

### 現在の実装状態（scaffold 済み）
| ファイル | 内容 |
|---|---|
| `settings_service.dart` | `isPremium` フラグ（SharedPreferences）|
| `screens/exam_screen.dart` | 試験画面（未購入→ゲート、購入済み→試験コンテンツ） |
| `widgets/premium_gate.dart` | ロック状態UI・購入ボタン |

### 課金実装時のTODO
1. `pubspec.yaml` に `purchases_flutter`（RevenueCat）を追加
2. App Store Connect / Google Play Console で課金アイテムを登録
3. `ExamScreen._handlePurchase()` に購入処理を実装
4. 購入完了後に `settings.setIsPremium(true)` を呼ぶ
5. `_ExamContent` に実際の試験問題・採点ロジックを実装
6. プライバシーポリシーに課金・返金の記載を追加

---

## デザイン

| 項目 | 値 |
|---|---|
| スタイル | シンプルミニマル |
| 背景色 | `#0E1A3A`（ネイビー） |
| メインカラー | `#5BA4CF`（スカイブルー） |
| アクセントカラー | `#7EC8E3` |
| テキスト | `#FFFFFF`（白） |
| サブテキスト | `#AEC6E8` |
| ダークモード | 非対応 |

---

## 開発コマンド

```bash
# 通常起動（実機 or シミュレーター）
flutter run

# 静的解析
flutter analyze

# iOSリリースビルド
flutter clean && flutter pub get
flutter build ios --release
# → Xcode で Archive → App Store Connect へ Upload

# Android リリースビルド（環境変数を先に設定）
export STORE_FILE=~/ortho-luxmeter-release.jks
export STORE_PASSWORD=xxx
export KEY_PASSWORD=xxx
flutter build appbundle --release
# 出力: build/app/outputs/bundle/release/app-release.aab

# クリーンビルド
flutter clean && flutter pub get
```

---

## リリース情報

| 項目 | 内容 |
|---|---|
| Bundle ID | `com.orthosleepacademy.app` |
| App Store Connect | 新規登録済み（TestFlight 準備中） |
| App Store ID（iOS） | `6760633019` |
| Android Application ID | `com.orthosleepacademy.app` |
| Google Play Console | 新規登録済み（内部テスト準備中） |
| プライバシーポリシーURL | `https://ch69bt.github.io/Ortho-Luxmeter/privacy-policy.html` |
| GitHub | `https://github.com/ch69bt/Ortho-Luxmeter` |

### Android 署名設定
- キーエイリアス: `ortho-luxmeter`
- キーストアファイル: 環境変数 `STORE_FILE`（未設定時は `~/ortho-luxmeter-release.jks`）
- パスワード: 環境変数 `KEY_PASSWORD` / `STORE_PASSWORD`
- 環境変数はターミナルセッションごとにリセットされるため、`~/.zshrc` への永続化を推奨

---

## 注意事項

- iOSシミュレーターではカメラが使えないため lux = 0 になる（実機テスト必須）
- Swift側のコード変更はホットリロード不可（`flutter run` で再起動が必要）
- `flutter clean` 後は必ず `flutter pub get` → `flutter build ios --release` を実行してからXcodeでArchiveする
- MethodChannel / EventChannel 名は `com.ortholutxmeter/lux` のまま（iOS Swift 側と一致させる必要があるため Bundle ID 変更時に変更しなかった）
- フォルダ名は `Ortho-Luxmeter` のまま（動作に影響なし。GitHub ごとリネームする場合は `git remote set-url` も更新する）
