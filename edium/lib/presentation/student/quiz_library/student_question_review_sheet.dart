import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:flutter/material.dart';

// ── Public entry point ───────────────────────────────────────────────────────

class StudentQuestionReviewData {
  final int index;
  final int total;
  final QuizQuestionForStudent question;
  final AnswerSubmissionResult answer;

  const StudentQuestionReviewData({
    required this.index,
    required this.total,
    required this.question,
    required this.answer,
  });
}

Future<void> showStudentQuestionReview(
  BuildContext context, {
  required StudentQuestionReviewData data,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StudentQuestionReviewSheet(data: data),
  );
}

// ── Sheet ────────────────────────────────────────────────────────────────────

class _StudentQuestionReviewSheet extends StatelessWidget {
  final StudentQuestionReviewData data;
  const _StudentQuestionReviewSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.92;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Handle(),
          _SheetTopBar(
            index: data.index,
            total: data.total,
            onClose: () => Navigator.pop(context),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPaddingH, 0, AppDimens.screenPaddingH, 32),
              child: _QuestionReviewBody(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Handle ───────────────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.mono200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _SheetTopBar extends StatelessWidget {
  final int index;
  final int total;
  final VoidCallback onClose;

  const _SheetTopBar({
    required this.index,
    required this.total,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.screenPaddingH, 8, 8, 12),
      child: Row(
        children: [
          Text(
            'Вопрос $index из $total',
            style: AppTextStyles.screenTitle,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 22, color: AppColors.mono400),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _QuestionReviewBody extends StatelessWidget {
  final StudentQuestionReviewData data;
  const _QuestionReviewBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final q = data.question;
    final a = data.answer;
    final isFree = q.type == QuizQuestionType.withFreeAnswer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Текст вопроса
        Text(
          q.text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.mono900,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        // Секция ответа
        const Text('ОТВЕТ', style: AppTextStyles.sectionTag),
        const SizedBox(height: 8),
        _answerBody(q, a),
        const SizedBox(height: 20),
        // Для свободных ответов — балл и комментарий учителя
        if (isFree) ...[
          const Text('ОЦЕНКА УЧИТЕЛЯ', style: AppTextStyles.sectionTag),
          const SizedBox(height: 8),
          _TeacherGradeBlock(
            score: a.finalScore,
            maxScore: q.maxScore,
            feedback: a.finalFeedback,
          ),
        ],
      ],
    );
  }

  Widget _answerBody(QuizQuestionForStudent q, AnswerSubmissionResult a) {
    switch (q.type) {
      case QuizQuestionType.singleChoice:
        return _ChoiceAnswerBlock(
          options: q.options ?? [],
          selectedIds: {
            if (a.answerData['selected_option_id'] != null)
              a.answerData['selected_option_id'].toString()
          },
          correctIds: _correctIdsFrom(a),
        );
      case QuizQuestionType.multipleChoice:
        final selected =
            (a.answerData['selected_option_ids'] as List<dynamic>? ?? [])
                .map((e) => e.toString())
                .toSet();
        return _ChoiceAnswerBlock(
          options: q.options ?? [],
          selectedIds: selected,
          correctIds: _correctIdsFrom(a),
        );
      case QuizQuestionType.withGivenAnswer:
        final text = a.answerData['text']?.toString() ?? '';
        final correctList =
            (a.correctData?['correct_answers'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [];
        final isCorrect = correctList
            .map((c) => c.trim().toLowerCase())
            .contains(text.trim().toLowerCase());
        return _GivenAnswerBlock(
          studentText: text,
          correctAnswers: correctList,
          isCorrect: isCorrect,
        );
      case QuizQuestionType.withFreeAnswer:
        final text = a.answerData['text']?.toString() ?? '';
        return _FreeAnswerBlock(studentText: text);
      case QuizQuestionType.drag:
        final studentOrder =
            (a.answerData['order'] as List<dynamic>? ?? [])
                .map((e) => e.toString())
                .toList();
        final correctOrder =
            (a.correctData?['correct_order'] as List<dynamic>? ?? [])
                .map((e) => e.toString())
                .toList();
        return _DragAnswerBlock(
          studentOrder: studentOrder,
          correctOrder: correctOrder,
        );
      case QuizQuestionType.connection:
        final studentPairs =
            (a.answerData['pairs'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, v.toString()));
        final correctPairs =
            (a.correctData?['correct_pairs'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, v.toString()));
        return _ConnectionAnswerBlock(
          studentPairs: studentPairs,
          correctPairs: correctPairs,
        );
    }
  }

  Set<String> _correctIdsFrom(AnswerSubmissionResult a) {
    final raw = a.correctData?['correct_option_ids'];
    if (raw is List) return raw.map((e) => e.toString()).toSet();
    return {};
  }
}

// ── Choice answer block ──────────────────────────────────────────────────────

class _ChoiceAnswerBlock extends StatelessWidget {
  final List<QuestionOptionForStudent> options;
  final Set<String> selectedIds;
  final Set<String> correctIds;

  const _ChoiceAnswerBlock({
    required this.options,
    required this.selectedIds,
    required this.correctIds,
  });

  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((o) {
        final isPicked = selectedIds.contains(o.id);
        final isCorrect = correctIds.contains(o.id);

        // Цвет строки
        final Color bg;
        final Color border;
        if (isCorrect && isPicked) {
          bg = _greenBg;
          border = _green;
        } else if (isCorrect && !isPicked) {
          bg = _greenBg;
          border = _green;
        } else if (!isCorrect && isPicked) {
          bg = _redBg;
          border = _red;
        } else {
          bg = Colors.white;
          border = AppColors.mono150;
        }

        // Лейбл справа
        Widget? badge;
        if (isCorrect && isPicked) {
          badge = _OptionBadge(label: 'Ваш ответ ✓', color: _green);
        } else if (isCorrect && !isPicked) {
          badge = _OptionBadge(label: 'Правильно', color: _green);
        } else if (!isCorrect && isPicked) {
          badge = _OptionBadge(label: 'Ваш ответ', color: _red);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  o.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: (isCorrect || isPicked)
                        ? AppColors.mono900
                        : AppColors.mono400,
                    fontWeight: isCorrect
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                badge,
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _OptionBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _OptionBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Given answer block ───────────────────────────────────────────────────────

class _GivenAnswerBlock extends StatelessWidget {
  final String studentText;
  final List<String> correctAnswers;
  final bool isCorrect;

  const _GivenAnswerBlock({
    required this.studentText,
    required this.correctAnswers,
    required this.isCorrect,
  });

  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    final hasAnswer = studentText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ваш ответ', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: !hasAnswer
                ? AppColors.mono50
                : isCorrect
                    ? _greenBg
                    : _redBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(
              color: !hasAnswer
                  ? AppColors.mono150
                  : isCorrect
                      ? _green
                      : _red,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasAnswer ? studentText : '— нет ответа —',
                  style: TextStyle(
                    fontSize: 14,
                    color: !hasAnswer
                        ? AppColors.mono400
                        : isCorrect
                            ? _green
                            : _red,
                  ),
                ),
              ),
              if (hasAnswer)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: isCorrect ? _green : _red,
                ),
            ],
          ),
        ),
        if (correctAnswers.isNotEmpty && !isCorrect) ...[
          const SizedBox(height: 8),
          Text('Верный ответ', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _greenBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              border: Border.all(color: _green),
            ),
            child: Text(
              correctAnswers.first,
              style: const TextStyle(fontSize: 14, color: _green),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Drag answer block ─────────────────────────────────────────────────────────

class _DragAnswerBlock extends StatelessWidget {
  final List<String> studentOrder;
  final List<String> correctOrder;

  const _DragAnswerBlock({
    required this.studentOrder,
    required this.correctOrder,
  });

  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);

  bool get _isFullyCorrect =>
      studentOrder.length == correctOrder.length &&
      List.generate(studentOrder.length, (i) => studentOrder[i] == correctOrder[i])
          .every((b) => b);

  @override
  Widget build(BuildContext context) {
    if (studentOrder.isEmpty) {
      return _emptyAnswer();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ваш порядок', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),
        ...studentOrder.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final isCorrectPos = i < correctOrder.length && correctOrder[i] == item;
          return Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isCorrectPos ? _greenBg : _redBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              border: Border.all(color: isCorrectPos ? _green : _red),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isCorrectPos ? _green : _red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCorrectPos ? _green : _red,
                    ),
                  ),
                ),
                Icon(
                  isCorrectPos ? Icons.check : Icons.close,
                  size: 15,
                  color: isCorrectPos ? _green : _red,
                ),
              ],
            ),
          );
        }),
        if (!_isFullyCorrect) ...[
          const SizedBox(height: 12),
          Text('Правильный порядок', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 6),
          ...correctOrder.asMap().entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _greenBg,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  border: Border.all(color: _green),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 14, color: _green),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _emptyAnswer() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.mono50,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          border: Border.all(color: AppColors.mono150),
        ),
        child: const Text('— нет ответа —',
            style: TextStyle(fontSize: 14, color: AppColors.mono400)),
      );
}

// ── Connection answer block ───────────────────────────────────────────────────

class _ConnectionAnswerBlock extends StatelessWidget {
  final Map<String, String> studentPairs;
  final Map<String, String> correctPairs;

  const _ConnectionAnswerBlock({
    required this.studentPairs,
    required this.correctPairs,
  });

  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    if (studentPairs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.mono50,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          border: Border.all(color: AppColors.mono150),
        ),
        child: const Text('— нет ответа —',
            style: TextStyle(fontSize: 14, color: AppColors.mono400)),
      );
    }

    final keys = correctPairs.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: keys.map((left) {
        final studentRight = studentPairs[left];
        final correctRight = correctPairs[left];
        final isCorrect = studentRight == correctRight;

        return Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCorrect ? _greenBg : _redBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: isCorrect ? _green : _red),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                left,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isCorrect ? _green : _red,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.arrow_forward,
                      size: 13,
                      color: isCorrect ? _green : _red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      studentRight ?? '—',
                      style: TextStyle(
                        fontSize: 13,
                        color: isCorrect ? _green : _red,
                      ),
                    ),
                  ),
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    size: 15,
                    color: isCorrect ? _green : _red,
                  ),
                ],
              ),
              if (!isCorrect && correctRight != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check,
                        size: 13, color: _green),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        correctRight,
                        style: const TextStyle(fontSize: 13, color: _green),
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
}

// ── Free answer block ─────────────────────────────────────────────────────────

class _FreeAnswerBlock extends StatelessWidget {
  final String studentText;
  const _FreeAnswerBlock({required this.studentText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Text(
        studentText.isEmpty ? '— нет ответа —' : studentText,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.mono700,
          height: 1.5,
        ),
      ),
    );
  }
}

// ── Teacher grade block ───────────────────────────────────────────────────────

class _TeacherGradeBlock extends StatelessWidget {
  final double? score;
  final int maxScore;
  final String? feedback;

  const _TeacherGradeBlock({
    required this.score,
    required this.maxScore,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Балл
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.mono150),
          ),
          child: Row(
            children: [
              const Text('Балл', style: AppTextStyles.fieldLabel),
              const Spacer(),
              if (score != null)
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: score!.toStringAsFixed(
                            score! % 1 == 0 ? 0 : 1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mono900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: ' / $maxScore',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mono300,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Text('—',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mono300)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Комментарий
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.mono150),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Комментарий', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 8),
              if (feedback != null && feedback!.isNotEmpty)
                Text(
                  feedback!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mono700,
                    height: 1.5,
                  ),
                )
              else
                Row(
                  children: const [
                    Icon(Icons.chat_bubble_outline,
                        size: 14, color: AppColors.mono300),
                    SizedBox(width: 8),
                    Text(
                      'Комментарий не добавлен',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mono300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Mock preview widget ───────────────────────────────────────────────────────
// Удалить после проверки на реальных данных.

class StudentQuestionReviewMockPreview extends StatelessWidget {
  const StudentQuestionReviewMockPreview({super.key});

  // Логика и алгоритмы (quiz-004) + доп. типы
  static final _mockQuestions = [
    // 1. drag — неверный порядок
    const QuizQuestionForStudent(
      id: 'q004-1',
      type: QuizQuestionType.drag,
      text: 'Расставьте этапы разработки в правильном порядке:',
      maxScore: 10,
      metadata: {
        'items': ['Тестирование', 'Дизайн', 'Требования', 'Разработка'],
        'correct_order': ['Требования', 'Дизайн', 'Разработка', 'Тестирование'],
      },
    ),
    // 2. connection — частично неверный
    const QuizQuestionForStudent(
      id: 'q004-2',
      type: QuizQuestionType.connection,
      text: 'Сопоставьте концепцию с её определением:',
      maxScore: 10,
      metadata: {
        'left': ['Инкапсуляция', 'Наследование', 'Полиморфизм'],
        'right': [
          'Переопределение методов',
          'Скрытие данных',
          'Расширение класса',
        ],
        'correct_pairs': {
          'Инкапсуляция': 'Скрытие данных',
          'Наследование': 'Расширение класса',
          'Полиморфизм': 'Переопределение методов',
        },
      },
    ),
    // 3. single_choice — неверный
    const QuizQuestionForStudent(
      id: 'q001-1',
      type: QuizQuestionType.singleChoice,
      text: 'Какой тип является nullable в Dart?',
      maxScore: 10,
      options: [
        QuestionOptionForStudent(id: 'q001-1-a', text: 'int'),
        QuestionOptionForStudent(id: 'q001-1-b', text: 'int?'),
        QuestionOptionForStudent(id: 'q001-1-c', text: 'String'),
        QuestionOptionForStudent(id: 'q001-1-d', text: 'dynamic'),
      ],
      metadata: {'correct_option_ids': ['q001-1-b']},
    ),
    // 4. with_given_answer — верный
    const QuizQuestionForStudent(
      id: 'q001-3',
      type: QuizQuestionType.withGivenAnswer,
      text: 'Напишите ключевое слово для асинхронной функции в Dart.',
      maxScore: 10,
      metadata: {
        'correct_answers': ['async', 'async*'],
      },
    ),
    // 5. with_free_answer — с комментарием учителя
    const QuizQuestionForStudent(
      id: 'q001-4',
      type: QuizQuestionType.withFreeAnswer,
      text: 'Объясните разницу между final и const в Dart.',
      maxScore: 10,
    ),
    // 6. with_free_answer — без комментария
    const QuizQuestionForStudent(
      id: 'q003-3',
      type: QuizQuestionType.withFreeAnswer,
      text: 'Опишите значение реформ Петра I для развития России.',
      maxScore: 10,
    ),
  ];

  static final _mockAnswers = [
    // drag — неверный порядок
    const AnswerSubmissionResult(
      questionId: 'q004-1',
      answerData: {
        'order': ['Дизайн', 'Требования', 'Тестирование', 'Разработка'],
      },
      finalScore: 0,
      finalSource: 'auto',
      correctData: {
        'correct_order': ['Требования', 'Дизайн', 'Разработка', 'Тестирование'],
      },
    ),
    // connection — инкапсуляция и полиморфизм перепутаны
    const AnswerSubmissionResult(
      questionId: 'q004-2',
      answerData: {
        'pairs': {
          'Инкапсуляция': 'Переопределение методов',
          'Наследование': 'Расширение класса',
          'Полиморфизм': 'Скрытие данных',
        },
      },
      finalScore: 0,
      finalSource: 'auto',
      correctData: {
        'correct_pairs': {
          'Инкапсуляция': 'Скрытие данных',
          'Наследование': 'Расширение класса',
          'Полиморфизм': 'Переопределение методов',
        },
      },
    ),
    // single_choice — выбрал int вместо int?
    const AnswerSubmissionResult(
      questionId: 'q001-1',
      answerData: {'selected_option_id': 'q001-1-a'},
      finalScore: 0,
      finalSource: 'auto',
      correctData: {'correct_option_ids': ['q001-1-b']},
    ),
    // with_given_answer — верный
    const AnswerSubmissionResult(
      questionId: 'q001-3',
      answerData: {'text': 'async'},
      finalScore: 10,
      finalSource: 'auto',
      correctData: {'correct_answers': ['async', 'async*']},
    ),
    // with_free_answer — с комментарием
    const AnswerSubmissionResult(
      questionId: 'q001-4',
      answerData: {
        'text':
            'final — значение присваивается один раз во время выполнения, const — компилируемая константа.',
      },
      finalScore: 8,
      finalSource: 'teacher',
      finalFeedback: 'Хорошо, но стоило привести пример с объектами.',
    ),
    // with_free_answer — без комментария
    const AnswerSubmissionResult(
      questionId: 'q003-3',
      answerData: {
        'text': 'Пётр I провёл военные, административные и культурные реформы.',
      },
      finalScore: 7,
      finalSource: 'teacher',
      finalFeedback: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      appBar: AppBar(
        title: const Text('Мок: разбор вопросов'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.mono900,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimens.screenPaddingH),
        itemCount: _mockQuestions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final q = _mockQuestions[i];
          final a = _mockAnswers[i];
          return GestureDetector(
            onTap: () => showStudentQuestionReview(
              context,
              data: StudentQuestionReviewData(
                index: i + 1,
                total: _mockQuestions.length,
                question: q,
                answer: a,
              ),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(color: AppColors.mono150),
              ),
              child: Row(
                children: [
                  Text(
                    '${i + 1}.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.mono400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      q.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.mono900),
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.mono300),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
