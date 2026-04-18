import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  final AttemptResult result;
  final int maxPossibleScore;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.maxPossibleScore,
  });

  double get _percentage {
    if (maxPossibleScore <= 0) return 0;
    return ((result.score ?? 0) / maxPossibleScore).clamp(0.0, 1.0);
  }

  int get _pct => (_percentage * 100).round();

  bool get _passed => _pct >= 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: AppColors.mono900),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Score circle
                    _ScoreCircle(pct: _pct, passed: _passed),
                    const SizedBox(height: 24),
                    // Heading
                    Text(
                      _passed ? 'Отлично!' : 'Не сдавайтесь!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mono900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _passed
                          ? 'Квиз успешно пройден. Продолжайте в том же духе!'
                          : 'Каждая ошибка — шаг к знаниям. Попробуйте ещё раз!',
                      style: AppTextStyles.screenSubtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Баллы',
                            value:
                                '${(result.score ?? 0).toStringAsFixed(1)} / $maxPossibleScore',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Вопросов',
                            value: '${result.answers.length}',
                          ),
                        ),
                      ],
                    ),
                    // Pending evaluation note
                    if (result.hasPendingEvaluation) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.mono50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.mono150),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.hourglass_top_outlined,
                                size: 16, color: AppColors.mono400),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Некоторые ответы ещё проверяются. Итоговый балл может измениться.',
                                style: AppTextStyles.helperText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Answers breakdown
                    if (result.answers.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'РЕЗУЛЬТАТЫ ПО ВОПРОСАМ',
                          style: AppTextStyles.sectionTag,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...result.answers.asMap().entries.map((entry) {
                        final i = entry.key;
                        final a = entry.value;
                        return _AnswerRow(
                          index: i + 1,
                          answer: a,
                        );
                      }),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mono900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    textStyle: AppTextStyles.primaryButton,
                  ),
                  child: const Text('Вернуться к квизам'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  final int pct;
  final bool passed;

  const _ScoreCircle({required this.pct, required this.passed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.mono50,
        border: Border.all(
          color: passed ? AppColors.mono700 : AppColors.mono300,
          width: 3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$pct%',
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: AppColors.mono900,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            passed ? 'Сдано' : 'Не сдано',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: passed ? AppColors.mono600 : AppColors.mono300,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.mono900,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.sectionTag),
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final int index;
  final AnswerSubmissionResult answer;

  const _AnswerRow({required this.index, required this.answer});

  @override
  Widget build(BuildContext context) {
    final score = answer.finalScore;
    final isPending = score == null;
    final isPerfect =
        !isPending && score > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isPending
                  ? AppColors.mono100
                  : isPerfect
                      ? AppColors.mono900
                      : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isPending
                    ? AppColors.mono200
                    : isPerfect
                        ? AppColors.mono900
                        : AppColors.mono300,
              ),
            ),
            child: Center(
              child: isPending
                  ? const Icon(Icons.hourglass_bottom,
                      size: 12, color: AppColors.mono350)
                  : isPerfect
                      ? const Icon(Icons.check,
                          size: 14, color: Colors.white)
                      : const Icon(Icons.close,
                          size: 14, color: AppColors.mono350),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Вопрос $index',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mono900,
                  ),
                ),
                if (answer.finalFeedback != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    answer.finalFeedback!,
                    style: AppTextStyles.helperText,
                  ),
                ],
              ],
            ),
          ),
          if (isPending)
            const Text(
              'Ожидание',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.mono350,
              ),
            )
          else
            Text(
              '${score.toStringAsFixed(score % 1 == 0 ? 0 : 1)} б.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isPerfect ? AppColors.mono900 : AppColors.mono350,
              ),
            ),
        ],
      ),
    );
  }
}
