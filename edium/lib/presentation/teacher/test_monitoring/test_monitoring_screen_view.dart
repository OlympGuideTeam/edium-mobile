part of 'test_monitoring_screen.dart';

class _View extends StatelessWidget {
  final String sessionId;
  final CourseItem? courseItem;

  const _View({required this.sessionId, required this.courseItem});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TestMonitoringBloc, TestMonitoringState>(
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

  Widget _body(BuildContext context, TestMonitoringState state) {
    if (state is TestMonitoringLoading || state is TestMonitoringInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mono700, strokeWidth: 2),
      );
    }

    if (state is TestMonitoringError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Не удалось загрузить данные',
                style: AppTextStyles.screenSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context
                    .read<TestMonitoringBloc>()
                    .add(const RefreshTestMonitoringEvent()),
                child: const Text('Повторить',
                    style: TextStyle(color: AppColors.mono900)),
              ),
            ],
          ),
        ),
      );
    }

    if (state is TestMonitoringLoaded) {
      return _LoadedBody(
        state: state,
        sessionId: sessionId,
      );
    }

    return const SizedBox.shrink();
  }
}

