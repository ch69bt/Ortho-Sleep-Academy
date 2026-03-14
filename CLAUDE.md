# Ortho Luxmeter — CLAUDE.md

> 睡眠の質改善をサポートするスマートフォン向け照度計アプリ
> Flutter（iOS / Android）

---

## プロジェクト概要

| 項目 | 内容 |
|---|---|
| アプリ名 | Ortho Luxmeter |
| 目的 | 起床時の日光浴・日中の光量確認・夜間の光量抑制を支援 |
| プラットフォーム | iOS / Android |
| 言語 | 日本語のみ |
| Bundle ID | `com.ortholutxmeter.orthoLuxmeter` |
| バージョン | 1.0.0+1 |

---

## 技術スタック

| レイヤー | 技術 |
|---|---|
| フレームワーク | Flutter 3.x（Dart 3.x） |
| iOS 照度取得 | AVFoundation（MethodChannel / EventChannel） |
| Android 照度取得 | SensorManager TYPE_LIGHT（MethodChannel / EventChannel） |
| 通知 | flutter_local_notifications + timezone |
| 広告 | google_mobile_ads（AdMob バナーのみ） |
| シェア | share_plus |
| 設定永続化 | shared_preferences |
| メール起動 | url_launcher |
| 権限管理 | permission_handler |

---

## ディレクトリ構成

```
lib/
├── main.dart                     # エントリーポイント（AdMob初期化）
├── app.dart                      # MaterialApp・テーマ定義
├── constants/
│   ├── colors.dart               # カラーパレット
│   ├── text_styles.dart          # タイポグラフィ
│   └── lux_thresholds.dart       # 光量基準値・時間帯定義・アドバイステキスト
├── models/
│   └── lux_feedback.dart         # 時間帯判定・フィードバックモデル
├── services/
│   ├── lux_service.dart          # 照度取得（プラットフォーム分岐）
│   ├── notification_service.dart # 通知スケジュール管理
│   └── settings_service.dart     # shared_preferencesラッパー
├── screens/
│   ├── main_screen.dart          # メイン計測画面
│   └── settings_screen.dart      # 設定画面
└── widgets/
    ├── lux_display.dart          # Lux値表示
    ├── lux_gauge.dart            # 対数スケールゲージ
    ├── advice_card.dart          # アドバイス・フィードバックカード
    ├── time_period_label.dart    # 時間帯ラベル・アイコン
    └── ad_banner.dart            # AdMobバナー

ios/Runner/
├── LuxMeasurementPlugin.swift    # AVFoundationでlux算出（独自実装）
├── AppDelegate.swift             # プラグイン登録
└── Info.plist                    # カメラ権限・GADApplicationIdentifier

android/app/src/main/
├── kotlin/.../MainActivity.kt    # SensorManagerでlux取得
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
- MethodChannel名: `com.ortholutxmeter/lux`
- EventChannel名: `com.ortholutxmeter/lux_stream`

### 光量基準値
| 時間帯 | 時刻 | 基準値 |
|---|---|---|
| 朝 | ～11:59 | 2,500 lux 以上 |
| 昼 | 12:00～17:59 | 基準なし（参考表示） |
| 夜 | 18:00～ | 50 lux 以下 |
| 上限 | — | 300,000 lux |

### AdMob ID
| | App ID | Ad Unit ID |
|---|---|---|
| iOS | `ca-app-pub-7430026135431315~6728502630` | `ca-app-pub-7430026135431315/6032201355` |
| Android | `ca-app-pub-7430026135431315~3845021715` | `ca-app-pub-7430026135431315/6971077613` |

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

# リリースビルド
flutter build ios --release
flutter build ipa

# クリーンビルド
flutter clean && flutter pub get
```

---

## リリース情報

| 項目 | 内容 |
|---|---|
| Bundle ID | `com.ortholutxmeter.orthoLuxmeter` |
| App Store Connect | 登録済み |
| プライバシーポリシーURL | `https://ch69bt.github.io/Ortho-Luxmeter/privacy-policy.html` |
| GitHub | `https://github.com/ch69bt/Ortho-Luxmeter` |

---

## 注意事項

- iOSシミュレーターではカメラが使えないため lux = 0 になる（実機テスト必須）
- Swift側のコード変更はホットリロード不可（`flutter run` で再起動が必要）
- `flutter clean` 後は必ず `flutter pub get` → `flutter build ios --release` を実行してからXcodeでArchiveする
