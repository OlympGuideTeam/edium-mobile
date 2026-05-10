part of 'teacher_home_screen.dart';

class _AwaitingReviewSection extends StatelessWidget {
  const _AwaitingReviewSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AwaitingReviewCubit, AwaitingReviewState>(
      builder: (context, state) {
        if (state is AwaitingReviewLoaded && state.sessions.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ОЖИДАЮТ ПРОВЕРКИ', style: AppTextStyles.sectionTag),
              const SizedBox(height: 12),
              ...state.sessions.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AwaitingReviewCard(session: s),
                  )),
              const SizedBox(height: 14),
              const SizedBox(height: 24),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

