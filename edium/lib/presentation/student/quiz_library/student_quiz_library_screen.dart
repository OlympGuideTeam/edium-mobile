import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  AppDimens.screenPaddingH, 16, AppDimens.screenPaddingH, 0),
              child: Text('Квизы', style: AppTextStyles.screenTitle),
            ),
            const SizedBox(height: 16),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPaddingH),
              child: SearchBarWidget(
                hint: 'Найти квиз...',
                onChanged: (q) => context
                    .read<StudentQuizBloc>()
                    .add(StudentSearchChangedEvent(q)),
              ),
            ),
            const SizedBox(height: 8),
            // Quiz list
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
                  if (state is StudentQuizLoaded) {
                    if (state.quizzes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.quiz_outlined,
                                size: 48, color: AppColors.mono200),
                            const SizedBox(height: 12),
                            Text('Квизы не найдены',
                                style: AppTextStyles.fieldText
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            const Text(
                                'Попробуйте изменить поисковый запрос',
                                style: AppTextStyles.screenSubtitle),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: AppColors.mono700,
                      onRefresh: () async {
                        context
                            .read<StudentQuizBloc>()
                            .add(const LoadStudentQuizzesEvent());
                      },
                      child: ListView.separated(
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
                          final completed =
                              state.completedSessions[quiz.id];
                          final inProgressId =
                              state.inProgressSessions[quiz.id];
                          final isInProgress =
                              inProgressId != null && completed == null;

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
      ),
    );
  }
}
