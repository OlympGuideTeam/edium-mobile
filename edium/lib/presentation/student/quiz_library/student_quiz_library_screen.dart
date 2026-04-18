import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/shared/widgets/library_quiz_card.dart';
import 'package:edium/presentation/shared/widgets/search_bar_widget.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_state.dart';
import 'package:edium/presentation/student/quiz_library/quiz_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentQuizLibraryScreen extends StatelessWidget {
  const StudentQuizLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text('Квизы', style: AppTextStyles.screenTitle),
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
            Expanded(
              child: BlocBuilder<StudentQuizBloc, StudentQuizState>(
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
                                  side: const BorderSide(
                                      color: AppColors.mono150),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
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
                  if (state is StudentQuizLoaded) {
                    if (state.quizzes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.quiz_outlined,
                                size: 48, color: AppColors.mono200),
                            const SizedBox(height: 12),
                            const Text(
                              'Квизы не найдены',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mono900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Попробуйте изменить поисковый запрос',
                              style: AppTextStyles.screenSubtitle,
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: AppColors.mono700,
                      onRefresh: () async => context
                          .read<StudentQuizBloc>()
                          .add(const LoadStudentQuizzesEvent()),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                        itemCount: state.quizzes.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final quiz = state.quizzes[i];
                          return LibraryQuizCard(
                            quiz: quiz,
                            onTap: () {
                              final bloc =
                                  context.read<StudentQuizBloc>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      QuizPreviewScreen(quiz: quiz),
                                ),
                              ).then((_) => bloc.add(
                                  const LoadStudentQuizzesEvent()));
                            },
                          );
                        },
                      ),
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
