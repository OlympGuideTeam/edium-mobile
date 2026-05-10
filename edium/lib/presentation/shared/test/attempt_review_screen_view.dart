part of 'attempt_review_screen.dart';

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: AppColors.mono900),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AttemptReviewBloc, AttemptReviewBlocState>(
                builder: (context, state) {
                  if (state is AttemptReviewLoading ||
                      state is AttemptReviewInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.mono700, strokeWidth: 2),
                    );
                  }
                  if (state is AttemptReviewError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(state.message,
                            style: AppTextStyles.screenSubtitle,
                            textAlign: TextAlign.center),
                      ),
                    );
                  }
                  if (state is AttemptReviewLoaded) {
                    return _body(state.review);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(AttemptReview review) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPaddingH, 0, AppDimens.screenPaddingH, 32),
      children: [
        const SizedBox(height: 8),
        Text('Разбор попытки',
            style: AppTextStyles.screenTitle.copyWith(fontSize: 22)),
        const SizedBox(height: 6),
        Text(
          review.score != null
              ? 'Итоговый балл: ${review.score!.toStringAsFixed(0)}'
              : 'Балл ещё не выставлен',
          style: AppTextStyles.screenSubtitle,
        ),
        const SizedBox(height: 20),
        ...review.answers.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _QuestionCard(index: e.key + 1, answer: e.value),
          );
        }),
      ],
    );
  }
}

