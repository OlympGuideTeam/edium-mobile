import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:edium/presentation/teacher/test_monitoring/bloc/test_monitoring_bloc.dart';
import 'package:edium/presentation/teacher/test_monitoring/bloc/test_monitoring_event.dart';
import 'package:edium/presentation/teacher/test_monitoring/bloc/test_monitoring_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'test_monitoring_screen_view.dart';
part 'test_monitoring_screen_loaded_body.dart';
part 'test_monitoring_screen_stats_strip.dart';
part 'test_monitoring_screen_stat_cell.dart';
part 'test_monitoring_screen_divider.dart';
part 'test_monitoring_screen_grading_banner.dart';
part 'test_monitoring_screen_monitoring_row_tile.dart';
part 'test_monitoring_screen_avatar.dart';
part 'test_monitoring_screen_trailing_section.dart';
part 'test_monitoring_screen_chip.dart';
part 'test_monitoring_screen_top_bar.dart';


class TestMonitoringScreen extends StatelessWidget {
  final String sessionId;
  final String classId;
  final CourseItem? courseItem;

  const TestMonitoringScreen({
    super.key,
    required this.sessionId,
    required this.classId,
    this.courseItem,
  });

  @override
  Widget build(BuildContext context) {
    final title = courseItem?.title ?? 'Тест';
    final needsManualGrading = courseItem?.needEvaluation ?? false;

    return BlocProvider(
      create: (_) => TestMonitoringBloc(
        listAttempts: getIt(),
        classRepo: getIt(),
      )..add(LoadTestMonitoringEvent(
          sessionId: sessionId,
          classId: classId,
          title: title,
          needsManualGrading: needsManualGrading,
        )),
      child: _View(sessionId: sessionId, courseItem: courseItem),
    );
  }
}

