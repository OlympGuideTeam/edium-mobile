import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_state.dart';
import 'package:edium/presentation/student/quiz_library/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TakeQuizScreen extends StatefulWidget {
  final String quizId;
  final String? resumeSessionId;

  const TakeQuizScreen({
    super.key,
    required this.quizId,
    this.resumeSessionId,
  });

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TakeQuizBloc>().add(StartSessionEvent(
          widget.quizId,
          resumeSessionId: widget.resumeSessionId,
        ));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TakeQuizBloc, TakeQuizState>(
      listener: (context, state) {
        if (state is TakeQuizCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuizResultScreen(session: state.result),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TakeQuizLoading || state is TakeQuizInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is TakeQuizError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.error_outline,
                          color: AppColors.error, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is TakeQuizInProgress) {
          final quiz = state.quiz;
          final question = quiz.questions[state.currentIndex];
          final progress = (state.currentIndex + 1) / quiz.questions.length;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(quiz.title),
              actions: [
                if (state.hasTimer)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (state.remainingSeconds ?? 0) < 60
                              ? AppColors.errorLight
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: (state.remainingSeconds ?? 0) < 60
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              state.timerDisplay,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: (state.remainingSeconds ?? 0) < 60
                                    ? AppColors.error
                                    : AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.cardBorder,
                  color: AppColors.primary,
                  minHeight: 4,
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question counter
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Вопрос ${state.currentIndex + 1} из ${quiz.questions.length}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            _TypeBadge(type: question.type),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Question text
                        Text(question.text, style: AppTextStyles.heading3),
                        const SizedBox(height: 24),
                        // Answer widget
                        _buildAnswerWidget(context, question, state),
                        // Feedback
                        if (state.answerSubmitted) ...[
                          const SizedBox(height: 20),
                          _FeedbackCard(
                            correct: state.lastCorrect ?? false,
                            explanation: state.lastExplanation,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Bottom buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: state.answerSubmitted
                      ? EdiumButton(
                          label: state.isLastQuestion
                              ? 'Завершить квиз'
                              : 'Следующий вопрос',
                          onPressed: () => context
                              .read<TakeQuizBloc>()
                              .add(const NextQuestionEvent()),
                          icon: state.isLastQuestion
                              ? Icons.flag_outlined
                              : Icons.arrow_forward,
                        )
                      : EdiumButton(
                          label: 'Проверить ответ',
                          onPressed: state.currentAnswer != null
                              ? () => context
                                  .read<TakeQuizBloc>()
                                  .add(const SubmitCurrentAnswerEvent())
                              : null,
                        ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAnswerWidget(
      BuildContext context, Question question, TakeQuizInProgress state) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return Column(
          children: question.options.map((opt) {
            final isSelected = state.currentAnswer == opt.id;
            Color? bgColor;
            Color? borderColor;
            if (state.answerSubmitted) {
              if (opt.isCorrect) {
                bgColor = AppColors.successLight;
                borderColor = AppColors.success;
              } else if (isSelected && !opt.isCorrect) {
                bgColor = AppColors.errorLight;
                borderColor = AppColors.error;
              }
            } else if (isSelected) {
              bgColor = AppColors.primaryLight;
              borderColor = AppColors.primary;
            }

            return GestureDetector(
              onTap: state.answerSubmitted
                  ? null
                  : () => context
                      .read<TakeQuizBloc>()
                      .add(SetAnswerEvent(opt.id)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgColor ?? AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor ?? AppColors.cardBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: opt.id,
                      groupValue: state.currentAnswer as String?,
                      onChanged: state.answerSubmitted
                          ? null
                          : (v) => context
                              .read<TakeQuizBloc>()
                              .add(SetAnswerEvent(v)),
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(opt.text, style: AppTextStyles.bodySmall),
                    ),
                    if (state.answerSubmitted && opt.isCorrect)
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 18),
                    if (state.answerSubmitted && isSelected && !opt.isCorrect)
                      const Icon(Icons.cancel,
                          color: AppColors.error, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        );

      case QuestionType.multiChoice:
        final selected = (state.currentAnswer as List<String>?) ?? [];
        return Column(
          children: question.options.map((opt) {
            final isSelected = selected.contains(opt.id);
            Color? bgColor;
            Color? borderColor;
            if (state.answerSubmitted) {
              if (opt.isCorrect) {
                bgColor = AppColors.successLight;
                borderColor = AppColors.success;
              } else if (isSelected && !opt.isCorrect) {
                bgColor = AppColors.errorLight;
                borderColor = AppColors.error;
              }
            } else if (isSelected) {
              bgColor = AppColors.primaryLight;
              borderColor = AppColors.primary;
            }

            return GestureDetector(
              onTap: state.answerSubmitted
                  ? null
                  : () {
                      final newSelected = List<String>.from(selected);
                      if (isSelected) {
                        newSelected.remove(opt.id);
                      } else {
                        newSelected.add(opt.id);
                      }
                      context
                          .read<TakeQuizBloc>()
                          .add(SetAnswerEvent(newSelected));
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgColor ?? AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor ?? AppColors.cardBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: state.answerSubmitted
                          ? null
                          : (v) {
                              final newSelected =
                                  List<String>.from(selected);
                              if (v == true) {
                                if (!newSelected.contains(opt.id)) {
                                  newSelected.add(opt.id);
                                }
                              } else {
                                newSelected.remove(opt.id);
                              }
                              context
                                  .read<TakeQuizBloc>()
                                  .add(SetAnswerEvent(newSelected));
                            },
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(opt.text, style: AppTextStyles.bodySmall),
                    ),
                    if (state.answerSubmitted && opt.isCorrect)
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        );

      case QuestionType.textInput:
        return TextField(
          controller: _textController,
          enabled: !state.answerSubmitted,
          style: AppTextStyles.body,
          onChanged: (v) =>
              context.read<TakeQuizBloc>().add(SetAnswerEvent(v)),
          decoration: InputDecoration(
            hintText: 'Введите ваш ответ...',
            hintStyle: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: state.answerSubmitted
                ? (state.lastCorrect == true
                    ? AppColors.successLight
                    : AppColors.errorLight)
                : AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
    }
  }
}

class _TypeBadge extends StatelessWidget {
  final QuestionType type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final labels = {
      QuestionType.singleChoice: 'Один ответ',
      QuestionType.multiChoice: 'Несколько',
      QuestionType.textInput: 'Текст',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        labels[type] ?? '',
        style: AppTextStyles.caption,
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final bool correct;
  final String? explanation;

  const _FeedbackCard({required this.correct, this.explanation});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correct ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: correct ? AppColors.success : AppColors.error,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.check_circle : Icons.cancel,
            color: correct ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correct ? 'Правильно!' : 'Неправильно',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: correct ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (explanation != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    explanation!,
                    style: AppTextStyles.caption.copyWith(
                      color: correct
                          ? const Color(0xFF166534)
                          : const Color(0xFF7F1D1D),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
