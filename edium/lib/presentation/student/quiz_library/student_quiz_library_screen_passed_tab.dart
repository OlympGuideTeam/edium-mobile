part of 'student_quiz_library_screen.dart';

class _PassedTab extends StatelessWidget {
  const _PassedTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentQuizBloc, StudentQuizState>(
      buildWhen: (previous, current) {
        if (previous is StudentQuizLoaded && current is StudentQuizLoading) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        if (state is StudentQuizLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.mono700,
              strokeWidth: 2,
            ),
          );
        }
        if (state is StudentQuizError) {
          return _ErrorBody(state: state);
        }
        if (state is StudentQuizLoaded) {
          return _PassedTabLoaded(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

