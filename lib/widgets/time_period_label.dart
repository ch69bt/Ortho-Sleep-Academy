import 'package:flutter/material.dart';
import '../models/lux_feedback.dart';
import '../constants/lux_thresholds.dart';
import '../constants/text_styles.dart';
import '../constants/colors.dart';

class TimePeriodLabel extends StatelessWidget {
  final LuxFeedback feedback;

  const TimePeriodLabel({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scaleX: feedback.period == TimePeriod.night ? -1 : 1,
          child: Icon(
            feedback.periodIcon,
            color: AppColors.secondary,
            size: 18,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          feedback.periodLabel,
          style: AppTextStyles.timePeriodLabel,
        ),
      ],
    );
  }
}
