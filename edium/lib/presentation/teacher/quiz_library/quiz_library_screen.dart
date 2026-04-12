import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/shared/widgets/quiz_card.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/create_quiz_screen.dart';
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
  String? _selectedSubject;

  static const _subjects = [
    'Все',
    'Математика',
    'История',
    'Информатика',
    'Физика',
    'Химия',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (index == _tabIndex) return;
    setState(() {
      _tabIndex = index;
      _selectedSubject = null;
    });
    _searchCtrl.clear();
    final scope = index == 0 ? 'global' : 'mine';
    context.read<QuizLibraryBloc>().add(LoadQuizzesEvent(scope: scope));
  }

  void _search() {
    final scope = _tabIndex == 0 ? 'global' : 'mine';
    String query = _searchCtrl.text.trim();
    if (_selectedSubject != null && _selectedSubject != 'Все') {
      query = query.isEmpty ? _selectedSubject! : '$query $_selectedSubject';
    }
    context
        .read<QuizLibraryBloc>()
        .add(LoadQuizzesEvent(scope: scope, search: query.isEmpty ? null : query));
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
                                create: (_) => CreateQuizBloc(getIt()),
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
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.mono25,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(
                      color: AppColors.mono100, width: AppDimens.borderWidth),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => _search(),
                  cursorColor: AppColors.mono900,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.mono700),
                  decoration: const InputDecoration(
                    hintText: 'Найти квиз...',
                    hintStyle:
                        TextStyle(fontSize: 14, color: AppColors.mono250),
                    prefixIcon: Icon(Icons.search,
                        size: 18, color: AppColors.mono250),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Subject filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH, vertical: 4),
                itemCount: _subjects.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final subject = _subjects[i];
                  final isSelected =
                      (_selectedSubject == null && subject == 'Все') ||
                          _selectedSubject == subject;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSubject = subject == 'Все' ? null : subject;
                      });
                      _search();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.mono900 : AppColors.mono50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subject,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isSelected ? Colors.white : AppColors.mono400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
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
                            const Text('Попробуйте изменить фильтры',
                                style: AppTextStyles.screenSubtitle),
                          ],
                        ),
                      );
                    }
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
                        return QuizCard(
                          quiz: quiz,
                          onTap: () {
                            final bloc = context.read<QuizLibraryBloc>();
                            final scope = _tabIndex == 0 ? 'global' : 'mine';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    QuizDetailScreen(quizId: quiz.id),
                              ),
                            ).then((_) =>
                                bloc.add(LoadQuizzesEvent(scope: scope)));
                          },
                          onLike: () => context
                              .read<QuizLibraryBloc>()
                              .add(LikeQuizEvent(quiz.id)),
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
