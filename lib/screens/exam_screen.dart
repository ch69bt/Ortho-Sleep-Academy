import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/quiz_data.dart';
import '../services/settings_service.dart';
import '../widgets/premium_gate.dart';
import 'quiz_screen.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : _isPremium
              ? _ExamContent()
              : PremiumGateWidget(onPurchase: _handlePurchase),
    );
  }
}

class _ExamContent extends StatelessWidget {
  const _ExamContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── ロゴエリア ──
        Expanded(
          flex: 4,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // シールドアイコン
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 44,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 20),
                // ORTHO SLEEP（白）
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'ORTHO SLEEP\n',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          height: 1.3,
                        ),
                      ),
                      // ACADEMY（ライトブルー）
                      TextSpan(
                        text: 'ACADEMY',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '睡眠知識検定試験',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ),

        // ── クイズボタンエリア ──
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'カテゴリを選んでください',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ...quizCategories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _QuizCategoryButton(category: category),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizCategoryButton extends StatelessWidget {
  final QuizCategory category;

  const _QuizCategoryButton({required this.category});

  IconData get _icon {
    switch (category.title) {
      case 'こどもの睡眠編':
        return Icons.child_care;
      case '大人の睡眠編':
        return Icons.person;
      case 'アスリートの睡眠編':
        return Icons.directions_run;
      default:
        return Icons.quiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(category: category),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.secondary, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(_icon, color: AppColors.secondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              category.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${category.questions.length}問',
            style: AppTextStyles.body,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios,
              color: AppColors.textSecondary, size: 16),
        ],
      ),
    );
  }
}
