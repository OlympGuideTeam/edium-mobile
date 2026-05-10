part of 'attempt_review_screen.dart';

class AttemptReviewBody extends StatelessWidget {
  final String attemptId;
  final bool dark;
  const AttemptReviewBody({super.key, required this.attemptId, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttemptReviewBloc(getIt())
        ..add(LoadAttemptReviewEvent(attemptId)),
      child: BlocBuilder<AttemptReviewBloc, AttemptReviewBlocState>(
        builder: (context, state) {
          if (state is AttemptReviewLoading || state is AttemptReviewInitial) {
            return Center(
              child: CircularProgressIndicator(
                  color: dark ? Colors.white54 : AppColors.mono700,
                  strokeWidth: 2),
            );
          }
          if (state is AttemptReviewError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(state.message,
                    style: AppTextStyles.screenSubtitle.copyWith(
                        color: dark ? Colors.white60 : null),
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
    );
  }

  Widget _body(AttemptReview review) {
    return ListView(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPaddingH, 0, AppDimens.screenPaddingH, 32),
        children: [
          const SizedBox(height: 8),
          Text('Разбор попытки',
              style: AppTextStyles.screenTitle.copyWith(
                  fontSize: 22,
                  color: dark ? Colors.white : null)),
          const SizedBox(height: 6),
          Text(
            review.score != null
                ? 'Итоговый балл: ${review.score!.toStringAsFixed(0)}'
                : 'Балл ещё не выставлен',
            style: AppTextStyles.screenSubtitle.copyWith(
                color: dark ? Colors.white60 : null),
          ),
          const SizedBox(height: 20),
          ...review.answers.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _QuestionCard(index: e.key + 1, answer: e.value, dark: dark),
            );
          }),
        ],
    );
  }
}

