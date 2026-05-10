part of 'course_detail_screen.dart';

class _QuizItemTile extends StatelessWidget {
  final CourseItem item;
  final bool isTeacher;
  final SessionStatusItem? sessionStatus;
  final VoidCallback? onTap;

  const _QuizItemTile({
    required this.item,
    required this.isTeacher,
    required this.onTap,
    this.sessionStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: AppColors.mono150,
              width: AppDimens.borderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.quizType == 'live'
                          ? AppColors.mono900
                          : AppColors.mono100,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusXs),
                    ),
                    child: Text(
                      item.quizType == 'live' ? 'ЛАЙВ' : 'ТЕСТ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: item.quizType == 'live'
                            ? Colors.white
                            : AppColors.mono400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (isTeacher && item.needEvaluation) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.mono900,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusXs),
                      ),
                      child: const Text(
                        'ИИ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  _TrailingBadge(
                    item: item,
                    isTeacher: isTeacher,
                    sessionStatus: sessionStatus,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.title ?? 'Квиз ${item.orderIndex + 1}',
                style: AppTextStyles.fieldText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ..._buildMetaChips(item.payload),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMetaChips(CourseItemPayload? p) {
    if (p == null) return const [];
    final chips = <Widget>[];

    if (p.totalTimeLimitSec != null) {
      final min = (p.totalTimeLimitSec! / 60).round();
      chips.add(_MetaChip(icon: Icons.timer_outlined, label: '$min мин'));
    } else if (p.questionTimeLimitSec != null) {
      chips.add(_MetaChip(
        icon: Icons.timer_outlined,
        label: '${p.questionTimeLimitSec} с/вопр.',
      ));
    }

    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    if (p.startedAt != null || p.finishedAt != null) {
      final parts = <String>[];
      if (p.startedAt != null) {
        final d = p.startedAt!.toLocal();
        parts.add('с ${d.day} ${months[d.month - 1]}');
      }
      if (p.finishedAt != null) {
        final d = p.finishedAt!.toLocal();
        parts.add('до ${d.day} ${months[d.month - 1]}');
      }
      chips.add(_MetaChip(
        icon: Icons.calendar_today_outlined,
        label: parts.join(' '),
      ));
    }

    if (chips.isEmpty) return const [];
    return [
      const SizedBox(height: 6),
      Wrap(spacing: 6, runSpacing: 4, children: chips),
    ];
  }
}

