import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/core/di/injection.dart';
import 'package:edium/domain/entities/library_quiz.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:edium/domain/usecases/library_quiz/get_attempt_result_usecase.dart';
import 'package:edium/domain/usecases/test_session/get_attempt_review_usecase.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:edium/presentation/shared/widgets/library_quiz_card.dart';
import 'package:edium/presentation/shared/widgets/search_bar_widget.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_state.dart';
import 'package:edium/presentation/student/quiz_library/quiz_preview_screen.dart';
import 'package:edium/presentation/student/quiz_library/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentQuizLibraryScreen extends StatelessWidget {
  const StudentQuizLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.mono900,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusXs),
                        ),
                        child: const Text('УЧЕНИК',
                            style: AppTextStyles.badgeText),
                      ),
                      const SizedBox(height: 12),
                      const Text('Квизы', style: AppTextStyles.screenTitle),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SearchBarWidget(
                    hint: 'Найти квиз...',
                    onChanged: (q) => context
                        .read<StudentQuizBloc>()
                        .add(StudentSearchChangedEvent(q)),
                  ),
                ),
                const SizedBox(height: 8),
                const _QuizTabBar(),
                // TabBarView всегда присутствует — каждый таб независим
                const Expanded(
                  child: TabBarView(
                    children: [
                      _AllTab(),
                      _PassedTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab bar ────────────────────────────────────────────────────────────────────

class _QuizTabBar extends StatelessWidget {
  const _QuizTabBar();

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      labelColor: AppColors.mono900,
      unselectedLabelColor: AppColors.mono400,
      indicatorColor: AppColors.mono900,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColors.mono150,
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      padding: EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        Tab(text: 'Все'),
        Tab(text: 'Пройденные'),
      ],
    );
  }
}

// ── Tab: Все ───────────────────────────────────────────────────────────────────

class _AllTab extends StatelessWidget {
  const _AllTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentQuizBloc, StudentQuizState>(
      buildWhen: (previous, current) {
        if (previous is StudentQuizLoaded && current is StudentQuizLoading) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        if (state is StudentQuizLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.mono700,
              strokeWidth: 2,
            ),
          );
        }
        if (state is StudentQuizError) {
          return _ErrorBody(state: state);
        }
        if (state is StudentQuizLoaded) {
          return _AllTabLoaded(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

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

// ── Tab: Пройденные ────────────────────────────────────────────────────────────

class _PassedTab extends StatelessWidget {
  const _PassedTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentQuizBloc, StudentQuizState>(
      buildWhen: (previous, current) {
        if (previous is StudentQuizLoaded && current is StudentQuizLoading) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        if (state is StudentQuizLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.mono700,
              strokeWidth: 2,
            ),
          );
        }
        if (state is StudentQuizError) {
          return _ErrorBody(state: state);
        }
        if (state is StudentQuizLoaded) {
          return _PassedTabLoaded(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

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

class _PassedQuizResultLoaderScreen extends StatefulWidget {
  final LibraryQuiz quiz;
  final String attemptId;

  const _PassedQuizResultLoaderScreen({
    required this.quiz,
    required this.attemptId,
  });

  @override
  State<_PassedQuizResultLoaderScreen> createState() =>
      _PassedQuizResultLoaderScreenState();
}

class _PassedQuizResultLoaderScreenState
    extends State<_PassedQuizResultLoaderScreen> {
  late final Future<(AttemptResult, List<QuizQuestionForStudent>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<(AttemptResult, List<QuizQuestionForStudent>)> _loadData() async {
    final result =
        await getIt<GetAttemptResultUsecase>().call(widget.attemptId);
    final review =
        await getIt<GetAttemptReviewUsecase>().call(widget.attemptId);

    final questions = review.answers.map((a) {
      final rawMaxScore = a.metadata?['max_score'];
      final maxScore = switch (rawMaxScore) {
        int v when v > 0 => v,
        num v when v > 0 => v.toInt(),
        _ => 10,
      };
      return QuizQuestionForStudent(
        id: a.questionId,
        type: a.questionType,
        text: a.questionText.isNotEmpty ? a.questionText : 'Вопрос',
        imageId: a.imageId,
        maxScore: maxScore,
        options: a.options
            ?.map((o) => QuestionOptionForStudent(id: o.id, text: o.text))
            .toList(),
        metadata: a.metadata,
      );
    }).toList();

    return (result, questions);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(AttemptResult, List<QuizQuestionForStudent>)>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.mono700,
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.mono200,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Не удалось загрузить результаты',
                        style: AppTextStyles.screenSubtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Назад'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final (result, questions) = snapshot.data!;
        final maxPossibleScore =
            questions.fold<int>(0, (sum, q) => sum + q.maxScore);

        return QuizResultScreen(
          result: result,
          maxPossibleScore: maxPossibleScore,
          quizTitle: widget.quiz.title,
          questions: questions,
          showBottomCta: false,
        );
      },
    );
  }
}

// ── Error body ─────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final StudentQuizError state;
  const _ErrorBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.mono200, size: 48),
            const SizedBox(height: 12),
            Text(state.message,
                style: AppTextStyles.screenSubtitle,
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context
                    .read<StudentQuizBloc>()
                    .add(const LoadStudentQuizzesEvent()),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.mono150),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Попробовать снова',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mono700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty placeholder ──────────────────────────────────────────────────────────

class _EmptyPlaceholder extends StatelessWidget {
  final bool isEmpty;
  final String emptyText;
  const _EmptyPlaceholder({required this.isEmpty, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.quiz_outlined, size: 48, color: AppColors.mono200),
        const SizedBox(height: 12),
        Text(
          isEmpty ? emptyText : 'Ничего не найдено',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.mono900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isEmpty ? '' : 'Попробуйте изменить поисковый запрос',
          style: AppTextStyles.screenSubtitle,
        ),
      ],
    );
  }
}
