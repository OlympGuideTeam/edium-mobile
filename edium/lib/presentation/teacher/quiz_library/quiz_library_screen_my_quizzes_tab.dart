part of 'quiz_library_screen.dart';

class _MyQuizzesTab extends StatefulWidget {
  const _MyQuizzesTab({super.key});

  @override
  State<_MyQuizzesTab> createState() => _MyQuizzesTabState();
}

class _MyQuizzesTabState extends State<_MyQuizzesTab> {
  late final QuizLibraryBloc _bloc;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = QuizLibraryBloc(
      getQuizzes: getIt(),
      likeQuiz: getIt(),
      quizRepository: getIt<IQuizRepository>(),
    )..add(const LoadQuizzesEvent(scope: 'mine'));
  }

  @override
  void dispose() {
    _bloc.close();
    _searchCtrl.dispose();
    super.dispose();
  }

  void reload() {
    final q = _searchCtrl.text.trim();
    _bloc.add(LoadQuizzesEvent(scope: 'mine', search: q.isEmpty ? null : q));
  }

  void _search() => reload();

  void _openQuiz(BuildContext context, Quiz quiz) {
    final route = quiz.isPublic
        ? MaterialPageRoute(
            builder: (_) =>
                QuizDetailScreen(quizId: quiz.id, isOwnerHint: true),
          )
        : MaterialPageRoute(
            builder: (_) => EditQuizTemplateScreen(quizId: quiz.id),
          );
    Navigator.push(context, route).then((updated) {
      if (updated == true) reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPaddingH, 12,
                AppDimens.screenPaddingH, 12),
            child: SearchBarWidget(
              hint: 'Найти квиз...',
              controller: _searchCtrl,
              onChanged: (_) => _search(),
              onClear: _search,
            ),
          ),
          Expanded(
            child: BlocBuilder<QuizLibraryBloc, QuizLibraryState>(
              buildWhen: (p, c) =>
                  !(p is QuizLibraryLoaded && c is QuizLibraryLoading),
              builder: (context, state) {
                if (state is QuizLibraryLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.mono700, strokeWidth: 2),
                  );
                }
                if (state is QuizLibraryError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.mono400, size: 48),
                        const SizedBox(height: 12),
                        Text(state.message,
                            style: AppTextStyles.screenSubtitle),
                      ],
                    ),
                  );
                }
                if (state is QuizLibraryLoaded) {
                  return _buildList(context, state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, QuizLibraryLoaded state) {
    Future<void> onRefresh() async {
      reload();
      await _bloc.stream
          .firstWhere(
              (s) => s is QuizLibraryLoaded || s is QuizLibraryError)
          .timeout(const Duration(seconds: 30), onTimeout: () => state);
    }

    if (state.quizzes.isEmpty) {
      return EdiumRefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 320,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.quiz_outlined,
                        size: 48, color: AppColors.mono200),
                    const SizedBox(height: 12),
                    Text('Квизы не найдены',
                        style: AppTextStyles.fieldText
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('Попробуйте изменить поиск',
                        style: AppTextStyles.screenSubtitle),
                  ],
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
        padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPaddingH, 8, AppDimens.screenPaddingH, 24),
        itemCount: state.quizzes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final quiz = state.quizzes[i];
          final card = QuizCard(
            quiz: quiz,
            showPublicBadge: true,
            showTopQuestionBadge: false,
            onTap: () => _openQuiz(context, quiz),
          );
          if (quiz.isPublic) return card;
          return _buildDismissible(
            key: ValueKey('q-${quiz.id}'),
            onDismissed: () => _bloc.add(DeleteQuizEvent(quiz.id)),
            child: card,
          );
        },
      ),
    );
  }
}

