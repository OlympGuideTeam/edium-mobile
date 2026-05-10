part of 'live_teacher_screen.dart';

class _TeacherQuestionPhase extends StatelessWidget {
  final LiveTeacherQuestionActive state;
  final VoidCallback onNext;

  const _TeacherQuestionPhase({required this.state, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      body: Column(
        children: [

          _MonitorHeader(
            questionIndex: state.questionIndex,
            questionTotal: state.questionTotal,
            deadlineAt: state.deadlineAt,
            timeLimitSec: state.timeLimitSec,
            isLocked: false,
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
                    showCorrect: false,
                    correctAnswer: null,
                  ),
                  const SizedBox(height: 12),
                  _LiveStatsRow(
                    answeredCount: state.answeredCount,
                    totalCount: state.totalCount,
                    stats: state.stats,
                  ),
                  const SizedBox(height: 16),
                  _ParticipantProgress(
                    participants: state.participants,
                    answeredMap: state.answeredMap,
                    deadlineAt: state.deadlineAt,
                    timeLimitSec: state.timeLimitSec,
                    isLocked: false,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _GatedMonitorBottomBar(
            key: ValueKey(state.question.id),
            isLast: state.questionIndex >= state.questionTotal,
            deadlineAt: state.deadlineAt,
            timeLimitSec: state.timeLimitSec,
            answeredCount: state.answeredCount,
            totalCount: state.totalCount,
            onNext: onNext,
          ),
        ],
      ),
    );
  }
}

