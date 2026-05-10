import 'dart:io';
import 'dart:math' as math;

import 'package:excel/excel.dart' as xl;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:edium/domain/usecases/course/get_course_sheet_usecase.dart';
import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/domain/entities/session_status_item.dart';
import 'package:edium/domain/usecases/course/get_module_detail_usecase.dart';
import 'package:edium/domain/usecases/course/get_session_statuses_usecase.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:edium/presentation/shared/widgets/search_bar_widget.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_bloc.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_event.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_state.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/template_search_cubit.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/create_quiz_hydration.dart';
import 'package:edium/presentation/teacher/create_quiz/create_quiz_screen.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_state.dart';
import 'package:edium/domain/usecases/quiz/create_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/domain/usecases/quiz/get_quizzes_usecase.dart';
import 'package:edium/presentation/teacher/quiz_library/quiz_detail_screen.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/live/live_session_completed_navigation.dart';
import 'package:edium/services/network/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'course_detail_screen_course_detail_view.dart';
part 'course_detail_screen_course_detail_body.dart';
part 'course_detail_screen_action_sheet_item.dart';
part 'course_detail_screen_template_picker_content.dart';
part 'course_detail_screen_template_card.dart';
part 'course_detail_screen_course_content_list.dart';
part 'course_detail_screen_reorderable_module_item.dart';
part 'course_detail_screen_dismissible_draft_tile.dart';
part 'course_detail_screen_module_section.dart';
part 'course_detail_screen_quiz_item_tile.dart';
part 'course_detail_screen_meta_chip.dart';
part 'course_detail_screen_trailing_badge.dart';
part 'course_detail_screen_drafts_section_header.dart';
part 'course_detail_screen_dashed_divider.dart';
part 'course_detail_screen_dashed_line_painter.dart';
part 'course_detail_screen_draft_tile.dart';
part 'course_detail_screen_course_sheet_tab.dart';
part 'course_detail_screen_sheet_table.dart';
part 'course_detail_screen_app_bar.dart';



String studentTestActionLabel(CourseItem item) {
  return switch (item.state) {
    'in_progress' => 'Продолжить →',
    'waiting' => 'Ожидает',
    'running' => 'Идёт',
    'completed' => 'Завершён',
    _ => 'Начать →',
  };
}

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  final String? classId;

  const CourseDetailScreen({super.key, required this.courseId, this.classId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseDetailBloc(
        getCourseDetail: getIt(),
        createModule: getIt(),
        profileStorage: getIt(),
        courseRepository: getIt(),
        courseId: courseId,
      )..add(LoadCourseDetailEvent(courseId)),
      child: _CourseDetailView(classId: classId),
    );
  }
}

