import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/shared/widgets/quiz_card.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Доступные квизы')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is StudentQuizError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.error_outline,
                              color: AppColors.error, size: 28),
                        ),
                        const SizedBox(height: 12),
                        Text(state.message, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  );
                }
                if (state is StudentQuizLoaded) {
                  if (state.quizzes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.quiz_outlined,
                                size: 36, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text('Квизы не найдены',
                              style: AppTextStyles.subtitle),
                          const SizedBox(height: 6),
                          Text('Попробуйте изменить поисковый запрос',
                              style: AppTextStyles.caption),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<StudentQuizBloc>()
                          .add(const LoadStudentQuizzesEvent());
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.quizzes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final quiz = state.quizzes[i];
                        final completed =
                            state.completedSessions[quiz.id];
                        final inProgressId =
                            state.inProgressSessions[quiz.id];
                        final isInProgress =
                            inProgressId != null && completed == null;

                        // Determine user status for preview
                        QuizUserStatus userStatus;
                        if (completed != null) {
                          userStatus = QuizUserStatus.completed;
                        } else if (isInProgress) {
                          userStatus = QuizUserStatus.inProgress;
                        } else {
                          userStatus = QuizUserStatus.notStarted;
                        }

                        return QuizCard(
                          quiz: quiz,
                          userScore: completed?.score,
                          userTotal: completed?.total,
                          isInProgress: isInProgress,
                          onTap: () {
                            final bloc =
                                context.read<StudentQuizBloc>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizPreviewScreen(
                                  quiz: quiz,
                                  userStatus: userStatus,
                                  sessionId: inProgressId,
                                  userScore: completed?.score,
                                  userTotal: completed?.total,
                                ),
                              ),
                            ).then((_) => bloc
                                .add(const LoadStudentQuizzesEvent()));
                          },
                          onLike: () => context
                              .read<StudentQuizBloc>()
                              .add(StudentLikeQuizEvent(quiz.id)),
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
    );
  }
}
