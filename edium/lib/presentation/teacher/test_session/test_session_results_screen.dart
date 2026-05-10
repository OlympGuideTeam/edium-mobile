import 'dart:async';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/quiz_attempt.dart'
    show AttemptStatus, QuizQuestionForStudent, AnswerSubmissionResult, AttemptResult;
import 'package:edium/domain/usecases/test_session/get_attempt_review_usecase.dart';
import 'package:edium/presentation/student/quiz_library/quiz_result_screen.dart';
import 'package:edium/presentation/teacher/test_session/bloc/test_session_results_bloc.dart';
import 'package:edium/presentation/teacher/test_session/bloc/test_session_results_event.dart';
import 'package:edium/presentation/teacher/test_session/bloc/test_session_results_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

part 'test_session_results_screen_student_result_screen.dart';
part 'test_session_results_screen_view.dart';
part 'test_session_results_screen_top_bar.dart';
part 'test_session_results_screen_status_hero.dart';
part 'test_session_results_screen_countdown_banner.dart';
part 'test_session_results_screen_count_unit.dart';
part 'test_session_results_screen_details_section.dart';
part 'test_session_results_screen_detail_row.dart';
part 'test_session_results_screen_section_header.dart';
part 'test_session_results_screen_student_row_tile.dart';
part 'test_session_results_screen_status_badge.dart';
part 'test_session_results_screen_grade_chip.dart';
part 'test_session_results_screen_action_buttons.dart';
part 'test_session_results_screen_finish_button.dart';
part 'test_session_results_screen_publish_button.dart';
part 'test_session_results_screen_delete_button.dart';


class TestSessionResultsScreen extends StatelessWidget {
  final String sessionId;
  final CourseItem? courseItem;
  final bool isTeacher;
  final String? moduleId;

  const TestSessionResultsScreen({
    super.key,
    required this.sessionId,
    this.courseItem,
    this.isTeacher = false,
    this.moduleId,
  });

  @override
  Widget build(BuildContext context) {

    if (!isTeacher) {
      final attemptId = courseItem?.attemptId;
      if (attemptId != null) {
        return _StudentResultScreen(
          attemptId: attemptId,
          quizTitle: courseItem?.title ?? 'Тест',
        );
      }


      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onBack: () => context.pop()),
              Expanded(
                child: Center(
                  child: Text('Нет доступа', style: AppTextStyles.screenSubtitle),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final title = courseItem?.title ?? 'Тест';
    return BlocProvider(
      create: (_) => TestSessionResultsBloc(
        listAttempts: getIt(),
        liveRepo: getIt(),
        courseRepo: getIt(),
        testSessionRepo: getIt(),
      )..add(LoadSessionResultsEvent(
          sessionId: sessionId,
          title: title,
          moduleId: moduleId,
          courseItemId: courseItem?.id,
          startedAt: courseItem?.startTime ?? courseItem?.payload?.startedAt,
          finishedAt: courseItem?.endTime ?? courseItem?.payload?.finishedAt,
        )),
      child: _View(sessionId: sessionId, courseItem: courseItem),
    );
  }
}

