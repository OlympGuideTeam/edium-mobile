import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/shared/widgets/question_image_widget.dart';
import 'package:edium/services/navigation_block_service/navigation_block_service.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:edium/presentation/shared/mixins/screen_protection_mixin.dart';
import 'package:edium/presentation/shared/widgets/no_copy_text_field.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_state.dart';
import 'package:edium/presentation/student/quiz_library/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'take_quiz_screen_question_page.dart';
part 'take_quiz_screen_top_bar.dart';
part 'take_quiz_screen_question_strip.dart';
part 'take_quiz_screen_drag_question.dart';
part 'take_quiz_screen_connection_question.dart';
part 'take_quiz_screen_connection_arrow_painter.dart';
part 'take_quiz_screen_edge_dot.dart';


class TakeQuizScreen extends StatefulWidget {
  final String sessionId;
  final String quizTitle;
  final int? totalTimeLimitSec;
  final bool useCache;


  final String? courseId;

  const TakeQuizScreen({
    super.key,
    required this.sessionId,
    required this.quizTitle,
    this.totalTimeLimitSec,
    this.useCache = false,
    this.courseId,
  });

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen>
    with WidgetsBindingObserver, ScreenProtectionMixin {
  late final PageController _pageController;
  bool _skipPageCallback = false;

  @override
  void initState() {
    super.initState();
    getIt<NavigationBlockService>().block();
    _pageController = PageController();
    context.read<TakeQuizBloc>().add(StartAttemptEvent(
          sessionId: widget.sessionId,
          quizTitle: widget.quizTitle,
          totalTimeLimitSec: widget.totalTimeLimitSec,
          useCache: widget.useCache,
        ));
  }

  @override
  void dispose() {
    getIt<NavigationBlockService>().unblock();
    _pageController.dispose();
    super.dispose();
  }


  void _exitToCourseOrPop(BuildContext context, String attemptId) {
    Navigator.of(context).pop(attemptId);
  }

  void _handleClose(BuildContext context, TakeQuizInProgress state) {
    final answeredCount =
        state.answers.values.where((a) => a != null).length;
    final totalCount = state.attempt.questions.length;
    final allAnswered = answeredCount == totalCount;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                allAnswered ? 'Завершить квиз?' : 'Прервать попытку?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                allAnswered
                    ? 'Вы ответили на все вопросы. Нажмите «Завершить», чтобы отправить ответы на проверку.'
                    : 'Вы ответили на $answeredCount из $totalCount вопросов. '
                        'Если выйдете сейчас — эта попытка будет прервана и вернуться к ней будет невозможно.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mono600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHSm,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (allAnswered) {
                      context
                          .read<TakeQuizBloc>()
                          .add(const FinishAttemptEvent());
                    } else {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mono900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    allAnswered ? 'Завершить' : 'Выйти',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHSm,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.mono150),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusLg),
                    ),
                  ),
                  child: Text(
                    allAnswered ? 'Продолжить' : 'Остаться',
                    style: const TextStyle(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TakeQuizBloc, TakeQuizState>(
      listener: (context, state) {
        if (state is TakeQuizCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuizResultScreen(
                result: state.result,
                maxPossibleScore: state.maxPossibleScore,
                quizTitle: state.quizTitle,
                questions: state.questions,
                courseId: widget.courseId,
                showBottomCta: false,
              ),
            ),
          );
        }
        if (state is TakeQuizInProgress && _pageController.hasClients) {
          final currentPage = _pageController.page?.round() ?? 0;
          if (currentPage != state.currentIndex) {
            FocusScope.of(context).unfocus();
            _skipPageCallback = true;
            _pageController
                .animateToPage(
                  state.currentIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                )
                .then((_) {
              if (mounted) _skipPageCallback = false;
            });
          }
        }
      },
      builder: (context, state) {
        if (state is TakeQuizLoading || state is TakeQuizInitial) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                  color: AppColors.mono700, strokeWidth: 2),
            ),
          );
        }

        if (state is TakeQuizFinishing) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                      color: AppColors.mono700, strokeWidth: 2),
                  SizedBox(height: 20),
                  Text('Оцениваем результаты…',
                      style: AppTextStyles.screenSubtitle),
                ],
              ),
            ),
          );
        }

        if (state is TakeQuizSubmitted) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.mono100,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(Icons.check,
                          color: AppColors.mono900, size: 36),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Спасибо за сдачу!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mono900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Работа успешно отправлена на оценку учителем.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.mono600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _exitToCourseOrPop(context, state.attemptId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mono900,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.courseId != null
                              ? 'Вернуться к курсу'
                              : 'Вернуться к квизам',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is TakeQuizError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.error_outline,
                          color: Color(0xFFEF4444), size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenSubtitle,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.mono150),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Назад',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mono700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is TakeQuizInProgress) {
          return PopScope(
            canPop: false,
            child: _buildQuizBody(context, state),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildQuizBody(BuildContext context, TakeQuizInProgress state) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              state: state,
              onBack: () => _handleClose(context, state),
            ),
            _QuestionStrip(state: state),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                itemCount: state.attempt.questions.length,
                onPageChanged: (index) {
                  FocusScope.of(context).unfocus();
                  if (!_skipPageCallback) {
                    context
                        .read<TakeQuizBloc>()
                        .add(JumpToQuestionEvent(index));
                  }
                },
                itemBuilder: (context, index) {
                  final question = state.attempt.questions[index];
                  return _QuestionPage(
                    key: ValueKey(question.id),
                    question: question,
                    answer: state.answers[question.id],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => context
                              .read<TakeQuizBloc>()
                              .add(const GoNextEvent()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mono900,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.mono200,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                        textStyle: AppTextStyles.primaryButton,
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              state.isLastQuestion
                                  ? 'Завершить квиз'
                                  : 'Далее',
                            ),
                    ),
                  ),
                  if (state.currentIndex > 0) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => context
                            .read<TakeQuizBloc>()
                            .add(const GoPrevEvent()),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.mono50,
                          foregroundColor: AppColors.mono600,
                          side: const BorderSide(color: AppColors.mono150),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                          textStyle: AppTextStyles.secondaryButton,
                        ),
                        child: const Text('Назад'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

