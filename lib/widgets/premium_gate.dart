import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

/// 課金前のロック状態を表示するウィジェット。
/// 課金実装時はこのウィジェット内の onPurchase コールバックに
/// RevenueCat 等の購入処理を渡す。
class PremiumGateWidget extends StatelessWidget {
  final VoidCallback onPurchase;

  const PremiumGateWidget({super.key, required this.onPurchase});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              '睡眠健康チェック試験',
              style: AppTextStyles.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '光と睡眠に関する知識を確認する試験です。\n受験には受験資格の購入が必要です。',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // TODO: 課金実装時に価格を動的に取得して表示する
            ElevatedButton(
              onPressed: onPurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '受験資格を購入する',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '※ 購入後は何度でも受験できます',
              style: AppTextStyles.disclaimer,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
