import 'package:flutter/material.dart';
import '../constants/lux_thresholds.dart';
import '../constants/colors.dart';

class LuxFeedback {
  final TimePeriod period;
  final String periodLabel;
  final IconData periodIcon;
  final String adviceText;
  final String feedbackText;
  final String thresholdLabel;
  final Color gaugeColor;

  const LuxFeedback({
    required this.period,
    required this.periodLabel,
    required this.periodIcon,
    required this.adviceText,
    required this.feedbackText,
    required this.thresholdLabel,
    required this.gaugeColor,
  });

  static LuxFeedback evaluate(double lux, {int wakeHour = 7, int wakeMinute = 0}) {
    final now = DateTime.now();
    final hour = now.hour;
    final currentMinutes = hour * 60 + now.minute;
    final wakeMinutes = wakeHour * 60 + wakeMinute;

    final TimePeriod period;
    if (hour >= TimePeriodBoundary.afternoonEndHour) {
      // 18:00以降 → 夜
      period = TimePeriod.night;
    } else if (currentMinutes < wakeMinutes) {
      // 0:00〜起床時刻前（深夜〜早朝）→ 夜
      period = TimePeriod.night;
    } else if (hour < TimePeriodBoundary.morningEndHour) {
      // 起床時刻〜11:59 → 朝
      period = TimePeriod.morning;
    } else {
      // 12:00〜17:59 → 昼
      period = TimePeriod.afternoon;
    }

    switch (period) {
      case TimePeriod.morning:
        final isGood = lux >= LuxThresholds.morningMin;
        return LuxFeedback(
          period: period,
          periodLabel: '朝',
          periodIcon: Icons.wb_sunny,
          adviceText: LuxAdvice.morningAdvice,
          feedbackText: isGood ? LuxAdvice.morningGood : LuxAdvice.morningBad,
          thresholdLabel: LuxAdvice.morningThresholdLabel,
          gaugeColor: isGood ? AppColors.success : AppColors.warning,
        );
      case TimePeriod.afternoon:
        return const LuxFeedback(
          period: TimePeriod.afternoon,
          periodLabel: '昼',
          periodIcon: Icons.cloud,
          adviceText: LuxAdvice.afternoonAdvice,
          feedbackText: LuxAdvice.afternoonNeutral,
          thresholdLabel: LuxAdvice.afternoonThresholdLabel,
          gaugeColor: AppColors.secondary,
        );
      case TimePeriod.night:
        final isGood = lux <= LuxThresholds.nightMax;
        return LuxFeedback(
          period: period,
          periodLabel: '夜',
          periodIcon: Icons.nightlight_round,
          adviceText: LuxAdvice.nightAdvice,
          feedbackText: isGood ? LuxAdvice.nightGood : LuxAdvice.nightBad,
          thresholdLabel: LuxAdvice.nightThresholdLabel,
          gaugeColor: isGood ? AppColors.success : AppColors.warning,
        );
    }
  }
}
