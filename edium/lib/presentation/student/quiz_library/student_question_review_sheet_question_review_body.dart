part of 'student_question_review_sheet.dart';

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

        const Text('ОТВЕТ', style: AppTextStyles.sectionTag),
        const SizedBox(height: 8),
        _answerBody(q, a),
        const SizedBox(height: 20),

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

