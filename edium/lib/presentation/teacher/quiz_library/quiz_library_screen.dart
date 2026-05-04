import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/presentation/live/teacher/live_teacher_screen.dart';
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

class QuizLibraryScreen extends StatefulWidget {
  const QuizLibraryScreen({super.key});

  @override
  State<QuizLibraryScreen> createState() => _QuizLibraryScreenState();
}

class _QuizLibraryScreenState extends State<QuizLibraryScreen> {
  final _searchCtrl = TextEditingController();
  int _tabIndex = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (index == _tabIndex) return;
    setState(() => _tabIndex = index);
    _searchCtrl.clear();
    if (index == 2) {
      context.read<LiveLibraryCubit>().load();
      return;
    }
    final scope = index == 0 ? 'global' : 'mine';
    context.read<QuizLibraryBloc>().add(LoadQuizzesEvent(scope: scope));
  }

  void _search() {
    if (_tabIndex == 2) return;
    final scope = _tabIndex == 0 ? 'global' : 'mine';
    final query = _searchCtrl.text.trim();
    context.read<QuizLibraryBloc>().add(
          LoadQuizzesEvent(
            scope: scope,
            search: query.isEmpty ? null : query,
          ),
        );
  }

  void _openLiveSession(BuildContext context, LiveLibrarySession session) {
    final cubit = context.read<LiveLibraryCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveTeacherScreen(
          sessionId: session.sessionId,
          quizTitle: session.quizTitle,
          questionCount: 0,
        ),
      ),
    ).then((_) {
      if (_tabIndex == 2) cubit.load();
    });
  }

  void _openQuiz(BuildContext context, Quiz quiz, bool isMineTab) {
    final libBloc = context.read<QuizLibraryBloc>();
    final scope = _tabIndex == 0 ? 'global' : 'mine';
    final route = isMineTab && !quiz.isPublic
        ? MaterialPageRoute(
            builder: (_) => EditQuizTemplateScreen(quizId: quiz.id),
          )
        : MaterialPageRoute(
            builder: (_) => QuizDetailScreen(
              quizId: quiz.id,
              isOwnerHint: isMineTab,
            ),
          );
    Navigator.push(context, route).then(
      (updated) {
        if (updated == true) libBloc.add(LoadQuizzesEvent(scope: scope));
      },
    );
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
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
                        onPressed: () {
                          final libBloc = context.read<QuizLibraryBloc>();
                          final scope =
                              _tabIndex == 0 ? 'global' : 'mine';
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
                          ).then((_) =>
                              libBloc.add(LoadQuizzesEvent(scope: scope)));
                        },
                        icon: const Icon(Icons.add, size: 26),
                        color: AppColors.mono900,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Pill-shaped tabs
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPaddingH),
              child: Row(
                children: [
                  _PillTab(
                    label: 'Все квизы',
                    isActive: _tabIndex == 0,
                    onTap: () => _switchTab(0),
                  ),
                  const SizedBox(width: 6),
                  _PillTab(
                    label: 'Мои квизы',
                    isActive: _tabIndex == 1,
                    onTap: () => _switchTab(1),
                  ),
                  const SizedBox(width: 6),
                  _PillTab(
                    label: 'Мои лайвы',
                    isActive: _tabIndex == 2,
                    onTap: () => _switchTab(2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search bar (only for quiz tabs)
            if (_tabIndex != 2) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH),
                child: SearchBarWidget(
                  hint: 'Найти квиз...',
                  controller: _searchCtrl,
                  onChanged: (_) => _search(),
                  onClear: _search,
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Content
            Expanded(
              child: _tabIndex == 2
                  ? _LiveSessionsContent(
                      onTap: (s) => _openLiveSession(context, s),
                    )
                  : BlocBuilder<QuizLibraryBloc, QuizLibraryState>(
                      builder: (context, state) {
                        if (state is QuizLibraryLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.mono700,
                              strokeWidth: 2,
                            ),
                          );
                        }
                        if (state is QuizLibraryError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline,
                                    color: AppColors.mono400, size: 48),
                                const SizedBox(height: 12),
                                Text(state.message,
                                    style: AppTextStyles.screenSubtitle),
                              ],
                            ),
                          );
                        }
                        if (state is QuizLibraryLoaded) {
                          if (state.quizzes.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.quiz_outlined,
                                      size: 48, color: AppColors.mono200),
                                  const SizedBox(height: 12),
                                  Text('Квизы не найдены',
                                      style: AppTextStyles.fieldText.copyWith(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  const Text('Попробуйте изменить поиск',
                                      style: AppTextStyles.screenSubtitle),
                                ],
                              ),
                            );
                          }
                          final isMineTab = _tabIndex == 1;
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                                AppDimens.screenPaddingH,
                                8,
                                AppDimens.screenPaddingH,
                                24),
                            itemCount: state.quizzes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final quiz = state.quizzes[i];
                              final card = QuizCard(
                                quiz: quiz,
                                showPublicBadge: isMineTab,
                                onTap: () =>
                                    _openQuiz(context, quiz, isMineTab),
                              );
                              if (!isMineTab) return card;
                              if (quiz.isPublic) return card;
                              return _buildDismissible(
                                key: ValueKey('q-${quiz.id}'),
                                onDismissed: () => context
                                    .read<QuizLibraryBloc>()
                                    .add(DeleteQuizEvent(quiz.id)),
                                child: card,
                              );
                            },
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
    );
  }
}

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

// ─── Live sessions tab ────────────────────────────────────────────────────────

class _LiveSessionsContent extends StatelessWidget {
  final ValueChanged<LiveLibrarySession> onTap;

  const _LiveSessionsContent({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveLibraryCubit, LiveLibraryState>(
      builder: (context, state) {
        if (state is LiveLibraryInitial) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => context.read<LiveLibraryCubit>().load(),
          );
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.mono700,
              strokeWidth: 2,
            ),
          );
        }
        if (state is LiveLibraryLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.mono700,
              strokeWidth: 2,
            ),
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
          return RefreshIndicator(
            color: AppColors.mono900,
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
                    fontSize: 13,
                    color: AppColors.mono600,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(session.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mono400,
                  ),
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
      LivePhase.lobby => ('Лобби', const Color(0xFFFFF3CD), const Color(0xFF92610A)),
      LivePhase.questionActive ||
      LivePhase.questionLocked =>
        ('Идёт', const Color(0xFFDCFCE7), const Color(0xFF166534)),
      LivePhase.completed => ('Завершён', AppColors.mono100, AppColors.mono400),
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

// ─── Pill tab ─────────────────────────────────────────────────────────────────

class _PillTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PillTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.mono900 : AppColors.mono50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.mono400,
          ),
        ),
      ),
    );
  }
}
