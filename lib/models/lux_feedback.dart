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

  static LuxFeedback evaluate(double lux) {
    final now = DateTime.now();
    final hour = now.hour;

    final TimePeriod period;
    if (hour < TimePeriodBoundary.morningEndHour) {
      period = TimePeriod.morning;
    } else if (hour < TimePeriodBoundary.afternoonEndHour) {
      period = TimePeriod.afternoon;
    } else {
      period = TimePeriod.night;
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
