import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:flutter/material.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback? onTap;
  final bool showAuthor;

  const QuizCard({
    super.key,
    required this.quiz,
    this.onTap,
    this.showAuthor = true,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (quiz.subject.trim().isNotEmpty) ...[
                    _SubjectChip(subject: quiz.subject),
                    const SizedBox(width: 6),
                  ],
                  if (quiz.isPublic)
                    _PublicBadge(),
                ],
              ),
              if (quiz.subject.trim().isNotEmpty || quiz.isPublic)
                const SizedBox(height: 8),
              Text(
                quiz.title,
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.mono900,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    icon: Icons.quiz_outlined,
                    label: '${quiz.questionsCount} вопр.',
                  ),
                  if (quiz.settings.timeLimitMinutes != null)
                    _InfoChip(
                      icon: Icons.timer_outlined,
                      label: '${quiz.settings.timeLimitMinutes} мин',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: AppColors.mono100),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (showAuthor) ...[
                    const Icon(Icons.person_outline,
                        size: 13, color: AppColors.mono300),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        quiz.authorName,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.mono400),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    const Spacer(),
                  Text(
                    _formatDate(quiz.createdAt),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.mono300),
                  ),
                ],
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.mono100,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
        border: Border.all(color: AppColors.mono200),
      ),
      child: const Text(
        'ПУБЛИЧНЫЙ',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.mono400,
          letterSpacing: 0.4,
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
