import 'package:flutter/material.dart';
import '../constants/text_styles.dart';

class LuxDisplay extends StatelessWidget {
  final double lux;

  const LuxDisplay({super.key, required this.lux});

  String _formatLux(double value) {
    if (value >= 1000) {
      return value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Text(
            _formatLux(lux),
            key: ValueKey(_formatLux(lux)),
            style: AppTextStyles.luxValue,
          ),
        ),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'lux',
            style: AppTextStyles.luxUnit,
          ),
        ),
      ],
    );
  }
}
