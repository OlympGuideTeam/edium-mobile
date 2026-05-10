import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:flutter/material.dart';

part 'student_question_review_sheet_student_question_review_sheet.dart';
part 'student_question_review_sheet_handle.dart';
part 'student_question_review_sheet_sheet_top_bar.dart';
part 'student_question_review_sheet_question_review_body.dart';
part 'student_question_review_sheet_choice_answer_block.dart';
part 'student_question_review_sheet_option_badge.dart';
part 'student_question_review_sheet_given_answer_block.dart';
part 'student_question_review_sheet_drag_answer_block.dart';
part 'student_question_review_sheet_connection_answer_block.dart';
part 'student_question_review_sheet_free_answer_block.dart';
part 'student_question_review_sheet_teacher_grade_block.dart';
part 'student_question_review_sheet_student_question_review_mock_preview.dart';



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

