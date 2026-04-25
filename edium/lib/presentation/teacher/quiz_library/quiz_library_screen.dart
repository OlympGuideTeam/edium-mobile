import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/presentation/shared/widgets/quiz_card.dart';
import 'package:edium/presentation/shared/widgets/search_bar_widget.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/create_quiz_screen.dart';
import 'package:edium/presentation/teacher/edit_quiz_template/edit_quiz_template_screen.dart';
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
    final scope = index == 0 ? 'global' : 'mine';
    context.read<QuizLibraryBloc>().add(LoadQuizzesEvent(scope: scope));
  }

  void _search() {
    final scope = _tabIndex == 0 ? 'global' : 'mine';
    final query = _searchCtrl.text.trim();
    context.read<QuizLibraryBloc>().add(
          LoadQuizzesEvent(
            scope: scope,
            search: query.isEmpty ? null : query,
          ),
        );
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
    return Scaffold(
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
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
            // Quiz list
            Expanded(
              child: BlocBuilder<QuizLibraryBloc, QuizLibraryState>(
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
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final quiz = state.quizzes[i];
                        final card = QuizCard(
                          quiz: quiz,
                          showPublicBadge: isMineTab,
                          onTap: () => _openQuiz(context, quiz, isMineTab),
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
