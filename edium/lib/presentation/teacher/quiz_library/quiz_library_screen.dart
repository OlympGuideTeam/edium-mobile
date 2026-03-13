import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
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

class _QuizLibraryScreenState extends State<QuizLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _searchCtrl = TextEditingController();
  String? _selectedSubject;

  static const _subjects = ['Все', 'Математика', 'История', 'Информатика', 'Физика', 'Химия'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) return;
      setState(() => _selectedSubject = null);
      _searchCtrl.clear();
      final scope = _tab.index == 0 ? 'global' : 'mine';
      context.read<QuizLibraryBloc>().add(LoadQuizzesEvent(scope: scope));
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final scope = _tab.index == 0 ? 'global' : 'mine';
    String query = _searchCtrl.text.trim();
    if (_selectedSubject != null && _selectedSubject != 'Все') {
      query = query.isEmpty ? _selectedSubject! : '$query $_selectedSubject';
    }
    context.read<QuizLibraryBloc>().add(LoadQuizzesEvent(scope: scope, search: query.isEmpty ? null : query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Библиотека квизов'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Все квизы'),
            Tab(text: 'Мои квизы'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final libBloc = context.read<QuizLibraryBloc>();
          final scope = _tab.index == 0 ? 'global' : 'mine';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => CreateQuizBloc(getIt()),
                child: const CreateQuizScreen(),
              ),
            ),
          ).then((_) => libBloc.add(LoadQuizzesEvent(scope: scope)));
        },
        icon: const Icon(Icons.add),
        label: const Text('Создать'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: AppTextStyles.bodySmall,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Поиск по названию...',
                        hintStyle: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search,
                            size: 20, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    size: 18, color: AppColors.textSecondary),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _search();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) {
                        _search();
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Subject filter chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _subjects.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final subject = _subjects[i];
                final isSelected = (_selectedSubject == null && subject == 'Все') ||
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      ),
                    ),
                    child: Text(
                      subject,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<QuizLibraryBloc, QuizLibraryState>(
              builder: (context, state) {
                if (state is QuizLibraryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is QuizLibraryError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        Text(state.message, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  );
                }
                if (state is QuizLibraryLoaded) {
                  if (state.quizzes.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.quiz_outlined,
                              size: 64, color: AppColors.textSecondary),
                          SizedBox(height: 12),
                          Text('Квизы не найдены',
                              style: AppTextStyles.subtitle),
                          SizedBox(height: 4),
                          Text('Попробуйте изменить фильтры',
                              style: AppTextStyles.caption),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: state.quizzes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final quiz = state.quizzes[i];
                      return QuizCard(
                        quiz: quiz,
                        onTap: () {
                          final bloc = context.read<QuizLibraryBloc>();
                          final scope = _tab.index == 0 ? 'global' : 'mine';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  QuizDetailScreen(quizId: quiz.id),
                            ),
                          ).then((_) => bloc.add(LoadQuizzesEvent(scope: scope)));
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
    );
  }
}
