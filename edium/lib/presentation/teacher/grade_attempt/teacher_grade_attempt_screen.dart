import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show QuizQuestionType;
import 'package:edium/presentation/shared/widgets/question_image_widget.dart';
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_bloc.dart';
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_event.dart';
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'teacher_grade_attempt_screen_view.dart';
part 'teacher_grade_attempt_screen_grade_body.dart';
part 'teacher_grade_attempt_screen_free_answer_inline_card.dart';
part 'teacher_grade_attempt_screen_readonly_answer_card.dart';
part 'teacher_grade_attempt_screen_index_badge.dart';
part 'teacher_grade_attempt_screen_top_bar.dart';
part 'teacher_grade_attempt_screen_submit_button.dart';
part 'teacher_grade_attempt_screen_score_picker.dart';
part 'teacher_grade_attempt_screen_score_row.dart';
part 'teacher_grade_attempt_screen_score_chip.dart';


class TeacherGradeAttemptScreen extends StatelessWidget {
  final String attemptId;

  const TeacherGradeAttemptScreen({super.key, required this.attemptId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeacherGradeBloc(
        getReview: getIt(),
        gradeSubmission: getIt(),
      )..add(LoadTeacherGradeEvent(attemptId)),
      child: _View(attemptId: attemptId),
    );
  }
}

