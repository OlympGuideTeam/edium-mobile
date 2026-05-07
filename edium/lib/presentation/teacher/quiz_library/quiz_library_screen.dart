import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/presentation/live/teacher/live_teacher_screen.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:edium/presentation/shared/widgets/quiz_card.dart';
import 'package:edium/presentation/shared/widgets/search_bar_widget.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/create_quiz_screen.dart';
import 'package:edium/presentation/teacher/edit_quiz_template/edit_quiz_template_screen.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/live_library_cubit.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_bloc.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_event.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_state.dart';
import 'package:edium/presentation/teacher/quiz_library/quiz_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────

class QuizLibraryScreen extends StatelessWidget {
  const QuizLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: _QuizLibraryScaffold(),
    );
  }
}

// ─── Scaffold ─────────────────────────────────────────────────────────────────

class _QuizLibraryScaffold extends StatefulWidget {
  const _QuizLibraryScaffold();

  @override
  State<_QuizLibraryScaffold> createState() => _QuizLibraryScaffoldState();
}

class _QuizLibraryScaffoldState extends State<_QuizLibraryScaffold> {
  final _allTabKey = GlobalKey<_AllQuizzesTabState>();
  final _mineTabKey = GlobalKey<_MyQuizzesTabState>();

  void _onCreateTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => CreateQuizBloc(
            getIt(),
            getIt<CreateSessionUsecase>(),
            getIt<IQuizRepository>(),
          ),
          child: const CreateQuizScreen(),
        ),
      ),
    ).then((_) {
      _allTabKey.currentState?.reload();
      _mineTabKey.currentState?.reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimens.screenPaddingH, 32, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mono900,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusXs),
                      ),
                      child: const Text('УЧИТЕЛЬ',
                          style: AppTextStyles.badgeText),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Библиотека',
                              style: AppTextStyles.screenTitle),
                        ),
                        IconButton(
                          onPressed: _onCreateTap,
                          icon: const Icon(Icons.add, size: 26),
                          color: AppColors.mono900,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Tab switcher
              const TabBar(
                labelColor: AppColors.mono900,
                unselectedLabelColor: AppColors.mono400,
                indicatorColor: AppColors.mono900,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: AppColors.mono150,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH),
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: 'Все квизы'),
                  Tab(text: 'Мои квизы'),
                  Tab(text: 'Мои лайвы'),
                ],
              ),
              // Independent tabs
              Expanded(
                child: TabBarView(
                  children: [
                    _AllQuizzesTab(key: _allTabKey),
                    _MyQuizzesTab(key: _mineTabKey),
                    const _LiveTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab: Все квизы ───────────────────────────────────────────────────────────

class _AllQuizzesTab extends StatefulWidget {
  const _AllQuizzesTab({super.key});

  @override
  State<_AllQuizzesTab> createState() => _AllQuizzesTabState();
}

class _AllQuizzesTabState extends State<_AllQuizzesTab> {
  late final QuizLibraryBloc _bloc;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = QuizLibraryBloc(
      getQuizzes: getIt(),
      likeQuiz: getIt(),
      quizRepository: getIt<IQuizRepository>(),
    )..add(const LoadQuizzesEvent(scope: 'global'));
  }

  @override
  void dispose() {
    _bloc.close();
    _searchCtrl.dispose();
    super.dispose();
  }

  void reload() {
    final q = _searchCtrl.text.trim();
    _bloc.add(LoadQuizzesEvent(scope: 'global', search: q.isEmpty ? null : q));
  }

  void _search() => reload();

  void _openQuiz(BuildContext context, Quiz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuizDetailScreen(quizId: quiz.id, isOwnerHint: false),
      ),
    ).then((updated) {
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
          return QuizCard(
            quiz: quiz,
            showPublicBadge: false,
            showTopQuestionBadge: true,
            onTap: () => _openQuiz(context, quiz),
          );
        },
      ),
    );
  }
}

// ─── Tab: Мои квизы ───────────────────────────────────────────────────────────

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

// ─── Tab: Мои лайвы ───────────────────────────────────────────────────────────

class _LiveTab extends StatefulWidget {
  const _LiveTab();

  @override
  State<_LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends State<_LiveTab> {
  late final LiveLibraryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = LiveLibraryCubit(getIt<ILiveRepository>())..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _openSession(LiveLibrarySession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveTeacherScreen(
          sessionId: session.sessionId,
          quizTitle: session.quizTitle,
          questionCount: 0,
        ),
      ),
    ).then((_) => _cubit.load());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: _LiveSessionsContent(onTap: _openSession),
    );
  }
}

// ─── Live sessions list ───────────────────────────────────────────────────────

class _LiveSessionsContent extends StatelessWidget {
  final ValueChanged<LiveLibrarySession> onTap;

  const _LiveSessionsContent({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveLibraryCubit, LiveLibraryState>(
      builder: (context, state) {
        if (state is LiveLibraryInitial || state is LiveLibraryLoading) {
          return const Center(
            child: CircularProgressIndicator(
                color: AppColors.mono700, strokeWidth: 2),
          );
        }
        if (state is LiveLibraryError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.mono400, size: 48),
                const SizedBox(height: 12),
                Text(state.message, style: AppTextStyles.screenSubtitle),
              ],
            ),
          );
        }
        if (state is LiveLibraryLoaded) {
          if (state.sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_outlined,
                      size: 48, color: AppColors.mono200),
                  const SizedBox(height: 12),
                  Text('Нет лайв-сессий',
                      style: AppTextStyles.fieldText
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Создайте квиз и запустите лайв',
                      style: AppTextStyles.screenSubtitle),
                ],
              ),
            );
          }
          return EdiumRefreshIndicator(
            onRefresh: () => context.read<LiveLibraryCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPaddingH, 8, AppDimens.screenPaddingH, 24),
              itemCount: state.sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _LiveSessionCard(
                session: state.sessions[i],
                onTap: () => onTap(state.sessions[i]),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _LiveSessionCard extends StatelessWidget {
  final LiveLibrarySession session;
  final VoidCallback onTap;

  const _LiveSessionCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.mono150),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.quizTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mono900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _PhaseBadge(phase: session.phase),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (session.joinCode != null) ...[
                  const Icon(Icons.key_rounded,
                      size: 14, color: AppColors.mono400),
                  const SizedBox(width: 4),
                  Text(
                    session.joinCode!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mono700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                const Icon(Icons.people_outline_rounded,
                    size: 14, color: AppColors.mono400),
                const SizedBox(width: 4),
                Text(
                  '${session.participantsCount}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.mono600),
                ),
                const Spacer(),
                Text(
                  _formatDate(session.createdAt),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.mono400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Сегодня';
    if (diff == 1) return 'Вчера';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}';
  }
}

class _PhaseBadge extends StatelessWidget {
  final LivePhase phase;

  const _PhaseBadge({required this.phase});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (phase) {
      LivePhase.pending => ('Не начат', AppColors.mono100, AppColors.mono600),
      LivePhase.lobby => (
          'Лобби',
          const Color(0xFFFFF3CD),
          const Color(0xFF92610A)
        ),
      LivePhase.questionActive || LivePhase.questionLocked => (
          'Идёт',
          const Color(0xFFDCFCE7),
          const Color(0xFF166534)
        ),
      LivePhase.completed =>
        ('Завершён', AppColors.mono100, AppColors.mono400),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Dismissible helper ───────────────────────────────────────────────────────

Widget _buildDismissible({
  required Key key,
  required VoidCallback onDismissed,
  required Widget child,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Container(
      color: AppColors.error,
      child: Dismissible(
        key: key,
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed(),
        background: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline,
              color: Colors.white, size: 20),
        ),
        child: child,
      ),
    ),
  );
}
