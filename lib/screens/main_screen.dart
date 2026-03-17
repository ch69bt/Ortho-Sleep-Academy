import 'dart:async';
import 'package:flutter/material.dart';

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
import 'exam_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _luxService = LuxService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('ORTHO SLEEP ACADEMY', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.school_outlined, color: AppColors.textSecondary),
            tooltip: '睡眠知識検定試験',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExamScreen()),
              );
            },
          ),
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
                  const SizedBox(height: 16),
                ],
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
