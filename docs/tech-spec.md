# 技術仕様書 — Ortho Luxmeter

> アプリ名：Ortho Luxmeter
> プラットフォーム：iOS / Android（Flutter）
> Version 1.0

---

## 目次

1. [開発環境・バージョン要件](#1-開発環境バージョン要件)
2. [使用パッケージ一覧](#2-使用パッケージ一覧)
3. [ディレクトリ構成](#3-ディレクトリ構成)
4. [iOS 照度算出ロジック](#4-ios-照度算出ロジック)
5. [Android 照度取得ロジック](#5-android-照度取得ロジック)
6. [通知実装詳細](#6-通知実装詳細)
7. [状態管理方針](#7-状態管理方針)
8. [AdMob 実装詳細](#8-admob-実装詳細)
9. [権限リクエストフロー](#9-権限リクエストフロー)
10. [シェア実装](#10-シェア実装)
11. [フィードバック実装](#11-フィードバック実装)
12. [ビルド・リリース設定](#12-ビルドリリース設定)

---

## 1. 開発環境・バージョン要件

| 項目 | バージョン / 内容 |
|---|---|
| Flutter SDK | 3.x.x（最新安定版） |
| Dart SDK | 3.x.x |
| iOS Deployment Target | iOS 14.0 以上 |
| Android Minimum SDK | API 21（Android 5.0）以上 |
| Xcode | 15.x 以上 |
| Android Studio | 最新安定版 |

---

## 2. 使用パッケージ一覧

| パッケージ名 | バージョン | 用途 | 選定理由 |
|---|---|---|---|
| `google_mobile_ads` | ^5.x.x | AdMob バナー広告 | Google公式プラグイン。iOSおよびAndroidのAdMob SDKをFlutterから利用可能。 |
| `flutter_local_notifications` | ^18.x.x | ローカルプッシュ通知 | iOS・Android両対応。スケジュール通知（日次繰り返し）にも対応。 |
| `share_plus` | ^10.x.x | SNSシェア | クロスプラットフォーム対応。ファイル（画像）とテキストの同時シェアが可能。 |
| `shared_preferences` | ^2.x.x | 設定値の永続化（時刻・通知ON/OFF） | シンプルなKey-Valueストレージ。設定値の保存に最適。 |
| `camera` | ^0.11.x | iOS カメラアクセス（照度算出用） | Flutter公式カメラプラグイン。AVFoundationのカメラセッション制御の基盤として使用。 |
| `sensors_plus` | ^6.x.x | Android 照度センサーアクセス | SensorManager（TYPE_LIGHT）のFlutterラッパー。StreamでLightSensorEventを受信可能。 |
| `timezone` | ^0.10.x | タイムゾーン対応（通知スケジュール用） | `flutter_local_notifications`の`zonedSchedule`の依存パッケージ。 |
| `flutter_timezone` | ^2.x.x | 現在のタイムゾーン取得 | デバイスのローカルタイムゾーンを文字列で取得。`timezone`パッケージと組み合わせて使用。 |
| `permission_handler` | ^11.x.x | カメラ・通知権限リクエスト | iOS・Android両対応のクロスプラットフォーム権限管理。 |
| `url_launcher` | ^6.x.x | フィードバックのメールアプリ起動 | `mailto:`スキームのURL起動に使用。 |

---

## 3. ディレクトリ構成

`lib/` 配下の詳細構成を以下に示す。

```
lib/
├── main.dart                      # エントリーポイント。パッケージ初期化処理（通知・タイムゾーン等）
├── app.dart                       # MaterialApp定義・テーマ（カラー・フォント）設定
├── constants/
│   ├── colors.dart                # カラーパレット定数（AppColors クラス）
│   ├── text_styles.dart           # タイポグラフィ定数（AppTextStyles クラス）
│   └── lux_thresholds.dart        # 光量基準値（朝:2500 / 夜:50 lux）・時間帯境界定義
├── models/
│   └── lux_feedback.dart          # 時間帯Enum・フィードバックメッセージのデータモデル
├── services/
│   ├── lux_service.dart           # 照度取得のプラットフォーム分岐（iOS: MethodChannel / Android: sensors_plus）・計算ロジック
│   ├── notification_service.dart  # 通知初期化・スケジュール登録・キャンセル管理
│   └── settings_service.dart      # shared_preferencesのラッパー（通知ON/OFF・時刻の読み書き）
├── screens/
│   ├── main_screen.dart           # メイン計測画面（StatefulWidget）
│   └── settings_screen.dart       # 設定画面（StatefulWidget）
└── widgets/
    ├── lux_display.dart           # Lux値表示ウィジェット（数値＋単位、アニメーション付き）
    ├── lux_gauge.dart             # プログレスバー（対数スケール・色条件分岐）
    ├── advice_card.dart           # アドバイス・フィードバック・基準値を表示するカードウィジェット
    ├── time_period_label.dart     # 時間帯ラベル・アイコンウィジェット
    └── ad_banner.dart             # AdMobバナーウィジェット（Scaffold.bottomNavigationBarに配置）
```

---

## 4. iOS 照度算出ロジック

### 概要

iOSには環境光センサーへの直接アクセスAPIが公開されていないため、AVFoundationのカメラフレームからISO値・シャッタースピード（露出時間）を取得し、照度（lux）を近似算出する。

FlutterからネイティブiOSのAVFoundationにアクセスするため、**Method Channel** および **Event Channel** を使用する。

---

### 算出式

```
EV（露出値）= log2(N² / t)
  N : Fナンバー（絞り値）※ iOSの場合はハードコードされた固定値（例: f/1.8）
  t : 露出時間（秒）

Lux = 2.5 × 2^EV
  ※ ISO 100相当に正規化した近似式
  ※ 実際のFナンバーはデバイスにより異なるが、iPhone標準カメラは f/1.8 前後
```

> 注意：この算出式はあくまで近似値であり、正確な照度計の代替ではない。アプリ内の注意表示にもその旨を記載する。

---

### Method Channel / Event Channel 設計

| 項目 | 値 |
|---|---|
| Method Channel 名 | `com.ortholutxmeter/lux` |
| Event Channel 名 | `com.ortholutxmeter/lux_stream` |

#### メソッド一覧（Method Channel）

| メソッド名 | 方向 | 説明 |
|---|---|---|
| `startMeasurement` | Dart → Native | カメラセッション開始・ストリーム配信開始 |
| `stopMeasurement` | Dart → Native | カメラセッション停止・ストリーム配信停止 |

#### ストリーム（Event Channel）

- `startMeasurement` 呼び出し後、算出したlux値（`double`）をリアルタイムで `FlutterEventSink` を通じてDart側に配信する。

---

### ネイティブ実装（iOS Swift）の概要

```swift
// AppDelegate.swift または専用のLuxPlugin.swift に実装

// 1. AVCaptureSession を生成・設定
let session = AVCaptureSession()

// 2. AVCaptureVideoDataOutput でフレームをキャプチャ
let videoOutput = AVCaptureVideoDataOutput()
videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "lux.queue"))
session.addOutput(videoOutput)

// 3. captureOutput(_:didOutput:from:) 内でISO・露出時間を取得
func captureOutput(_ output: AVCaptureOutput,
                   didOutput sampleBuffer: CMSampleBuffer,
                   from connection: AVCaptureConnection) {
    guard let metadataDict = CMGetAttachment(
        sampleBuffer,
        key: kCGImagePropertyExifDictionary,
        attachmentModeOut: nil
    ) as? [String: Any] else { return }

    let iso = /* CMSampleBuffer から ISO を取得 */
    let exposureTime = /* CMSampleBuffer から露出時間を取得 */

    let fNumber: Double = 1.8  // 固定値（デバイス依存）
    let ev = log2((fNumber * fNumber) / exposureTime)
    let lux = 2.5 * pow(2.0, ev)

    // 4. FlutterEventSink を通じてDartに送信
    eventSink?(lux)
}
```

---

## 5. Android 照度取得ロジック

### 概要

Androidでは `SensorManager` の `TYPE_LIGHT` センサーを使用して照度を取得する。`sensors_plus` パッケージの `LightSensorEvent` を Stream として受信するため、ネイティブコードの追加実装は不要。

---

### 実装概要

```dart
import 'package:sensors_plus/sensors_plus.dart';

// sensors_plus パッケージを使用
StreamSubscription<LightSensorEvent>? _lightSensorSubscription;

void startMeasurement() {
  _lightSensorSubscription = SensorsPlatform.instance.lightSensorEvents.listen(
    (LightSensorEvent event) {
      double lux = event.lux;
      // 300,000 lux 以上は上限値として扱う
      if (lux > 300000) lux = 300000;
      // UIの更新処理へ渡す
    },
  );
}

void stopMeasurement() {
  _lightSensorSubscription?.cancel();
  _lightSensorSubscription = null;
}
```

> 注意：`sensors_plus` のTYPE_LIGHTセンサーはデバイスによって精度が異なる。センサーが搭載されていない端末では0が返ることがある。

---

## 6. 通知実装詳細

### 初期化フロー

`main.dart` の `main()` 内で以下の順序で初期化を行う。

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. flutter_local_notifications の初期化
  await NotificationService.initialize();

  // 2. timezone パッケージの初期化
  tz.initializeTimeZones();
  final String localTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(localTimeZone));

  runApp(const App());
}
```

#### プラットフォーム別初期化

- **iOS**：通知権限リクエスト（`requestPermission`）を初期化時に実行
- **Android 8.0（API 26）以上**：通知チャンネルを作成（`AndroidNotificationChannel`）

---

### 通知スケジュール仕様

| 通知種別 | タイミング | 繰り返し | 通知ID |
|---|---|---|---|
| 起床通知 | 毎日、設定した起床時刻 | 日次繰り返し | `1` |
| 就寝前通知 | 毎日、設定した就寝時刻の **45分前** | 日次繰り返し | `2` |

#### スケジュール実装

```dart
// flutter_local_notifications の zonedSchedule を使用
await flutterLocalNotificationsPlugin.zonedSchedule(
  notificationId,           // 1 または 2
  notificationTitle,
  notificationBody,
  _nextInstanceOf(hour, minute),
  const NotificationDetails(...),
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
  matchDateTimeComponents: DateTimeComponents.time,  // 日次繰り返し
);

TZDateTime _nextInstanceOf(int hour, int minute) {
  final TZDateTime now = TZDateTime.now(tz.local);
  TZDateTime scheduledDate = TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}
```

---

### 通知コンテンツ例

| 通知種別 | タイトル | 本文 |
|---|---|---|
| 起床通知 | 「おはようございます」 | 「起床後に日光を浴びて体内時計をリセットしましょう ☀」 |
| 就寝前通知 | 「そろそろ就寝の準備を」 | 「部屋の光を暗くしてメラトニンの分泌を止めないようにしましょう 🌙」 |

---

## 7. 状態管理方針

本アプリは画面数・状態量ともに少ないため、追加の状態管理パッケージは導入しない。

| 方針 | 内容 |
|---|---|
| 状態管理手法 | Flutter標準の `StatefulWidget` + `setState` を使用 |
| 理由 | 画面が2枚・共有状態がほぼないシンプルな構成のため、ProviderやRiverpodは過剰 |
| リアルタイム更新 | Lux値のリアルタイム更新は `StreamSubscription` で管理し、`setState` で画面を再描画 |
| 設定値の永続化 | `SettingsService`（`shared_preferences`のラッパー）を通じて読み書きする |

---

## 8. AdMob 実装詳細

### バナー設定

| 項目 | 仕様 |
|---|---|
| バナーサイズ | `AdSize.banner`（標準 320×50）または `AdSize.getAnchoredAdaptiveBannerAdSize`（アダプティブ） |
| 配置 | `Scaffold` の `bottomNavigationBar` スロットに `AdBannerWidget` を配置 |
| AdUnit ID（テスト） | `ca-app-pub-3940256099942544/6300978111`（Google提供のテストID） |

### Ad配置コード概要

```dart
// main_screen.dart の Scaffold
Scaffold(
  appBar: ...,
  body: ...,
  bottomNavigationBar: const AdBannerWidget(),  // バナー広告を最下部に固定
)
```

### AdUnit IDの切り替え

本番用AdUnit IDはリリース前に `--dart-define` で環境変数として渡して管理する。テスト時はGoogleが提供するテストIDを使用し、実機テスト時の誤クリックによる規約違反を防ぐ。

```bash
# ビルド時にAdUnit IDを渡す例
flutter build ios --dart-define=ADMOB_UNIT_ID=ca-app-pub-xxxx/xxxx
flutter build apk --dart-define=ADMOB_UNIT_ID=ca-app-pub-xxxx/xxxx
```

```dart
// Dart側での取得
const String adUnitId = String.fromEnvironment(
  'ADMOB_UNIT_ID',
  defaultValue: 'ca-app-pub-3940256099942544/6300978111',  // テストID
);
```

---

## 9. 権限リクエストフロー

### iOS（Info.plist）

`ios/Runner/Info.plist` に以下のキーを追加する。

```xml
<key>NSCameraUsageDescription</key>
<string>照度を計測するためにカメラを使用します</string>
```

> 通知権限は `flutter_local_notifications` の初期化時にシステムダイアログで自動リクエストされるため、`Info.plist` への個別記載は不要。

### Android（AndroidManifest.xml）

`android/app/src/main/AndroidManifest.xml` に以下のパーミッションを追加する。

```xml
<!-- カメラ権限（照度算出用）-->
<uses-permission android:name="android.permission.CAMERA" />

<!-- 再起動後の通知復元 -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- 正確なアラーム（Android 12以上、API 31+） -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

<!-- 通知表示（Android 13以上、API 33+） -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### 実行時権限リクエスト（Dart側）

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  // カメラ権限（iOS・Android共通）
  final cameraStatus = await Permission.camera.request();

  // 通知権限（Android 13以上）
  final notificationStatus = await Permission.notification.request();

  if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
    // 権限拒否時の案内処理（設定アプリへ誘導など）
  }
}
```

---

## 10. シェア実装

画面全体をスクリーンショットとして取得し、`share_plus` でシェアシートを起動する。

### スクリーンショット取得

`RepaintBoundary` でシェア対象ウィジェットを囲み、`RenderRepaintBoundary` を通じて画像データを取得する。

```dart
// main_screen.dart
final GlobalKey _repaintKey = GlobalKey();

// ウィジェットをRepaintBoundaryで囲む
RepaintBoundary(
  key: _repaintKey,
  child: /* シェアしたいウィジェット */,
)

// シェアボタンのonPressed
Future<void> _onShareTapped() async {
  final RenderRepaintBoundary boundary =
      _repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List pngBytes = byteData!.buffer.asUint8List();

  // 一時ファイルに書き込み
  final tempDir = await getTemporaryDirectory();
  final file = await File('${tempDir.path}/ortho_luxmeter_share.png').writeAsBytes(pngBytes);

  // share_plus でシェアシート起動
  await Share.shareXFiles(
    [XFile(file.path)],
    text: '現在の照度：$_currentLux lux【Ortho Luxmeter】',
  );
}
```

---

## 11. フィードバック実装

`url_launcher` を使用して `mailto:` スキームでメールアプリを起動する。

```dart
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

Future<void> _launchFeedbackEmail() async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'support@example.com',
    queryParameters: {
      'subject': '[Ortho Luxmeter] フィードバック',
      'body': 'バージョン: 1.0.0\nOS: ${Platform.operatingSystem}\n\n',
    },
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    // メールアプリが見つからない場合のエラーハンドリング
  }
}
```

---

## 12. ビルド・リリース設定

### アプリ識別子

| 項目 | 値 |
|---|---|
| iOS Bundle ID | `com.ortholutxmeter.app`（仮） |
| Android Application ID | `com.ortholutxmeter.app`（仮） |

### Dart Define によるフラグ管理

| フラグ | 説明 |
|---|---|
| `--dart-define=ENV=production` | 本番ビルドフラグ。AdUnit IDや各種エンドポイントの切り替えに使用。 |
| `--dart-define=ADMOB_UNIT_ID=xxx` | 本番用AdMob AdUnit IDの注入。 |

### 配布チャネル

| プラットフォーム | 配布方法 |
|---|---|
| iOS | App Store Connect 経由（TestFlightによるベータ配布 → 本番審査） |
| Android | Google Play Console 経由（内部テスト → クローズドテスト → 本番公開） |

---

*本ドキュメントはOrtho Luxmeter v1.0 の技術仕様を定義するものです。*
