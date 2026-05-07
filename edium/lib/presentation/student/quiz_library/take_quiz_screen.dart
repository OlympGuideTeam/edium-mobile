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
import 'package:go_router/go_router.dart';

class TakeQuizScreen extends StatefulWidget {
  final String sessionId;
  final String quizTitle;
  final int? totalTimeLimitSec;
  final bool useCache;

  /// Если передан — после завершения теста уводим на `/course/<courseId>`
  /// (с обновлением данных курса), а не просто закрываем экран.
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

  /// Выходит с экрана прохождения теста: если знаем `courseId` —
  /// возвращаемся на экран курса (и он перезагрузит детали в `LoadCourseDetailEvent`),
  /// иначе просто закрываем экран.
  void _exitToCourseOrPop(BuildContext context) {
    final cid = widget.courseId;
    if (cid != null) {
      context.go('/course/$cid');
    } else {
      Navigator.pop(context);
    }
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
                        onPressed: () => _exitToCourseOrPop(context),
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

// ── Question Page ─────────────────────────────────────────────────────────────

class _QuestionPage extends StatefulWidget {
  final QuizQuestionForStudent question;
  final Map<String, dynamic>? answer;

  const _QuestionPage({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<_QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<_QuestionPage>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _textController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.answer?['text'] as String? ?? '',
    );
  }

  @override
  void didUpdateWidget(_QuestionPage old) {
    super.didUpdateWidget(old);
    if (old.question.id != widget.question.id) {
      final text = widget.answer?['text'] as String? ?? '';
      _textController.text = text;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.mono900,
                height: 1.4,
              ),
            ),
            if (widget.question.imageId != null) ...[
              const SizedBox(height: 16),
              QuestionImageWidget(imageId: widget.question.imageId!),
            ],
            const SizedBox(height: 24),
            _buildAnswerWidget(context),
            if (widget.question.type ==
                QuizQuestionType.withFreeAnswer) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mono50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.mono150),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome_outlined,
                        size: 14, color: AppColors.mono400),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Свободный ответ проверяется автоматически с помощью ИИ.',
                        style: AppTextStyles.helperText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerWidget(BuildContext context) {
    final question = widget.question;
    final answer = widget.answer;

    switch (question.type) {
      case QuizQuestionType.singleChoice:
        final selectedId = answer?['selected_option_id'] as String?;
        return Column(
          children: (question.options ?? []).map((opt) {
            final isSelected = selectedId == opt.id;
            return GestureDetector(
              onTap: () => context.read<TakeQuizBloc>().add(
                    SetAnswerEvent({'selected_option_id': opt.id}),
                  ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.mono25,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.mono900
                        : AppColors.mono150,
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.mono900
                              : AppColors.mono250,
                          width: isSelected ? 6 : 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt.text,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected
                              ? AppColors.mono900
                              : AppColors.mono700,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

      case QuizQuestionType.multipleChoice:
        final selectedIds = ((answer?['selected_option_ids']
                    as List<dynamic>?) ??
                [])
            .map((e) => e.toString())
            .toSet();
        return Column(
          children: (question.options ?? []).map((opt) {
            final isSelected = selectedIds.contains(opt.id);
            return GestureDetector(
              onTap: () {
                final updated = Set<String>.from(selectedIds);
                if (isSelected) {
                  updated.remove(opt.id);
                } else {
                  updated.add(opt.id);
                }
                context.read<TakeQuizBloc>().add(SetAnswerEvent(
                    {'selected_option_ids': updated.toList()}));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.mono25,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.mono900
                        : AppColors.mono150,
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.mono900
                            : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.mono900
                              : AppColors.mono250,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 13, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt.text,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected
                              ? AppColors.mono900
                              : AppColors.mono700,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

      case QuizQuestionType.withGivenAnswer:
        return SizedBox(
          height: AppDimens.buttonH,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mono25,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: AppColors.mono100,
                width: AppDimens.borderWidth,
              ),
            ),
            child: NoCopyTextField(
              controller: _textController,
              maxLines: 1,
              style: const TextStyle(fontSize: 15, color: AppColors.mono700),
              cursorColor: AppColors.mono900,
              onChanged: (v) => context
                  .read<TakeQuizBloc>()
                  .add(SetAnswerEvent({'text': v})),
              decoration: const InputDecoration(
                hintText: 'Введите ответ…',
                hintStyle:
                    TextStyle(fontSize: 15, color: AppColors.mono250),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        );

      case QuizQuestionType.withFreeAnswer:
        return Container(
          decoration: BoxDecoration(
            color: AppColors.mono25,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: AppColors.mono100,
              width: AppDimens.borderWidth,
            ),
          ),
          child: NoCopyTextField(
            controller: _textController,
            maxLines: 5,
            style: const TextStyle(fontSize: 15, color: AppColors.mono700),
            cursorColor: AppColors.mono900,
            onChanged: (v) => context
                .read<TakeQuizBloc>()
                .add(SetAnswerEvent({'text': v})),
            decoration: const InputDecoration(
              hintText: 'Введите развёрнутый ответ…',
              hintStyle:
                  TextStyle(fontSize: 15, color: AppColors.mono250),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        );

      case QuizQuestionType.drag:
        return _DragQuestion(
          question: question,
          currentOrder: (answer?['order'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              ((question.metadata?['items'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  []),
          onReorder: (order) => context
              .read<TakeQuizBloc>()
              .add(SetAnswerEvent({'order': order})),
        );

      case QuizQuestionType.connection:
        return _ConnectionQuestion(
          question: question,
          currentPairs:
              (answer?['pairs'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, v.toString())),
          onPairsChanged: (pairs) => context
              .read<TakeQuizBloc>()
              .add(SetAnswerEvent({'pairs': pairs})),
        );
    }
  }
}

// ── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final TakeQuizInProgress state;
  final VoidCallback onBack;

  const _TopBar({required this.state, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close,
                size: 22, color: AppColors.mono700),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              state.quizTitle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.mono900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (state.hasTimer)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (state.remainingSeconds ?? 0) < 60
                    ? const Color(0xFFFEE2E2)
                    : AppColors.mono50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (state.remainingSeconds ?? 0) < 60
                      ? const Color(0xFFEF4444)
                      : AppColors.mono150,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: (state.remainingSeconds ?? 0) < 60
                        ? const Color(0xFFEF4444)
                        : AppColors.mono400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.timerDisplay,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: (state.remainingSeconds ?? 0) < 60
                          ? const Color(0xFFEF4444)
                          : AppColors.mono700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Question Strip ────────────────────────────────────────────────────────────

class _QuestionStrip extends StatelessWidget {
  final TakeQuizInProgress state;
  const _QuestionStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final total = state.attempt.questions.length;
    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: total,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isCurrent = i == state.currentIndex;
          final q = state.attempt.questions[i];
          final isAnswered = state.answers[q.id] != null;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context
                .read<TakeQuizBloc>()
                .add(JumpToQuestionEvent(i)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.mono900
                    : isAnswered
                        ? AppColors.mono100
                        : Colors.transparent,
                shape: BoxShape.circle,
                border: isCurrent
                    ? null
                    : Border.all(
                        color: isAnswered
                            ? AppColors.mono150
                            : AppColors.mono200,
                        width: 1.5,
                      ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isCurrent
                      ? Colors.white
                      : isAnswered
                          ? AppColors.mono700
                          : AppColors.mono400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Drag Question ─────────────────────────────────────────────────────────────

class _DragQuestion extends StatefulWidget {
  final QuizQuestionForStudent question;
  final List<String> currentOrder;
  final ValueChanged<List<String>> onReorder;

  const _DragQuestion({
    required this.question,
    required this.currentOrder,
    required this.onReorder,
  });

  @override
  State<_DragQuestion> createState() => _DragQuestionState();
}

class _DragQuestionState extends State<_DragQuestion> {
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.currentOrder);
  }

  @override
  void didUpdateWidget(_DragQuestion old) {
    super.didUpdateWidget(old);
    if (old.question.id != widget.question.id) {
      _items = List.from(widget.currentOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Перетащите элементы в правильном порядке:',
          style: TextStyle(fontSize: 13, color: AppColors.mono400),
        ),
        const SizedBox(height: 12),
        Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 6,
                color: Colors.transparent,
                shadowColor: Colors.black12,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: child,
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _items.removeAt(oldIndex);
                _items.insert(newIndex, item);
              });
              widget.onReorder(List.from(_items));
            },
            children: _items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return ReorderableDragStartListener(
                key: ValueKey('$i:$item'),
                index: i,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mono150, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mono350,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.mono900),
                        ),
                      ),
                      const Icon(Icons.drag_handle,
                          color: AppColors.mono250, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Connection Question ───────────────────────────────────────────────────────

class _ConnectionQuestion extends StatefulWidget {
  final QuizQuestionForStudent question;
  final Map<String, String>? currentPairs;
  final ValueChanged<Map<String, String>> onPairsChanged;

  const _ConnectionQuestion({
    required this.question,
    required this.currentPairs,
    required this.onPairsChanged,
  });

  @override
  State<_ConnectionQuestion> createState() => _ConnectionQuestionState();
}

class _ConnectionQuestionState extends State<_ConnectionQuestion> {
  String? _selectedLeft;
  late Map<String, String> _pairs;

  // GlobalKeys to measure each card's position on screen
  late List<GlobalKey> _leftKeys;
  late List<GlobalKey> _rightKeys;
  // Key for the Stack — arrow positions are relative to it
  final _stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pairs = Map.from(widget.currentPairs ?? {});
    _initKeys();
  }

  void _initKeys() {
    final left = _leftItems;
    final right = _rightItems;
    _leftKeys = List.generate(left.length, (_) => GlobalKey());
    _rightKeys = List.generate(right.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(_ConnectionQuestion old) {
    super.didUpdateWidget(old);
    if (old.question.id != widget.question.id) {
      _selectedLeft = null;
      _pairs = Map.from(widget.currentPairs ?? {});
      _initKeys();
    }
  }

  List<String> get _leftItems =>
      (widget.question.metadata?['left'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  List<String> get _rightItems =>
      (widget.question.metadata?['right'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  void _onTapLeft(String item) {
    setState(() {
      _selectedLeft = _selectedLeft == item ? null : item;
    });
  }

  void _onTapRight(String item) {
    if (_selectedLeft == null) return;
    setState(() {
      _pairs.removeWhere((_, v) => v == item);
      _pairs[_selectedLeft!] = item;
      _selectedLeft = null;
    });
    widget.onPairsChanged(Map.from(_pairs));
  }

  void _removePair(String left) {
    setState(() => _pairs.remove(left));
    widget.onPairsChanged(Map.from(_pairs));
  }

  // Returns Rect of a keyed widget in the coordinate space of [_stackKey].
  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stackBox == null) return null;
    final topLeft = stackBox.globalToLocal(box.localToGlobal(Offset.zero));
    return topLeft & box.size;
  }

  // Build list of (fromRect, toRect, leftItem) for all active pairs
  List<({Rect fromRect, Rect toRect, String leftItem})> _arrowData() {
    final leftItems = _leftItems;
    final rightItems = _rightItems;
    final result = <({Rect fromRect, Rect toRect, String leftItem})>[];
    for (final entry in _pairs.entries) {
      final li = leftItems.indexOf(entry.key);
      final ri = rightItems.indexOf(entry.value);
      if (li == -1 || ri == -1) continue;
      final fromRect = _rectOf(_leftKeys[li]);
      final toRect = _rectOf(_rightKeys[ri]);
      if (fromRect != null && toRect != null) {
        result.add((fromRect: fromRect, toRect: toRect, leftItem: entry.key));
      }
    }
    return result;
  }

  // Detect tap on an arrow segment (within 20px of the line midpoint)
  void _onTapStack(TapUpDetails details) {
    final arrows = _arrowData();
    for (final arrow in arrows) {
      final from = Offset(arrow.fromRect.right, arrow.fromRect.center.dy);
      final to = Offset(arrow.toRect.left, arrow.toRect.center.dy);
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      if ((details.localPosition - mid).distance < 20) {
        _removePair(arrow.leftItem);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leftItems = _leftItems;
    final rightItems = _rightItems;
    final rowCount = leftItems.length > rightItems.length
        ? leftItems.length
        : rightItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Нажмите на элемент слева, затем на соответствующий справа:',
          style: TextStyle(fontSize: 13, color: AppColors.mono400),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTapUp: _onTapStack,
          child: Stack(
            key: _stackKey,
            children: [
              // ── Grid of cards ────────────────────────────────────────
              Column(
                children: List.generate(rowCount, (i) {
                  final left = i < leftItems.length ? leftItems[i] : null;
                  final right = i < rightItems.length ? rightItems[i] : null;

                  final isLeftSelected =
                      left != null && _selectedLeft == left;
                  final isLeftPaired =
                      left != null && _pairs.containsKey(left);
                  final isRightPaired =
                      right != null && _pairs.values.contains(right);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: 84,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left card
                          Expanded(
                            child: left != null
                                ? GestureDetector(
                                    onTap: () => _onTapLeft(left),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        AnimatedContainer(
                                          key: _leftKeys[i],
                                          duration: const Duration(
                                              milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isLeftSelected
                                                ? AppColors.mono900
                                                : isLeftPaired
                                                    ? AppColors.mono50
                                                    : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isLeftSelected
                                                  ? AppColors.mono900
                                                  : isLeftPaired
                                                      ? AppColors.mono350
                                                      : AppColors.mono150,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              left,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isLeftSelected
                                                    ? Colors.white
                                                    : AppColors.mono900,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Dot on right edge
                                        Positioned(
                                          right: -5,
                                          top: 0,
                                          bottom: 0,
                                          child: Center(
                                            child: _EdgeDot(
                                              active: isLeftPaired ||
                                                  isLeftSelected,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          // Gap between columns
                          const SizedBox(width: 32),

                          // Right card
                          Expanded(
                            child: right != null
                                ? GestureDetector(
                                    onTap: () => _onTapRight(right),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        AnimatedContainer(
                                          key: _rightKeys[i],
                                          duration: const Duration(
                                              milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isRightPaired
                                                ? AppColors.mono50
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isRightPaired
                                                  ? AppColors.mono350
                                                  : AppColors.mono150,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              right,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.mono900,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Dot on left edge
                                        Positioned(
                                          left: -5,
                                          top: 0,
                                          bottom: 0,
                                          child: Center(
                                            child: _EdgeDot(
                                              active: isRightPaired,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              // ── Arrow overlay ────────────────────────────────────────
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ConnectionArrowPainter(
                      arrows: _arrowData(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Arrow painter ─────────────────────────────────────────────────────────────

class _ConnectionArrowPainter extends CustomPainter {
  final List<({Rect fromRect, Rect toRect, String leftItem})> arrows;

  _ConnectionArrowPainter({required this.arrows});

  @override
  void paint(Canvas canvas, Size size) {
    if (arrows.isEmpty) return;

    const color = AppColors.mono700;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final arrow in arrows) {
      final from = Offset(arrow.fromRect.right, arrow.fromRect.center.dy);
      final to = Offset(arrow.toRect.left, arrow.toRect.center.dy);

      if ((to - from).distance < 4) continue;

      canvas.drawPath(_buildSCurvePath(from, to), linePaint);
    }
  }

  // S-curve: exits horizontally from left card, enters horizontally into right card
  Path _buildSCurvePath(Offset from, Offset to) {
    final path = Path()..moveTo(from.dx, from.dy);
    final dx = (to.dx - from.dx) * 0.5;
    path.cubicTo(
      from.dx + dx, from.dy,
      to.dx - dx, to.dy,
      to.dx, to.dy,
    );
    return path;
  }

  @override
  bool shouldRepaint(_ConnectionArrowPainter old) => old.arrows != arrows;
}

// ── Edge dot ──────────────────────────────────────────────────────────────────

class _EdgeDot extends StatelessWidget {
  final bool active;
  const _EdgeDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.mono700 : Colors.white,
        border: Border.all(
          color: active ? AppColors.mono700 : AppColors.mono250,
          width: 1.5,
        ),
      ),
    );
  }
}

