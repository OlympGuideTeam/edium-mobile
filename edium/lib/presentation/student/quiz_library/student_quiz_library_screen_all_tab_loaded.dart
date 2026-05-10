part of 'student_quiz_library_screen.dart';

class _AllTabLoaded extends StatelessWidget {
  final StudentQuizLoaded state;
  const _AllTabLoaded({required this.state});

  @override
  Widget build(BuildContext context) {
    Future<void> onRefresh() async {
      final bloc = context.read<StudentQuizBloc>();
      bloc.add(const LoadStudentQuizzesEvent());
      await bloc.stream
          .firstWhere((s) => s is StudentQuizLoaded || s is StudentQuizError)
          .timeout(const Duration(seconds: 30), onTimeout: () => state);
    }

    if (state.filtered.isEmpty) {
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
                  emptyText: 'Пока нет доступных квизов',
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
        itemCount: state.filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final quiz = state.filtered[i];
          return LibraryQuizCard(
            quiz: quiz,
            onTap: () {
              final bloc = context.read<StudentQuizBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizPreviewScreen(quiz: quiz),
                ),
              ).then((_) => bloc.add(const LoadStudentQuizzesEvent()));
            },
          );
        },
      ),
    );
  }
}

