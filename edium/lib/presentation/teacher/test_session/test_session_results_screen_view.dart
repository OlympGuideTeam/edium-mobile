part of 'test_session_results_screen.dart';

class _View extends StatelessWidget {
  final String sessionId;
  final CourseItem? courseItem;
  const _View({required this.sessionId, this.courseItem});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TestSessionResultsBloc, TestSessionResultsState>(
      listener: (ctx, state) {
        if (state is TestSessionResultsDeleted) {
          Navigator.of(ctx).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(onBack: () => context.pop()),
                Expanded(child: _body(context, state, courseItem)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(
      BuildContext context, TestSessionResultsState state, CourseItem? courseItem) {
    if (state is TestSessionResultsLoading ||
        state is TestSessionResultsInitial) {
      return const Center(
        child: CircularProgressIndicator(
            color: AppColors.mono700, strokeWidth: 2),
      );
    }
    if (state is TestSessionResultsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(state.message,
              style: AppTextStyles.screenSubtitle,
              textAlign: TextAlign.center),
        ),
      );
    }
    if (state is TestSessionResultsLoaded) {
      return RefreshIndicator(
        color: AppColors.mono700,
        onRefresh: () async {
          context
              .read<TestSessionResultsBloc>()
              .add(const RefreshSessionResultsEvent());
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPaddingH, 0, AppDimens.screenPaddingH, 32),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 4),
            Text(state.title, style: AppTextStyles.heading2),
            const SizedBox(height: 20),
            _StatusHero(state: state),
            const SizedBox(height: 20),
            _DetailsSection(state: state),
            const SizedBox(height: 24),
            _SectionHeader(
              label: 'Участники',
              count: state.totalCount,
            ),
            const SizedBox(height: 10),
            if (state.rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    state.sessionStatus == 'not_started'
                        ? 'Тест ещё не открыт для прохождения'
                        : 'Пока никто не начинал тест',
                    style: AppTextStyles.screenSubtitle,
                  ),
                ),
              )
            else
              ...state.rows.map((r) => _StudentRowTile(
                    row: r,
                    onTap: r.attempt != null
                        ? () async {
                            final status = r.attempt!.status;
                            if (status == AttemptStatus.graded ||
                                status == AttemptStatus.grading) {
                              await context.push(
                                '/test/${state.sessionId}/attempts/${r.attempt!.attemptId}/grade',
                              );
                              if (context.mounted) {
                                context.read<TestSessionResultsBloc>().add(
                                    const RefreshSessionResultsEvent());
                              }
                            } else {
                              context.push(
                                '/test/${state.sessionId}/attempts/${r.attempt!.attemptId}',
                              );
                            }
                          }
                        : null,
                  )),
            const SizedBox(height: 20),
            _ActionButtons(state: state),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

