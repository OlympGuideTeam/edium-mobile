import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:flutter/material.dart';

part 'quiz_card_info_chip.dart';
part 'quiz_card_public_badge.dart';
part 'quiz_card_question_count_badge.dart';
part 'quiz_card_subject_chip.dart';


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

