import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/lux_feedback.dart';
import '../services/lux_service.dart';
import '../services/settings_service.dart';
import '../widgets/time_period_label.dart';
import '../widgets/lux_display.dart';
import '../widgets/lux_gauge.dart';
import '../widgets/advice_card.dart';
import '../widgets/ad_banner.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _luxService = LuxService();
  final _screenshotKey = GlobalKey();
  final _shareButtonKey = GlobalKey();
  StreamSubscription<double>? _subscription;

  double _currentLux = 0;
  LuxFeedback _feedback = LuxFeedback.evaluate(0);
  int _wakeHour = 7;
  int _wakeMinute = 0;

  // 時間帯を定期的に再評価するタイマー
  Timer? _periodTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _startMeasurement();
    // 1分ごとに時間帯を再評価
    _periodTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _feedback = LuxFeedback.evaluate(_currentLux, wakeHour: _wakeHour, wakeMinute: _wakeMinute);
        });
      }
    });
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.create();
    if (mounted) {
      setState(() {
        _wakeHour = settings.wakeHour;
        _wakeMinute = settings.wakeMinute;
        _feedback = LuxFeedback.evaluate(_currentLux, wakeHour: _wakeHour, wakeMinute: _wakeMinute);
      });
    }
  }

  void _startMeasurement() {
    _luxService.start();
    _subscription = _luxService.luxStream.listen((lux) {
      if (mounted) {
        setState(() {
          _currentLux = lux;
          _feedback = LuxFeedback.evaluate(lux, wakeHour: _wakeHour, wakeMinute: _wakeMinute);
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _luxService.dispose();
    _periodTimer?.cancel();
    super.dispose();
  }

  Future<void> _share() async {
    // ボタンの位置を非同期処理前に同期的に取得
    final shareBox = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final shareOrigin = shareBox != null
        ? shareBox.localToGlobal(Offset.zero) & shareBox.size
        : Rect.fromLTWH(0, 400, 100, 50);

    try {
      final boundary = _screenshotKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('Share error: RepaintBoundary not found');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('シェアの準備ができていません。もう一度お試しください。')),
          );
        }
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ortho_luxmeter_share.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '現在の照度：${_currentLux.toStringAsFixed(0)} lux【Ortho Luxmeter】',
        sharePositionOrigin: shareOrigin,
      );
    } catch (e) {
      debugPrint('Share error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('シェアに失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Ortho Luxmeter', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textSecondary),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              _loadSettings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _screenshotKey,
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 時間帯ラベル
                      TimePeriodLabel(feedback: _feedback),
                      const SizedBox(height: 32),

                      // Lux値
                      LuxDisplay(lux: _currentLux),
                      const SizedBox(height: 24),

                      // ゲージ
                      LuxGauge(
                        lux: _currentLux,
                        gaugeColor: _feedback.gaugeColor,
                      ),
                      const SizedBox(height: 32),

                      // アドバイスカード
                      AdviceCard(feedback: _feedback),
                      const SizedBox(height: 16),

                      // 注意表示
                      Text(
                        '※この値はあくまで参考値です。正確な照度計ではありません。',
                        style: AppTextStyles.disclaimer,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // シェアボタン
                      OutlinedButton.icon(
                        key: _shareButtonKey,
                        onPressed: _share,
                        icon: const Icon(
                          Icons.share,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                        label: const Text(
                          'この画面をシェアする',
                          style: TextStyle(color: AppColors.secondary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.secondary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // バナー広告
          const AdBannerWidget(),
        ],
      ),
    );
  }
}
