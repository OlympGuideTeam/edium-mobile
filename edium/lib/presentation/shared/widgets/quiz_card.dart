import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:flutter/material.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool showAuthor;
  final int? userScore;
  final int? userTotal;
  final bool isInProgress;

  const QuizCard({
    super.key,
    required this.quiz,
    this.onTap,
    this.onLike,
    this.showAuthor = true,
    this.userScore,
    this.userTotal,
    this.isInProgress = false,
  });

  bool get _isCompleted => userScore != null && userTotal != null;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isCompleted
                  ? AppColors.success.withAlpha(80)
                  : isInProgress
                      ? AppColors.secondary.withAlpha(80)
                      : AppColors.cardBorder,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (quiz.subject.trim().isNotEmpty) ...[
                          _SubjectChip(subject: quiz.subject),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          quiz.title,
                          style: AppTextStyles.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_isCompleted)
                    _CompletedBadge(
                        score: userScore!, total: userTotal!)
                  else if (isInProgress)
                    const _InProgressBadge()
                  else
                    _StatusBadge(status: quiz.status),
                ],
              ),
              const SizedBox(height: 12),
              // Info chips row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    icon: Icons.quiz_outlined,
                    label: '${quiz.questionsCount} вопросов',
                  ),
                  if (quiz.settings.timeLimitMinutes != null)
                    _InfoChip(
                      icon: Icons.timer_outlined,
                      label: '${quiz.settings.timeLimitMinutes} мин',
                      color: AppColors.secondary,
                    ),
                  if (quiz.settings.deadline != null)
                    _InfoChip(
                      icon: Icons.event_outlined,
                      label: _formatDeadline(quiz.settings.deadline!),
                      color: _isDeadlineSoon(quiz.settings.deadline!)
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: onLike,
                    child: Row(
                      children: [
                        Icon(
                          quiz.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 16,
                          color: quiz.isLiked
                              ? AppColors.secondary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${quiz.likesCount}',
                          style: AppTextStyles.caption.copyWith(
                            color: quiz.isLiked
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showAuthor) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.person_outline,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        quiz.authorName,
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    const Spacer(),
                  Text(
                    _formatDate(quiz.createdAt),
                    style: AppTextStyles.caption,
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

  String _formatDeadline(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.isNegative) return 'Истёк';
    if (diff.inDays > 0) return 'до ${dt.day}.${dt.month.toString().padLeft(2, '0')}';
    if (diff.inHours > 0) return '${diff.inHours} ч';
    return '${diff.inMinutes} мин';
  }

  bool _isDeadlineSoon(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    return diff.isNegative || diff.inHours < 24;
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: c,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        subject,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final QuizStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case QuizStatus.active:
        bg = AppColors.successLight;
        fg = AppColors.success;
        label = 'Активен';
        break;
      case QuizStatus.completed:
        bg = AppColors.divider;
        fg = AppColors.textSecondary;
        label = 'Завершён';
        break;
      case QuizStatus.future:
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        label = 'Запланирован';
        break;
      case QuizStatus.draft:
        bg = AppColors.secondaryLight;
        fg = AppColors.secondary;
        label = 'Черновик';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InProgressBadge extends StatelessWidget {
  const _InProgressBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_outline,
              size: 12, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            'В процессе',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  final int score;
  final int total;

  const _CompletedBadge({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (score / total * 100).round() : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 12, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            'Пройден · $pct%',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
