part of 'review_session_screen.dart';

class _LoadedBody extends StatelessWidget {
  final String sessionId;
  final Future<void> Function() onRefresh;
  final _Loaded state;

  const _LoadedBody({
    required this.sessionId,
    required this.onRefresh,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final attempts = state.attempts;

    if (attempts.isEmpty) {
      return Center(
        child: Text(
          'Нет попыток для проверки',
          style: AppTextStyles.screenSubtitle,
        ),
      );
    }

    final gradedCount =
        attempts.where((a) => a.status == AttemptStatus.graded).length;
    final gradingCount =
        attempts.where((a) => a.status == AttemptStatus.grading).length;
    final completedCount =
        attempts.where((a) => a.status == AttemptStatus.completed).length;
    final canPublish = attempts.isNotEmpty &&
        attempts.every((a) => a.status == AttemptStatus.completed);
    final remainingCount = attempts.length - completedCount;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: AppColors.mono700,
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPaddingH,
                8,
                AppDimens.screenPaddingH,
                24,
              ),
              children: [
                _SummaryStrip(
                  gradedCount: gradedCount,
                  gradingCount: gradingCount,
                  completedCount: completedCount,
                ),
                const SizedBox(height: 20),
                ...attempts.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _AttemptTile(
                      attempt: a,
                      onTap: a.status == AttemptStatus.graded
                          ? () => context.push(
                                '/test/$sessionId/attempts/${a.attemptId}/grade',
                              )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPaddingH,
            8,
            AppDimens.screenPaddingH,
            16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonH,
                child: ElevatedButton(
                  onPressed: (canPublish && !state.isPublishing)
                      ? () => context.read<_Cubit>().publish()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mono900,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.mono200,
                    disabledForegroundColor: AppColors.mono400,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                    textStyle: AppTextStyles.primaryButton,
                  ),
                  child: state.isPublishing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Опубликовать результаты'),
                ),
              ),
              if (!canPublish && remainingCount > 0) ...[
                const SizedBox(height: 6),
                Text(
                  'Осталось проверить: $remainingCount',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.mono400),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

