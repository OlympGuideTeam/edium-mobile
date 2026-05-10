part of 'live_teacher_screen.dart';

class _MonitorHeader extends StatelessWidget {
  final int questionIndex;
  final int questionTotal;
  final DateTime deadlineAt;
  final int timeLimitSec;
  final bool isLocked;

  final double? lockedSegmentFillStart;

  const _MonitorHeader({
    required this.questionIndex,
    required this.questionTotal,
    required this.deadlineAt,
    required this.timeLimitSec,
    required this.isLocked,
    this.lockedSegmentFillStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mono50,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              _LiveDot(isLocked: isLocked),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Лайв',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mono900,
                  ),
                ),
              ),
              if (!isLocked)
                _LiveTimer(deadlineAt: deadlineAt)
              else
                _LockedBadge(),
            ],
          ),
          const SizedBox(height: 12),


          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Вопрос $questionIndex',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                ' / $questionTotal',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mono400,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),


          Row(
            children: List.generate(questionTotal, (i) {
              final filled = i < questionIndex - 1;
              final active = i == questionIndex - 1;
              final segMargin =
                  EdgeInsets.only(right: i < questionTotal - 1 ? 3 : 0);
              return Expanded(
                child: filled
                    ? Container(
                        height: 4,
                        margin: segMargin,
                        decoration: BoxDecoration(
                          color: AppColors.mono900,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      )
                    : active
                        ? (isLocked
                            ? _LockedSnapSegment(
                                margin: segMargin,
                                fillStart: lockedSegmentFillStart ?? 1.0,
                              )
                            : _TimerProgressSegment(
                                margin: segMargin,
                                deadlineAt: deadlineAt,
                                timeLimitSec: timeLimitSec,
                              ))
                        : Container(
                            height: 4,
                            margin: segMargin,
                            decoration: BoxDecoration(
                              color: AppColors.mono150,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

