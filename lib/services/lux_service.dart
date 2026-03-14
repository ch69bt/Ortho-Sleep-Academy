import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../constants/lux_thresholds.dart';

/// 照度取得サービス
/// iOS: MethodChannel / EventChannel経由でAVFoundationを使用
/// Android: sensors_plusパッケージの照度センサーを使用
class LuxService {
  static const _methodChannel = MethodChannel('com.ortholutxmeter/lux');
  static const _eventChannel = EventChannel('com.ortholutxmeter/lux_stream');

  StreamSubscription? _subscription;
  final _controller = StreamController<double>.broadcast();

  Stream<double> get luxStream => _controller.stream;

  Future<void> start() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _startIOS();
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await _startAndroid();
    }
  }

  Future<void> _startIOS() async {
    try {
      await _methodChannel.invokeMethod('startMeasurement');
      _subscription = _eventChannel.receiveBroadcastStream().listen((value) {
        final lux = (value as num).toDouble().clamp(
              LuxThresholds.minLux,
              LuxThresholds.maxLux,
            );
        _controller.add(lux);
      });
    } on PlatformException catch (e) {
      debugPrint('LuxService iOS error: $e');
      _controller.addError(e);
    }
  }

  Future<void> _startAndroid() async {
    // Android: sensors_plus の LightSensor を使用
    // ネイティブ側は android/app 配下で実装済みの想定
    // ここではMethodChannelで統一して呼び出す
    try {
      await _methodChannel.invokeMethod('startMeasurement');
      _subscription = _eventChannel.receiveBroadcastStream().listen((value) {
        final lux = (value as num).toDouble().clamp(
              LuxThresholds.minLux,
              LuxThresholds.maxLux,
            );
        _controller.add(lux);
      });
    } on PlatformException catch (e) {
      debugPrint('LuxService Android error: $e');
      _controller.addError(e);
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _methodChannel.invokeMethod('stopMeasurement');
    } catch (_) {}
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
