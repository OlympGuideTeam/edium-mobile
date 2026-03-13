import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz_session.dart';
import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizSession session;

  const QuizResultScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final score = session.score ?? 0;
    final total = session.totalQuestions ?? session.answers.length;
    final pct = total > 0 ? (score / total * 100).round() : 0;
    final passed = pct >= 60;
    final color = passed ? AppColors.success : AppColors.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Animated icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  passed ? Icons.emoji_events_outlined : Icons.school_outlined,
                  color: color,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              // Score circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      color.withAlpha(20),
                      color.withAlpha(40),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: color, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$pct%',
                      style: AppTextStyles.heading1.copyWith(
                        color: color,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '$score / $total',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                passed ? 'Отличная работа!' : 'Не сдавайтесь!',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  passed
                      ? 'Вы успешно прошли квиз. Продолжайте в том же духе!'
                      : 'Каждая ошибка — это шаг к новым знаниям. Вы на правильном пути!',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatCard(
                    icon: Icons.check_circle_outline,
                    value: '$score',
                    label: 'Правильно',
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.cancel_outlined,
                    value: '${total - score}',
                    label: 'Ошибок',
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.percent,
                    value: '$pct%',
                    label: 'Результат',
                    color: AppColors.primary,
                  ),
                ],
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Вернуться к квизам'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.subtitle.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
