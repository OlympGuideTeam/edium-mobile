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
import 'package:share_plus/share_plus.dart';

part 'quiz_preview_screen_info_card.dart';
part 'quiz_preview_screen_warning_block.dart';


class QuizPreviewScreen extends StatefulWidget {
  final LibraryQuiz quiz;

  const QuizPreviewScreen({super.key, required this.quiz});

  @override
  State<QuizPreviewScreen> createState() => _QuizPreviewScreenState();
}

class _QuizPreviewScreenState extends State<QuizPreviewScreen> {
  late Future<LibraryQuiz> _detailFuture;

  void _shareQuiz() {
    Share.share(
      'https://links.edium.online/quiz/${widget.quiz.id}',
      subject: widget.quiz.title,
    );
  }

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: AppColors.mono900),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.ios_share_outlined,
                        size: 20, color: AppColors.mono700),
                    onPressed: _shareQuiz,
                  ),
                ],
              ),
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
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
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

          ),
        ),
      ),
    );
  }
}

