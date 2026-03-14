import 'package:flutter/material.dart';
import '../models/lux_feedback.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class AdviceCard extends StatelessWidget {
  final LuxFeedback feedback;

  const AdviceCard({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            feedback.adviceText,
            style: AppTextStyles.adviceText,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: feedback.gaugeColor,
              ),
              const SizedBox(width: 6),
              Text(
                feedback.feedbackText,
                style: AppTextStyles.feedbackText.copyWith(
                  color: feedback.gaugeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            feedback.thresholdLabel,
            style: AppTextStyles.thresholdLabel,
          ),
        ],
      ),
    );
  }
}
