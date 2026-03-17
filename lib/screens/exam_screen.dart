import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/quiz_data.dart';
import '../services/settings_service.dart';
import 'quiz_screen.dart';
import 'main_exam_gate_screen.dart';

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
          : _ExamContent(isPremium: _isPremium),
    );
  }
}

class _ExamContent extends StatelessWidget {
  final bool isPremium;
  const _ExamContent({required this.isPremium});

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
                Image.asset(
                  'assets/images/logo.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'ORTHO SLEEP',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      TextSpan(
                        text: '  ACADEMY',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text('睡眠知識検定', style: AppTextStyles.body),
              ],
            ),
          ),
        ),

        // ── ボタンエリア ──
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 無料クイズセクション
                Text(
                  '無料クイズ',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ...quizCategories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _QuizButton(category: category),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: AppColors.surface, thickness: 1),
                const SizedBox(height: 16),

                // 本試験セクション（課金）
                Text(
                  '本試験',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                _MainExamButton(isPremium: isPremium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizButton extends StatelessWidget {
  final QuizCategory category;
  const _QuizButton({required this.category});

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
          MaterialPageRoute(builder: (_) => QuizScreen(category: category)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.secondary, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(_icon, color: AppColors.secondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              category.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text('${category.questions.length}問', style: AppTextStyles.body),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_ios,
              color: AppColors.textSecondary, size: 14),
        ],
      ),
    );
  }
}

class _MainExamButton extends StatelessWidget {
  final bool isPremium;
  const _MainExamButton({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MainExamGateScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isPremium ? AppColors.secondary : AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isPremium ? AppColors.secondary : AppColors.textSecondary,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPremium ? Icons.assignment : Icons.lock_outline,
            color: isPremium ? Colors.white : AppColors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '睡眠知識検定 本試験',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isPremium ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
          if (!isPremium)
            Text('受験資格が必要', style: AppTextStyles.disclaimer),
          const SizedBox(width: 6),
          Icon(
            Icons.arrow_forward_ios,
            color: isPremium ? Colors.white : AppColors.textSecondary,
            size: 14,
          ),
        ],
      ),
    );
  }
}
