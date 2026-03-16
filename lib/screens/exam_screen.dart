import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/settings_service.dart';
import '../widgets/premium_gate.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  bool _isPremium = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await SettingsService.create();
    if (mounted) {
      setState(() {
        _isPremium = settings.isPremium;
        _initialized = true;
      });
    }
  }

  /// TODO: 課金実装時にここを RevenueCat 等の購入処理に置き換える
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
        title: const Text('睡眠健康チェック試験', style: AppTextStyles.appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : _isPremium
              ? const _ExamContent()
              : PremiumGateWidget(onPurchase: _handlePurchase),
    );
  }
}

/// 受験資格購入済みユーザーに表示する試験コンテンツ。
/// TODO: 課金実装後に実際の試験問題・採点ロジックを実装する
class _ExamContent extends StatelessWidget {
  const _ExamContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success,
            ),
            const SizedBox(height: 24),
            Text(
              '受験資格を取得済みです',
              style: AppTextStyles.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '試験コンテンツは準備中です。\nお待ちください。',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
