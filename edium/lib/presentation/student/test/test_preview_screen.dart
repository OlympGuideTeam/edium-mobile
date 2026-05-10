import 'dart:async';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/quiz_attempt.dart'
    show AttemptResult, AnswerSubmissionResult, QuizQuestionForStudent;
import 'package:edium/domain/entities/test_session_meta.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/quiz_result_screen.dart';
import 'package:edium/presentation/student/quiz_library/take_quiz_screen.dart';
import 'package:edium/presentation/student/test/bloc/test_preview_bloc.dart';
import 'package:edium/presentation/student/test/bloc/test_preview_event.dart';
import 'package:edium/presentation/student/test/bloc/test_preview_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

part 'test_preview_screen_test_preview_view.dart';
part 'test_preview_screen_back_row.dart';
part 'test_preview_screen_error_body.dart';
part 'test_preview_screen_loaded_body.dart';
part 'test_preview_screen_status_hero.dart';
part 'test_preview_screen_details_section.dart';
part 'test_preview_screen_detail_row.dart';
part 'test_preview_screen_scheduled_banner.dart';
part 'test_preview_screen_count_unit.dart';
part 'test_preview_screen_warning_block.dart';
part 'test_preview_screen_bottom_cta.dart';


class TestPreviewScreen extends StatelessWidget {
  final String sessionId;
  final CourseItem? courseItem;
  final String? quizTitle;
  final String? courseId;

  const TestPreviewScreen({
    super.key,
    required this.sessionId,
    this.courseItem,
    this.quizTitle,
    this.courseId,
  });

  TestSessionMeta _buildMeta() {
    final item = courseItem;
    final quizId = item?.quizTemplateId ?? item?.refId ?? sessionId;
    return TestSessionMeta(
      sessionId: sessionId,
      quizId: quizId,
      title: item?.title ?? quizTitle ?? 'Тест',
      description: null,
      questionCount: 0,
      needEvaluation: item?.needEvaluation ?? false,
      totalTimeLimitSec: item?.payload?.totalTimeLimitSec,
      shuffleQuestions: item?.payload?.shuffleQuestions,
      startedAt: item?.startTime,
      finishedAt: item?.endTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = _buildMeta();
    return BlocProvider(
      create: (_) => TestPreviewBloc(
        repo: getIt(),
        getReview: getIt(),
      )..add(LoadTestPreviewEvent(
          meta: meta,
          initialAttemptId: courseItem?.attemptId,
        )),
      child: _TestPreviewView(sessionId: sessionId, courseId: courseId),
    );
  }
}

