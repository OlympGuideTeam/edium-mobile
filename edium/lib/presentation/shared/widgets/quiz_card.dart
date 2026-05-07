import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:flutter/material.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback? onTap;
  final bool showPublicBadge;
  final bool showTopQuestionBadge;

  const QuizCard({
    super.key,
    required this.quiz,
    this.onTap,
    this.showPublicBadge = true,
    this.showTopQuestionBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.mono100),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showTopQuestionBadge ||
                        quiz.subject.trim().isNotEmpty ||
                        (showPublicBadge && quiz.isPublic)) ...[
                      Row(
                        children: [
                          if (showTopQuestionBadge)
                            _QuestionCountBadge(count: quiz.questionsCount),
                          if (quiz.subject.trim().isNotEmpty) ...[
                            if (showTopQuestionBadge)
                              const SizedBox(width: 6),
                            _SubjectChip(subject: quiz.subject),
                          ],
                          if (showPublicBadge && quiz.isPublic) ...[
                            if (showTopQuestionBadge ||
                                quiz.subject.trim().isNotEmpty)
                              const SizedBox(width: 6),
                            _PublicBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      quiz.title,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.mono900,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (!showTopQuestionBadge)
                          _InfoChip(
                            icon: Icons.quiz_outlined,
                            label: '${quiz.questionsCount}',
                          ),
                        if (quiz.settings.totalTimeLimitSec != null &&
                            quiz.settings.totalTimeLimitSec! > 0)
                          _InfoChip(
                            icon: Icons.timer_outlined,
                            label: _formatQuizDurationSec(
                              quiz.settings.totalTimeLimitSec!,
                            ),
                          )
                        else if (quiz.settings.timeLimitMinutes != null)
                          _InfoChip(
                            icon: Icons.timer_outlined,
                            label: '${quiz.settings.timeLimitMinutes} мин',
                          ),
                        if (quiz.settings.questionTimeLimitSec != null &&
                            quiz.settings.questionTimeLimitSec! > 0)
                          _InfoChip(
                            icon: Icons.timer_outlined,
                            label:
                                '${_formatQuizDurationSec(quiz.settings.questionTimeLimitSec!)}/впр',
                          ),
                        _InfoChip(
                          icon: Icons.calendar_today_outlined,
                          label: _formatDate(quiz.createdAt),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.mono250,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}

/// Human-readable duration for quiz time limits (from seconds).
/// Matches [QuizDetailScreen] labels for consistency.
String _formatQuizDurationSec(int sec) {
  if (sec <= 0) return '0 с';
  if (sec >= 3600) {
    final h = sec ~/ 3600;
    final rem = sec % 3600;
    final m = rem ~/ 60;
    if (m == 0) return '$h ч';
    return '$h ч $m мин';
  }
  if (sec >= 60) {
    final m = sec ~/ 60;
    final s = sec % 60;
    if (s == 0) return '$m мин';
    return '$m мин $s с';
  }
  return '$sec с';
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
        border: Border.all(color: AppColors.mono100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.mono400),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mono600,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: const Text(
        'ПУБЛИЧНЫЙ',
        style: AppTextStyles.badgeText,
      ),
    );
  }
}

class _QuestionCountBadge extends StatelessWidget {
  final int count;
  const _QuestionCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 ВОПРОС' : '$count ВОПРОСОВ';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.mono400,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final String subject;

  const _SubjectChip({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        subject.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
