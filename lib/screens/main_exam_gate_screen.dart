import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/settings_service.dart';

/// 本試験の課金ゲート画面
class MainExamGateScreen extends StatefulWidget {
  const MainExamGateScreen({super.key});

  @override
  State<MainExamGateScreen> createState() => _MainExamGateScreenState();
}

class _MainExamGateScreenState extends State<MainExamGateScreen> {
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await SettingsService.create();
    if (mounted) setState(() => _isPremium = settings.isPremium);
  }

  /// TODO: 課金実装時に RevenueCat 等の購入処理に置き換える
  Future<void> _handlePurchase() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('課金機能は準備中です')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('睡眠知識検定 本試験', style: AppTextStyles.appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isPremium ? const _MainExamContent() : _MainExamGate(onPurchase: _handlePurchase),
    );
  }
}

/// 未購入時のゲートUI
class _MainExamGate extends StatelessWidget {
  final VoidCallback onPurchase;
  const _MainExamGate({required this.onPurchase});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
            // ロゴ + テキスト
            Image.asset('assets/images/logo.png', width: 120, height: 120),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'ORTHO SLEEP',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  TextSpan(
                    text: '  ACADEMY',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ロックアイコン
            const Icon(Icons.lock_outline, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 20),

            // 説明
            Text(
              '睡眠知識検定 本試験',
              style: AppTextStyles.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '光と睡眠に関する知識を問う本格的な試験です。\n受験には受験資格の購入が必要です。\n合格するとデジタルディプロマ（資格）が発行されます。',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 特典リスト
            _FeatureItem(icon: Icons.quiz, text: '全20問の本格試験'),
            _FeatureItem(icon: Icons.emoji_events, text: '合格でデジタルディプロマ発行'),
            _FeatureItem(icon: Icons.warning_amber_outlined, text: '不合格の場合は再購入が必要'),

            const SizedBox(height: 32),

            // 購入ボタン
            // TODO: 課金実装時に価格を動的に表示する
            ElevatedButton(
              onPressed: onPurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '受験資格を購入する',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Text('※ 不合格の場合は再度購入が必要です', style: AppTextStyles.disclaimer),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Text(text, style: AppTextStyles.adviceText),
        ],
      ),
    );
  }
}

/// 購入済みユーザー向け本試験コンテンツ
/// TODO: 課金実装後に実際の試験問題を実装する
class _MainExamContent extends StatelessWidget {
  const _MainExamContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 100, height: 100),
            const SizedBox(height: 20),
            const Icon(Icons.check_circle_outline, size: 56, color: AppColors.success),
            const SizedBox(height: 16),
            Text('受験資格を取得済みです', style: AppTextStyles.heading, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('本試験コンテンツは準備中です。\nお待ちください。', style: AppTextStyles.body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
