import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:edium/presentation/shared/widgets/library_quiz_card.dart';
import 'package:edium/presentation/shared/widgets/search_bar_widget.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_state.dart';
import 'package:edium/presentation/student/quiz_library/quiz_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
                Expanded(
                  child: BlocBuilder<StudentQuizBloc, StudentQuizState>(
                    buildWhen: (previous, current) {
                      if (previous is StudentQuizLoaded &&
                          current is StudentQuizLoading) {
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
                        return TabBarView(
                          children: [
                            _AllTab(state: state),
                            _PassedTab(state: state),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
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

// ── Tab bar ────────────────────────────────────────────────────────────────

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

// ── Error body ─────────────────────────────────────────────────────────────

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

// ── Tab: Все ───────────────────────────────────────────────────────────────

class _AllTab extends StatelessWidget {
  final StudentQuizLoaded state;
  const _AllTab({required this.state});

  @override
  Widget build(BuildContext context) {
    Future<void> onRefresh() async {
      final bloc = context.read<StudentQuizBloc>();
      bloc.add(const LoadStudentQuizzesEvent());
      await bloc.stream
          .firstWhere((s) => s is StudentQuizLoaded || s is StudentQuizError)
          .timeout(const Duration(seconds: 30),
              onTimeout: () => state);
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

// ── Tab: Пройденные ────────────────────────────────────────────────────────

class _PassedTab extends StatelessWidget {
  final StudentQuizLoaded state;
  const _PassedTab({required this.state});

  @override
  Widget build(BuildContext context) {
    Future<void> onRefresh() async {
      final bloc = context.read<StudentQuizBloc>();
      bloc.add(const LoadStudentQuizzesEvent());
      await bloc.stream
          .firstWhere((s) => s is StudentQuizLoaded || s is StudentQuizError)
          .timeout(const Duration(seconds: 30), onTimeout: () => state);
    }

    // One card per quiz — most recent attempt
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
            onTap: () => context.push(
              '/test/${attempt.sessionId}/attempts/${attempt.id}',
            ),
          );
        },
      ),
    );
  }
}

// ── Empty placeholder ──────────────────────────────────────────────────────

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
          isEmpty
              ? ''
              : 'Попробуйте изменить поисковый запрос',
          style: AppTextStyles.screenSubtitle,
        ),
      ],
    );
  }
}
