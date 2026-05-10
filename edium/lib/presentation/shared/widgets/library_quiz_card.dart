import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/library_quiz.dart';
import 'package:flutter/material.dart';

part 'library_quiz_card_tag.dart';
part 'library_quiz_card_info_chip.dart';


class LibraryQuizCard extends StatelessWidget {
  final LibraryQuiz quiz;
  final VoidCallback? onTap;
  final double? score;
  final DateTime? date;

  const LibraryQuizCard({
    super.key,
    required this.quiz,
    this.onTap,
    this.score,
    this.date,
  });

  String _fmtScore(double s) {
    final str = s % 1 == 0 ? s.toInt().toString() : s.toStringAsFixed(1);
    return '$str / 10';
  }

  static const _months = [
    'янв', 'фев', 'мар', 'апр', 'май', 'июн',
    'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
  ];

  String _fmtDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Tag(
                        label: quiz.questionCount == 1
                            ? '1 ВОПРОС'
                            : '${quiz.questionCount} ВОПРОСОВ',
                        bg: AppColors.mono50,
                        fg: AppColors.mono400,
                      ),
                      if (score != null) ...[
                        const SizedBox(width: 6),
                        _Tag(
                          label: _fmtScore(score!),
                          bg: AppColors.mono900,
                          fg: Colors.white,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
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
                  if (quiz.description != null &&
                      quiz.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      quiz.description!,
                      style: AppTextStyles.screenSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (quiz.hasTimeLimit || date != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (quiz.hasTimeLimit)
                          _InfoChip(
                            icon: Icons.timer_outlined,
                            label: '${quiz.timeLimitMinutes} мин',
                          ),
                        if (quiz.hasTimeLimit && date != null)
                          const SizedBox(width: 6),
                        if (date != null)
                          _InfoChip(
                            icon: Icons.calendar_today_outlined,
                            label: _fmtDate(date!),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.mono250,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

