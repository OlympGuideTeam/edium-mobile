import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show QuizQuestionType;
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_bloc.dart';
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_event.dart';
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_state.dart';
import 'package:edium/presentation/teacher/grade_attempt/teacher_grade_question_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TeacherGradeAttemptScreen extends StatelessWidget {
  final String attemptId;

  const TeacherGradeAttemptScreen({super.key, required this.attemptId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeacherGradeBloc(
        getReview: getIt(),
        gradeSubmission: getIt(),
        completeAttempt: getIt(),
      )..add(LoadTeacherGradeEvent(attemptId)),
      child: _View(attemptId: attemptId),
    );
  }
}

class _View extends StatelessWidget {
  final String attemptId;
  const _View({required this.attemptId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherGradeBloc, TeacherGradeState>(
      listener: (ctx, state) {
        if (state is TeacherGradeCompleted) {
          ctx.pop();
        }
        if (state is TeacherGradeLoaded && state.saveError != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                'Ошибка сохранения: ${state.saveError}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.mono900,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(onBack: () => context.pop()),
                Expanded(child: _body(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, TeacherGradeState state) {
    if (state is TeacherGradeLoading || state is TeacherGradeInitial) {
      return const Center(
        child: CircularProgressIndicator(
            color: AppColors.mono700, strokeWidth: 2),
      );
    }
    if (state is TeacherGradeError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(state.message,
              style: AppTextStyles.screenSubtitle,
              textAlign: TextAlign.center),
        ),
      );
    }
    if (state is TeacherGradeLoaded) {
      return _GradeBody(
        review: state.review,
        isSaving: state.isSaving,
        attemptId: attemptId,
      );
    }
    return const SizedBox.shrink();
  }
}

class _GradeBody extends StatelessWidget {
  final AttemptReview review;
  final bool isSaving;
  final String attemptId;

  const _GradeBody({
    required this.review,
    required this.isSaving,
    required this.attemptId,
  });

  bool get _isReadyToSubmit => review.answers
      .where((a) => a.questionType == QuizQuestionType.withFreeAnswer)
      .every((a) => a.finalScore != null);

  @override
  Widget build(BuildContext context) {
    final answers = review.answers;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPaddingH, 0, AppDimens.screenPaddingH, 16),
            children: [
              const SizedBox(height: 8),
              const Text('Проверка работы', style: AppTextStyles.screenTitle),
              const SizedBox(height: 6),
              Text(
                review.score != null
                    ? 'Текущий балл: ${review.score!.toStringAsFixed(0)}'
                    : 'Балл не выставлен',
                style: AppTextStyles.screenSubtitle,
              ),
              const SizedBox(height: 20),
              ...answers.asMap().entries.map((e) {
                final answer = e.value;
                if (answer.questionType == QuizQuestionType.withFreeAnswer) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FreeAnswerSummaryCard(
                      index: e.key + 1,
                      answer: answer,
                      onTap: () => _openGrading(context, answer, e.key + 1),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReadonlyAnswerCard(index: e.key + 1, answer: answer),
                );
              }),
            ],
          ),
        ),
        _SubmitButton(
          isSaving: isSaving,
          isReady: _isReadyToSubmit,
          onTap: () {
            context
                .read<TeacherGradeBloc>()
                .add(CompleteGradingEvent(attemptId));
          },
        ),
      ],
    );
  }

  Future<void> _openGrading(
      BuildContext context, AnswerReview answer, int index) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherGradeQuestionScreen(
          attemptId: attemptId,
          answer: answer,
          index: index,
        ),
      ),
    );
    if (result == true && context.mounted) {
      context.read<TeacherGradeBloc>().add(LoadTeacherGradeEvent(attemptId));
    }
  }
}

// ── Tappable summary-карточка free-answer ───────────────────────────────────

class _FreeAnswerSummaryCard extends StatelessWidget {
  final int index;
  final AnswerReview answer;
  final VoidCallback onTap;

  const _FreeAnswerSummaryCard({
    required this.index,
    required this.answer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final studentText = answer.answerData['text']?.toString() ?? '';
    final hasScore = answer.finalScore != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.mono25,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: hasScore ? AppColors.mono300 : AppColors.mono150,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IndexBadge(index: index),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    answer.questionText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mono900,
                      height: 1.3,
                    ),
                  ),
                ),
                if (hasScore)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.mono900,
                      borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                    ),
                    child: Text(
                      answer.finalScore!.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.mono300),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.mono100,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Text(
                studentText.isEmpty ? '— нет ответа —' : studentText,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.mono700, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            if (!hasScore)
              Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.mono400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ИИ проверяет · Нажмите, чтобы оценить самостоятельно',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.mono400),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Icon(
                    answer.finalSource == 'teacher'
                        ? Icons.check_circle_outline
                        : Icons.auto_awesome,
                    size: 14,
                    color: AppColors.mono400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    answer.finalSource == 'teacher'
                        ? 'Вы оценили · Нажмите, чтобы изменить'
                        : 'Оценено ИИ · Нажмите, чтобы изменить',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.mono400),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ── Read-only карточка ────────────────────────────────────────────────────

class _ReadonlyAnswerCard extends StatelessWidget {
  final int index;
  final AnswerReview answer;

  const _ReadonlyAnswerCard({required this.index, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IndexBadge(index: index),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  answer.questionText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                    height: 1.3,
                  ),
                ),
              ),
              if (answer.finalScore != null)
                Text(
                  answer.finalScore!.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                )
              else
                const Text('—',
                    style: TextStyle(fontSize: 14, color: AppColors.mono300)),
            ],
          ),
          const SizedBox(height: 10),
          _answerPreview(answer),
        ],
      ),
    );
  }

  Widget _answerPreview(AnswerReview a) {
    switch (a.questionType) {
      case QuizQuestionType.singleChoice:
        final picked = a.answerData['selected_option_id'] as String?;
        return _optionsList(a.options ?? [], {if (picked != null) picked});
      case QuizQuestionType.multipleChoice:
        final picked = (a.answerData['selected_option_ids'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toSet();
        return _optionsList(a.options ?? [], picked);
      case QuizQuestionType.withGivenAnswer:
        final text = a.answerData['text']?.toString() ?? '';
        final correct = (a.metadata?['correct_answers'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ответ: $text',
                style: const TextStyle(fontSize: 13, color: AppColors.mono900)),
            if (correct != null)
              Text('Верные: ${correct.join(", ")}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.mono400)),
          ],
        );
      default:
        final raw = a.answerData.toString();
        return Text(raw,
            style: const TextStyle(fontSize: 13, color: AppColors.mono700));
    }
  }

  Widget _optionsList(List<TeacherAnswerOption> options, Set<String> picked) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Column(
      children: options.map((o) {
        final ip = picked.contains(o.id);
        final ic = o.isCorrect;
        final bg = ic
            ? const Color(0xFFE8F5E9)
            : (ip ? const Color(0xFFFEE2E2) : Colors.white);
        final borderColor = ic
            ? const Color(0xFF22C55E)
            : (ip ? const Color(0xFFEF4444) : AppColors.mono150);
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                ip
                    ? (ic ? Icons.check_circle : Icons.cancel)
                    : (ic ? Icons.check : Icons.radio_button_unchecked),
                size: 16,
                color: ic
                    ? const Color(0xFF22C55E)
                    : (ip ? const Color(0xFFEF4444) : AppColors.mono300),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(o.text,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.mono900)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────

class _IndexBadge extends StatelessWidget {
  final int index;
  const _IndexBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.mono100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '$index',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.mono600,
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: AppColors.mono900),
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isSaving;
  final bool isReady;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.isSaving,
    required this.isReady,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = isReady && !isSaving;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPaddingH, 8, AppDimens.screenPaddingH, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isReady && !isSaving)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Оцените все вопросы с развёрнутым ответом',
                style: AppTextStyles.caption.copyWith(color: AppColors.mono400),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: AppDimens.buttonH,
            child: ElevatedButton(
              onPressed: enabled ? onTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mono900,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.mono200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                ),
                elevation: 0,
                textStyle: AppTextStyles.primaryButton,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Завершить проверку'),
            ),
          ),
        ],
      ),
    );
  }
}
