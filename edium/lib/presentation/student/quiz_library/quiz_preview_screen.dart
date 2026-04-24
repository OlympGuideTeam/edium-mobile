import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/library_quiz.dart';
import 'package:edium/domain/repositories/test_session_repository.dart';
import 'package:edium/domain/usecases/library_quiz/create_attempt_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/finish_attempt_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/get_attempt_result_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/get_quiz_for_student_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/submit_attempt_answer_usecase.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/take_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuizPreviewScreen extends StatefulWidget {
  final LibraryQuiz quiz;

  const QuizPreviewScreen({super.key, required this.quiz});

  @override
  State<QuizPreviewScreen> createState() => _QuizPreviewScreenState();
}

class _QuizPreviewScreenState extends State<QuizPreviewScreen> {
  late Future<LibraryQuiz> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture =
        getIt<GetQuizForStudentUsecase>().call(widget.quiz.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back button row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: AppColors.mono900),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<LibraryQuiz>(
                future: _detailFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildContent(context, widget.quiz,
                        isLoading: true);
                  }
                  if (snapshot.hasError) {
                    return _buildContent(context, widget.quiz,
                        error: snapshot.error.toString());
                  }
                  return _buildContent(context, snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    LibraryQuiz quiz, {
    bool isLoading = false,
    String? error,
  }) {
    final sessionId = quiz.libraryTestSessionId;
    final canStart = sessionId != null && !isLoading && error == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Title
          Text(
            quiz.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.mono900,
            ),
          ),
          if (quiz.description != null &&
              quiz.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              quiz.description!,
              style: AppTextStyles.screenSubtitle,
            ),
          ],
          const SizedBox(height: 28),
          // Info cards
          _InfoCard(
            icon: Icons.quiz_outlined,
            title: 'Количество вопросов',
            value: '${quiz.questionCount}',
          ),
          if (quiz.hasTimeLimit) ...[
            const SizedBox(height: 10),
            _InfoCard(
              icon: Icons.timer_outlined,
              title: 'Ограничение по времени',
              value: '${quiz.timeLimitMinutes} мин',
            ),
          ],
          if (quiz.needEvaluation) ...[
            const SizedBox(height: 10),
            _InfoCard(
              icon: Icons.auto_awesome_outlined,
              title: 'Проверка ответов',
              value: 'Автоматически + ИИ',
            ),
          ],
          const SizedBox(height: 24),
          // Warning for timed quiz
          if (quiz.hasTimeLimit)
            _WarningBlock(
              text:
                  'Таймер запустится сразу после нажатия «Начать». Он не остановится, если вы покинете экран.',
            ),
          if (error != null)
            _WarningBlock(
              text: 'Не удалось загрузить квиз: $error',
              isError: true,
            ),
          const Spacer(),
          // Start button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canStart
                  ? () => _navigateToQuiz(context, quiz, sessionId)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mono900,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.mono200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                textStyle: AppTextStyles.primaryButton,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Начать квиз'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _navigateToQuiz(
      BuildContext context, LibraryQuiz quiz, String? sessionId) {
    if (sessionId == null) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => TakeQuizBloc(
            createAttempt: getIt<CreateAttemptUsecase>(),
            submitAnswer: getIt<SubmitAttemptAnswerUsecase>(),
            finishAttempt: getIt<FinishAttemptUsecase>(),
            getResult: getIt<GetAttemptResultUsecase>(),
            testSessionRepo: getIt<ITestSessionRepository>(),
          ),
          child: TakeQuizScreen(
            sessionId: sessionId,
            quizTitle: quiz.title,
            totalTimeLimitSec: quiz.defaultSettings.totalTimeLimitSec,
            // useCache: false (default) — public library не использует кэш.
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.mono150),
            ),
            child: Icon(icon, size: 18, color: AppColors.mono700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.mono400,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.mono900,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBlock extends StatelessWidget {
  final String text;
  final bool isError;

  const _WarningBlock({required this.text, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFEE2E2)
            : AppColors.mono50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? const Color(0xFFEF4444)
              : AppColors.mono150,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError
                ? Icons.error_outline
                : Icons.info_outline,
            size: 16,
            color: isError
                ? const Color(0xFFEF4444)
                : AppColors.mono400,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: isError
                    ? const Color(0xFFEF4444)
                    : AppColors.mono400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
