import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/lux_thresholds.dart';

class LuxGauge extends StatelessWidget {
  final double lux;
  final Color gaugeColor;

  const LuxGauge({super.key, required this.lux, required this.gaugeColor});

  /// 対数スケールで0〜1に正規化（0 lux → 0, 300,000 lux → 1）
  double _logNormalize(double value) {
    if (value <= 0) return 0;
    final logMax = log(LuxThresholds.maxLux + 1);
    final logVal = log(value + 1);
    return (logVal / logMax).clamp(0.0, 1.0);
  }

  // ガイドマーカー（lux値, 短縮ラベル, 環境説明）
  static const _markers = [
    _GuideMarker(10, '10', '夜間照明'),
    _GuideMarker(100, '100', '一般照明'),
    _GuideMarker(1000, '1k', '日陰'),
    _GuideMarker(10000, '10k', '曇り空'),
    _GuideMarker(100000, '100k', '直射日光'),
  ];

  /// 現在のlux値に対応する環境説明を返す
  String _currentEnvironment() {
    if (lux < 1) return '暗闇';
    if (lux < 10) return '薄暗い室内';
    if (lux < 100) return '夕暮れ・夜間照明';
    if (lux < 500) return '室内（一般照明）';
    if (lux < 3000) return '室内（窓際）';
    if (lux < 10000) return '日陰（屋外）';
    if (lux < 20000) return '明るい曇り空';
    if (lux < 100000) return '快晴の屋外';
    return '直射日光';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _logNormalize(lux);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 現在の環境ラベル
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentEnvironment(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${lux.toStringAsFixed(0)} lux',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // プログレスバー＋目盛り
            SizedBox(
              height: 14,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // 背景トラック
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: barWidth,
                      height: 10,
                      color: AppColors.surface,
                    ),
                  ),
                  // アニメーション付きフィル
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, value, _) {
                        return Container(
                          width: barWidth * value,
                          height: 10,
                          color: gaugeColor,
                        );
                      },
                    ),
                  ),
                  // ガイド目盛り（縦線）
                  for (final marker in _markers)
                    Positioned(
                      left: _logNormalize(marker.lux) * barWidth - 0.5,
                      child: Container(
                        width: 1.5,
                        height: 14,
                        color: AppColors.background.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 3),

            // ガイドラベル（lux値）
            SizedBox(
              height: 13,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 左端ラベル
                  const Positioned(
                    left: 0,
                    child: Text('0', style: _labelStyle),
                  ),
                  // 各マーカーのラベル
                  for (final marker in _markers)
                    Positioned(
                      left: (_logNormalize(marker.lux) * barWidth - 10)
                          .clamp(0.0, barWidth - 20),
                      child: Text(marker.label, style: _labelStyle),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static const _labelStyle = TextStyle(
    fontSize: 9,
    color: AppColors.textSecondary,
  );
}

class _GuideMarker {
  final double lux;
  final String label;
  final String environment;

  const _GuideMarker(this.lux, this.label, this.environment);
}
