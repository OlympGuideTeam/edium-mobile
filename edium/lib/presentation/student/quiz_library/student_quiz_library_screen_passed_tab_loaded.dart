part of 'student_quiz_library_screen.dart';

class _PassedTabLoaded extends StatelessWidget {
  final StudentQuizLoaded state;
  const _PassedTabLoaded({required this.state});

  @override
  Widget build(BuildContext context) {
    Future<void> onRefresh() async {
      final bloc = context.read<StudentQuizBloc>();
      bloc.add(const LoadStudentQuizzesEvent());
      await bloc.stream
          .firstWhere((s) => s is StudentQuizLoaded || s is StudentQuizError)
          .timeout(const Duration(seconds: 30), onTimeout: () => state);
    }

    final items = state.filteredPassed.map((q) {
      final latest = q.attempts
          .reduce((a, b) => a.startedAt.isAfter(b.startedAt) ? a : b);
      return (quiz: q, attempt: latest);
    }).toList();

    if (items.isEmpty) {
      return EdiumRefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 320,
              child: Center(
                child: _EmptyPlaceholder(
                  isEmpty: state.searchQuery.isEmpty,
                  emptyText: 'Вы ещё не прошли ни одного квиза',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return EdiumRefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        itemCount: items.length + 1,
        separatorBuilder: (_, i) =>
            i == 0 ? const SizedBox(height: 12) : const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i == 0) {
            return const Text(
              'Показана последняя попытка по каждому квизу',
              style: AppTextStyles.screenSubtitle,
            );
          }
          final (:quiz, :attempt) = items[i - 1];
          return LibraryQuizCard(
            quiz: quiz,
            score: attempt.score,
            date: attempt.finishedAt ?? attempt.startedAt,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _PassedQuizResultLoaderScreen(
                  quiz: quiz,
                  attemptId: attempt.id,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

