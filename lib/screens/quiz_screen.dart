import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/quiz_data.dart';
import '../widgets/ad_banner.dart';

class QuizScreen extends StatefulWidget {
  final QuizCategory category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  int _correctCount = 0;
  bool _answered = false;

  QuizQuestion get _currentQuestion =>
      widget.category.questions[_currentIndex];
  int get _totalQuestions => widget.category.questions.length;
  bool get _isLastQuestion => _currentIndex == _totalQuestions - 1;

  void _onSelect(int index) {
    if (_answered) return;
    final isCorrect = index == _currentQuestion.correctIndex;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (isCorrect) _correctCount++;
    });
  }

  void _onNext() {
    if (_isLastQuestion) {
      _showResult();
    } else {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
    }
  }

  void _showResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _ResultScreen(
          category: widget.category,
          correctCount: _correctCount,
          totalQuestions: _totalQuestions,
        ),
      ),
    );
  }

  Color _choiceColor(int index) {
    if (!_answered) return AppColors.surface;
    if (index == _currentQuestion.correctIndex) return AppColors.success;
    if (index == _selectedIndex) return AppColors.warning;
    return AppColors.surface;
  }

  Color _choiceTextColor(int index) {
    if (!_answered) return AppColors.textPrimary;
    if (index == _currentQuestion.correctIndex) return Colors.white;
    if (index == _selectedIndex) return Colors.white;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(widget.category.title, style: AppTextStyles.appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 進捗バー
            Row(
              children: [
                Text(
                  '問題 ${_currentIndex + 1} / $_totalQuestions',
                  style: AppTextStyles.body,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _totalQuestions,
                      backgroundColor: AppColors.surface,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 問題文
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currentQuestion.question,
                style: AppTextStyles.adviceText,
              ),
            ),
            const SizedBox(height: 24),

            // 選択肢
            Expanded(
              child: ListView.separated(
                itemCount: _currentQuestion.choices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onSelect(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _choiceColor(index),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _answered &&
                                  index == _currentQuestion.correctIndex
                              ? AppColors.success
                              : AppColors.surface,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _choiceTextColor(index)
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(
                                color: _choiceTextColor(index),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _currentQuestion.choices[index],
                              style: TextStyle(
                                color: _choiceTextColor(index),
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                          if (_answered &&
                              index == _currentQuestion.correctIndex)
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 20),
                          if (_answered &&
                              index == _selectedIndex &&
                              index != _currentQuestion.correctIndex)
                            const Icon(Icons.cancel,
                                color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 解説 + 次へボタン
            if (_answered) ...[
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.secondary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentQuestion.explanation,
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _isLastQuestion ? '結果を見る' : '次の問題へ',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  final QuizCategory category;
  final int correctCount;
  final int totalQuestions;

  const _ResultScreen({
    required this.category,
    required this.correctCount,
    required this.totalQuestions,
  });

  String get _message {
    final ratio = correctCount / totalQuestions;
    if (ratio == 1.0) return '満点！素晴らしい知識です🎉';
    if (ratio >= 0.8) return 'よくできました！';
    if (ratio >= 0.6) return 'もう少しで合格圏内です';
    return '復習してもう一度チャレンジしましょう';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(category.title, style: AppTextStyles.appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events,
                        size: 72, color: AppColors.secondary),
                    const SizedBox(height: 24),
                    Text(
                      '$correctCount / $totalQuestions 問正解',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _message,
                      style: AppTextStyles.adviceText,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('試験画面に戻る',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }
}
