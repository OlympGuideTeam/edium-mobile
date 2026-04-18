import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/library_quiz.dart';
import 'package:flutter/material.dart';

class LibraryQuizCard extends StatelessWidget {
  final LibraryQuiz quiz;
  final VoidCallback? onTap;

  const LibraryQuizCard({super.key, required this.quiz, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mono150),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags row
            Row(
              children: [
                if (quiz.needEvaluation)
                  _Tag(
                    label: 'ПРОВЕРКА ИИ',
                    bg: AppColors.mono900,
                    fg: Colors.white,
                  ),
                if (quiz.needEvaluation) const SizedBox(width: 8),
                _Tag(
                  label: quiz.questionCount == 1
                      ? '1 ВОПРОС'
                      : '${quiz.questionCount} ВОПРОСОВ',
                  bg: AppColors.mono50,
                  fg: AppColors.mono400,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              quiz.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.mono900,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (quiz.description != null && quiz.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                quiz.description!,
                style: AppTextStyles.screenSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            // Bottom chips
            Row(
              children: [
                _InfoChip(
                  icon: Icons.quiz_outlined,
                  label: '${quiz.questionCount} вопр.',
                ),
                if (quiz.hasTimeLimit) ...[
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label: '${quiz.timeLimitMinutes} мин',
                  ),
                ],
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.mono250,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Tag({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.mono350),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.mono350,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
