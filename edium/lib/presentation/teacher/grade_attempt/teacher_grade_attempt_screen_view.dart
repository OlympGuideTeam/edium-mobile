part of 'teacher_grade_attempt_screen.dart';

class _View extends StatelessWidget {
  final String attemptId;
  const _View({required this.attemptId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherGradeBloc, TeacherGradeState>(
      listener: (ctx, state) {
        if (state is TeacherGradeCompleted) {
          ctx.pop();
        }
        if (state is TeacherGradeLoaded && state.saveError != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                'Ошибка сохранения: ${state.saveError}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.mono900,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(onBack: () => context.pop()),
                Expanded(child: _body(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, TeacherGradeState state) {
    if (state is TeacherGradeLoading || state is TeacherGradeInitial) {
      return const Center(
        child: CircularProgressIndicator(
            color: AppColors.mono700, strokeWidth: 2),
      );
    }
    if (state is TeacherGradeError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(state.message,
              style: AppTextStyles.screenSubtitle,
              textAlign: TextAlign.center),
        ),
      );
    }
    if (state is TeacherGradeLoaded) {
      return _GradeBody(
        review: state.review,
        isSaving: state.isSaving,
        attemptId: attemptId,
        localGrades: state.localGrades,
      );
    }
    return const SizedBox.shrink();
  }
}

