import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show QuizQuestionType;
import 'package:edium/presentation/shared/test/bloc/attempt_review_bloc.dart';
import 'package:edium/presentation/shared/test/bloc/attempt_review_event.dart';
import 'package:edium/presentation/shared/test/bloc/attempt_review_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AttemptReviewScreen extends StatelessWidget {
  final String attemptId;
  const AttemptReviewScreen({super.key, required this.attemptId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttemptReviewBloc(getIt())
        ..add(LoadAttemptReviewEvent(attemptId)),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: AppColors.mono900),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AttemptReviewBloc, AttemptReviewBlocState>(
                builder: (context, state) {
                  if (state is AttemptReviewLoading ||
                      state is AttemptReviewInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.mono700, strokeWidth: 2),
                    );
                  }
                  if (state is AttemptReviewError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(state.message,
                            style: AppTextStyles.screenSubtitle,
                            textAlign: TextAlign.center),
                      ),
                    );
                  }
                  if (state is AttemptReviewLoaded) {
                    return _body(state.review);
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

  Widget _body(AttemptReview review) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPaddingH, 0, AppDimens.screenPaddingH, 32),
      children: [
        const SizedBox(height: 8),
        Text('Разбор попытки',
            style: AppTextStyles.screenTitle.copyWith(fontSize: 22)),
        const SizedBox(height: 6),
        Text(
          review.score != null
              ? 'Итоговый балл: ${review.score!.toStringAsFixed(0)}'
              : 'Балл ещё не выставлен',
          style: AppTextStyles.screenSubtitle,
        ),
        const SizedBox(height: 20),
        ...review.answers.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _QuestionCard(index: e.key + 1, answer: e.value),
          );
        }),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final AnswerReview answer;
  const _QuestionCard({required this.index, required this.answer});

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
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.mono100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('$index',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mono600,
                      )),
                ),
              ),
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
          _answerBlock(answer),
          if (answer.finalFeedback != null &&
              answer.finalFeedback!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              answer.finalFeedback!,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mono600,
                  fontStyle: FontStyle.italic),
            ),
          ],
          if (answer.finalSource != null) ...[
            const SizedBox(height: 6),
            Text(
              _sourceLabel(answer.finalSource!),
              style: AppTextStyles.caption.copyWith(color: AppColors.mono300),
            ),
          ],
        ],
      ),
    );
  }

  String _sourceLabel(String s) {
    switch (s) {
      case 'auto':
        return 'Проверено автоматически';
      case 'llm':
        return 'Проверено ИИ';
      case 'teacher':
        return 'Проверено учителем';
      default:
        return s;
    }
  }

  Widget _answerBlock(AnswerReview a) {
    switch (a.questionType) {
      case QuizQuestionType.singleChoice:
        return _singleChoiceBlock(a);
      case QuizQuestionType.multipleChoice:
        return _multiChoiceBlock(a);
      case QuizQuestionType.withGivenAnswer:
        return _givenAnswerBlock(a);
      case QuizQuestionType.withFreeAnswer:
        return _freeAnswerBlock(a);
      case QuizQuestionType.drag:
        return _dragBlock(a);
      case QuizQuestionType.connection:
        return _connectionBlock(a);
    }
  }

  Widget _singleChoiceBlock(AnswerReview a) {
    final picked = a.answerData['selected_option_id'] as String?;
    final options = a.options ?? const [];
    if (options.isEmpty && picked != null) {
      return Text('Выбран вариант: $picked',
          style: const TextStyle(fontSize: 13, color: AppColors.mono700));
    }
    return Column(
      children: options.map((o) {
        final isPicked = o.id == picked;
        final isCorrect = o.isCorrect;
        return _OptionLine(text: o.text, isPicked: isPicked, isCorrect: isCorrect);
      }).toList(),
    );
  }

  Widget _multiChoiceBlock(AnswerReview a) {
    final picked = (a.answerData['selected_option_ids'] as List<dynamic>? ??
            const [])
        .map((e) => e.toString())
        .toSet();
    final options = a.options ?? const [];
    if (options.isEmpty) {
      return Text('Выбрано: ${picked.join(", ")}',
          style: const TextStyle(fontSize: 13, color: AppColors.mono700));
    }
    return Column(
      children: options.map((o) {
        final isPicked = picked.contains(o.id);
        return _OptionLine(
            text: o.text, isPicked: isPicked, isCorrect: o.isCorrect);
      }).toList(),
    );
  }

  Widget _givenAnswerBlock(AnswerReview a) {
    final text = a.answerData['text']?.toString() ?? '';
    final correct = (a.metadata?['correct_answers'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ваш ответ: $text',
            style: const TextStyle(fontSize: 13, color: AppColors.mono900)),
        if (correct != null && correct.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Верные: ${correct.join(", ")}',
              style: AppTextStyles.caption.copyWith(color: AppColors.mono400)),
        ],
      ],
    );
  }

  Widget _freeAnswerBlock(AnswerReview a) {
    final text = a.answerData['text']?.toString() ?? '';
    return Text(text,
        style: const TextStyle(
            fontSize: 13, color: AppColors.mono900, height: 1.4));
  }

  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);

  Widget _dragBlock(AnswerReview a) {
    final studentOrder = (a.answerData['order'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    final correctOrder = (a.metadata?['correct_order'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    if (studentOrder.isEmpty) return _emptyBlock();

    final isFullyCorrect = correctOrder.isNotEmpty &&
        studentOrder.length == correctOrder.length &&
        List.generate(
          studentOrder.length,
          (i) => studentOrder[i] == correctOrder[i],
        ).every((b) => b);

    if (isFullyCorrect || correctOrder.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: studentOrder.asMap().entries.map((e) {
          return _OrderItem(
            index: e.key + 1,
            text: e.value,
            isCorrect: true,
            showIcon: false,
          );
        }).toList(),
      );
    }

    final count = studentOrder.length > correctOrder.length
        ? studentOrder.length
        : correctOrder.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ВАШ ОТВЕТ', style: AppTextStyles.sectionTag),
              const SizedBox(height: 6),
              ...List.generate(count, (i) {
                final text =
                    i < studentOrder.length ? studentOrder[i] : '—';
                final isCorrect = i < correctOrder.length &&
                    i < studentOrder.length &&
                    studentOrder[i] == correctOrder[i];
                return _OrderItem(
                    index: i + 1,
                    text: text,
                    isCorrect: isCorrect,
                    showIcon: true);
              }),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ПРАВИЛЬНО', style: AppTextStyles.sectionTag),
              const SizedBox(height: 6),
              ...List.generate(count, (i) {
                final text =
                    i < correctOrder.length ? correctOrder[i] : '—';
                return _OrderItem(
                    index: i + 1,
                    text: text,
                    isCorrect: true,
                    showIcon: false);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _connectionBlock(AnswerReview a) {
    final studentPairs =
        (a.answerData['pairs'] as Map<String, dynamic>? ?? const {})
            .map((k, v) => MapEntry(k, v.toString()));
    final correctPairs =
        (a.metadata?['correct_pairs'] as Map<String, dynamic>? ?? const {})
            .map((k, v) => MapEntry(k, v.toString()));

    if (studentPairs.isEmpty) return _emptyBlock();

    final keys = correctPairs.isNotEmpty
        ? correctPairs.keys.toList()
        : studentPairs.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: keys.map((left) {
        final studentRight = studentPairs[left];
        final correctRight = correctPairs[left];
        final isCorrect =
            studentRight != null && studentRight == correctRight;
        final color = isCorrect ? _green : _red;
        final bgColor = isCorrect ? _greenBg : _redBg;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                left,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.arrow_forward, size: 12, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      studentRight ?? '—',
                      style: TextStyle(fontSize: 13, color: color),
                    ),
                  ),
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    size: 14,
                    color: color,
                  ),
                ],
              ),
              if (!isCorrect && correctRight != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check, size: 12, color: _green),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        correctRight,
                        style: const TextStyle(
                            fontSize: 13, color: _green),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyBlock() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.mono50,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          border: Border.all(color: AppColors.mono150),
        ),
        child: const Text('— нет ответа —',
            style: TextStyle(fontSize: 13, color: AppColors.mono400)),
      );
}

class _OrderItem extends StatelessWidget {
  final int index;
  final String text;
  final bool isCorrect;
  final bool showIcon;

  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);

  const _OrderItem({
    required this.index,
    required this.text,
    required this.isCorrect,
    required this.showIcon,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? _green : _red;
    final bgColor = isCorrect ? _greenBg : _redBg;

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: color, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showIcon) ...[
            const SizedBox(width: 4),
            Icon(
              isCorrect ? Icons.check : Icons.close,
              size: 12,
              color: color,
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionLine extends StatelessWidget {
  final String text;
  final bool isPicked;
  final bool isCorrect;

  const _OptionLine({
    required this.text,
    required this.isPicked,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isCorrect
        ? const Color(0xFFE8F5E9)
        : (isPicked ? const Color(0xFFFEE2E2) : Colors.white);
    final borderColor = isCorrect
        ? const Color(0xFF22C55E)
        : (isPicked ? const Color(0xFFEF4444) : AppColors.mono150);

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
            isPicked
                ? (isCorrect ? Icons.check_circle : Icons.cancel)
                : (isCorrect ? Icons.check : Icons.radio_button_unchecked),
            size: 16,
            color: isCorrect
                ? const Color(0xFF22C55E)
                : (isPicked ? const Color(0xFFEF4444) : AppColors.mono300),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.mono900)),
          ),
        ],
      ),
    );
  }
}
