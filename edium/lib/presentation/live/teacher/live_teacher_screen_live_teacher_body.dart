part of 'live_teacher_screen.dart';

class _LiveTeacherBody extends StatelessWidget {
  final String quizTitle;
  final int questionCount;

  const _LiveTeacherBody({
    required this.quizTitle,
    required this.questionCount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LiveTeacherBloc, LiveTeacherState>(
      listener: (context, state) {
        if (state is LiveTeacherCompleted) {
          context.read<LiveTeacherBloc>().add(LiveTeacherLoadResults());
        }
      },
      builder: (context, state) {
        return switch (state) {
          LiveTeacherInitial() || LiveTeacherConnecting() =>
            _TeacherLoadingPhase(quizTitle: quizTitle),
          LiveTeacherPending() => _TeacherPendingPhase(
              state: state,
              onStartLobby: () =>
                  context.read<LiveTeacherBloc>().add(LiveTeacherStartLobby()),
            ),
          LiveTeacherLobby() => _TeacherLobbyPhase(
              state: state,
              onStartQuiz: () =>
                  context.read<LiveTeacherBloc>().add(LiveTeacherStartQuiz()),
              onKick: (id) =>
                  context.read<LiveTeacherBloc>().add(LiveTeacherKickParticipant(id)),
            ),
          LiveTeacherQuestionActive() => _TeacherQuestionPhase(
              state: state,
              onNext: () =>
                  context.read<LiveTeacherBloc>().add(LiveTeacherNextQuestion()),
            ),
          LiveTeacherQuestionLocked() => _TeacherLockedPhase(
              state: state,
              isLast: state.questionIndex >= state.questionTotal,
              onNext: () =>
                  context.read<LiveTeacherBloc>().add(LiveTeacherNextQuestion()),
            ),
          LiveTeacherCompleted() || LiveTeacherResultsLoading() =>
            const _TeacherResultsLoadingPhase(),
          LiveTeacherResultsLoaded() => _TeacherResultsPhase(state: state),
          LiveTeacherError() => _TeacherErrorPhase(message: state.message),
        };
      },
    );
  }
}

