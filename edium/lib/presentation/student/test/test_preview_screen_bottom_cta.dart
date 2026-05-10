part of 'test_preview_screen.dart';

class _BottomCta extends StatelessWidget {
  final TestPreviewLoaded state;
  final String sessionId;
  final String? courseId;
  const _BottomCta({
    required this.state,
    required this.sessionId,
    this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final status = state.status;
    final meta = state.meta;

    final label = switch (status) {
      TestPreviewStatus.start => 'Начать тест',
      TestPreviewStatus.resume => 'Продолжить',
      TestPreviewStatus.locked => 'Откроется позже',
      TestPreviewStatus.expired => 'Дедлайн истёк',
      TestPreviewStatus.grading => 'Ответы проверяются',
      TestPreviewStatus.graded => 'Результаты недоступны',
      TestPreviewStatus.published => 'Загрузка...',
    };

    final enabled = status == TestPreviewStatus.start ||
        status == TestPreviewStatus.resume;

    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonH,
      child: ElevatedButton(
        onPressed: enabled ? () => _onTap(context, meta, status) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mono900,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.mono200,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          textStyle: AppTextStyles.primaryButton,
        ),
        child: Text(label),
      ),
    );
  }

  Future<void> _onTap(
    BuildContext context,
    TestSessionMeta meta,
    TestPreviewStatus status,
  ) async {
    final attemptId = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => TakeQuizBloc(
            createAttempt: getIt(),
            submitAnswer: getIt(),
            finishAttempt: getIt(),
            getResult: getIt(),
            testSessionRepo: getIt(),
            isFromCourse: true,
          ),
          child: TakeQuizScreen(
            sessionId: sessionId,
            quizTitle: meta.title,
            totalTimeLimitSec: meta.totalTimeLimitSec,
            useCache: true,
            courseId: courseId,
          ),
        ),
      ),
    );
    if (!context.mounted || attemptId == null) return;

    if (courseId != null) {


      context.pop(true);
    } else {
      context.read<TestPreviewBloc>().add(LoadTestPreviewEvent(
            meta: meta,
            initialAttemptId: attemptId,
          ));
    }
  }
}

