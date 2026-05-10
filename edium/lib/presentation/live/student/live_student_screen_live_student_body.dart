part of 'live_student_screen.dart';

class _LiveStudentBody extends StatelessWidget {
  final String quizTitle;
  final String attemptId;

  const _LiveStudentBody({required this.quizTitle, required this.attemptId});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _darkTheme(),
      child: BlocConsumer<LiveStudentBloc, LiveStudentState>(
        listener: (context, state) {
          if (state is LiveStudentCompleted) {
            context.read<LiveStudentBloc>().add(LiveStudentLoadResults());
          }
        },
        builder: (context, state) {
          return switch (state) {
            LiveStudentInitial() || LiveStudentConnecting() => _LoadingPhase(quizTitle: quizTitle),
            LiveStudentLobby() => _LobbyPhase(
                quizTitle: quizTitle,
                state: state,
              ),
            LiveStudentQuestionActive() => _QuestionPhase(state: state),
            LiveStudentQuestionLocked() => _LockedPhase(state: state),
            LiveStudentCompleted() || LiveStudentResultsLoading() => _LoadingPhase(quizTitle: quizTitle),
            LiveStudentResultsLoaded() => _ResultsPhase(state: state, attemptId: attemptId),
            LiveStudentKicked() => _KickedPhase(),
            LiveStudentError() => _ErrorPhase(message: state.message),
          };
        },
      ),
    );
  }

  ThemeData _darkTheme() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.liveDarkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.liveAccent,
          surface: AppColors.liveDarkSurface,
        ),
      );
}

