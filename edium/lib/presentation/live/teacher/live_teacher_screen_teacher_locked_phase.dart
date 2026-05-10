part of 'live_teacher_screen.dart';

class _TeacherLockedPhase extends StatelessWidget {
  final LiveTeacherQuestionLocked state;
  final bool isLast;
  final VoidCallback onNext;

  const _TeacherLockedPhase({
    required this.state,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      body: Column(
        children: [
          _MonitorHeader(
            questionIndex: state.questionIndex,
            questionTotal: state.questionTotal,
            deadlineAt: DateTime.now(),
            timeLimitSec: 0,
            isLocked: true,
            lockedSegmentFillStart: state.timerFillAtLock,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _QuestionCard(text: state.question.text),
                  const SizedBox(height: 12),
                  _QuestionDistribution(
                    question: state.question,
                    stats: state.stats,
                    showCorrect: true,
                    correctAnswer: state.correctAnswer,
                  ),
                  const SizedBox(height: 12),
                  _LiveStatsRow(
                    answeredCount: state.stats.answeredCount,
                    totalCount: state.participants.length,
                    stats: state.stats,
                  ),
                  const SizedBox(height: 16),
                  _ParticipantProgress(
                    participants: state.participants,
                    answeredMap: state.answeredMap,
                    deadlineAt: DateTime.now(),
                    timeLimitSec: 0,
                    isLocked: true,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _MonitorBottomBar(
            isLast: isLast,
            onNext: onNext,
          ),
        ],
      ),
    );
  }
}


Widget _monitorSegmentTrack({
  required EdgeInsets margin,
  required double widthFactor,
  required Color fillColor,
}) {
  final f = widthFactor.clamp(0.0, 1.0);
  return Container(
    height: 4,
    margin: margin,
    decoration: BoxDecoration(
      color: AppColors.mono150,
      borderRadius: BorderRadius.circular(999),
    ),
    clipBehavior: Clip.antiAlias,
    child: Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: f,
        heightFactor: 1.0,
        child: ColoredBox(color: fillColor),
      ),
    ),
  );
}

