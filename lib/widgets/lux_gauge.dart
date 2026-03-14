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

  @override
  Widget build(BuildContext context) {
    final progress = _logNormalize(lux);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: AppColors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: _labelStyle),
            Text('300,000', style: _labelStyle),
          ],
        ),
      ],
    );
  }

  static const _labelStyle = TextStyle(
    fontSize: 10,
    color: AppColors.textSecondary,
  );
}
