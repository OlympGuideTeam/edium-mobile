import 'dart:async';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/presentation/shared/widgets/question_image_widget.dart';
import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/live/student/bloc/live_student_bloc.dart';
import 'package:edium/presentation/live/student/bloc/live_student_event.dart';
import 'package:edium/presentation/live/student/bloc/live_student_state.dart';
import 'package:edium/presentation/shared/mixins/screen_protection_mixin.dart';
import 'package:edium/presentation/shared/test/attempt_review_screen.dart';
import 'package:edium/services/live_ws/live_ws_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'live_student_screen_live_student_body.dart';
part 'live_student_screen_loading_phase.dart';
part 'live_student_screen_lobby_phase.dart';
part 'live_student_screen_lobby_section_label.dart';
part 'live_student_screen_lobby_participant_tile.dart';
part 'live_student_screen_lobby_empty_card.dart';
part 'live_student_screen_pulsing_wait_badge.dart';
part 'live_student_screen_question_phase.dart';
part 'live_student_screen_question_header.dart';
part 'live_student_screen_timer_badge.dart';
part 'live_student_screen_timer_progress_bar.dart';
part 'live_student_screen_answer_options.dart';
part 'live_student_screen_option_card.dart';
part 'live_student_screen_radio_dot.dart';
part 'live_student_screen_check_dot.dart';
part 'live_student_screen_option_text.dart';
part 'live_student_screen_confirm_button.dart';
part 'live_student_screen_answered_overlay.dart';
part 'live_student_screen_locked_option.dart';
part 'live_student_screen_waiting_banner.dart';
part 'live_student_screen_live_drag_question.dart';
part 'live_student_screen_live_connection_question.dart';
part 'live_student_screen_live_edge_dot.dart';
part 'live_student_screen_live_arrow_painter.dart';
part 'live_student_screen_locked_phase.dart';
part 'live_student_screen_given_answer_distribution.dart';
part 'live_student_screen_binary_bar.dart';
part 'live_student_screen_locked_choice_distribution.dart';
part 'live_student_screen_locked_option_fill_cell.dart';
part 'live_student_screen_locked_choice_indicator.dart';
part 'live_student_screen_locked_drag_result.dart';
part 'live_student_screen_locked_connection_result.dart';
part 'live_student_screen_correctness_badge.dart';
part 'live_student_screen_word_cloud_view.dart';
part 'live_student_screen_locked_connection_my_answer.dart';
part 'live_student_screen_locked_arrow_painter.dart';
part 'live_student_screen_answered_connection_display.dart';
part 'live_student_screen_neutral_arrow_painter.dart';
part 'live_student_screen_results_phase.dart';
part 'live_student_screen_result_position_circle.dart';
part 'live_student_screen_dark_stat_card.dart';
part 'live_student_screen_leaderboard_tab_content.dart';
part 'live_student_screen_leaderboard_row.dart';
part 'live_student_screen_kicked_phase.dart';
part 'live_student_screen_error_phase.dart';


class LiveStudentScreen extends StatefulWidget {
  final String sessionId;
  final String attemptId;
  final String wsToken;
  final String quizTitle;
  final int questionCount;
  final String? moduleId;

  const LiveStudentScreen({
    super.key,
    required this.sessionId,
    required this.attemptId,
    required this.wsToken,
    required this.quizTitle,
    required this.questionCount,
    this.moduleId,
  });

  @override
  State<LiveStudentScreen> createState() => _LiveStudentScreenState();
}

class _LiveStudentScreenState extends State<LiveStudentScreen>
    with WidgetsBindingObserver, ScreenProtectionMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LiveStudentBloc(
        repo: getIt<ILiveRepository>(),
        ws: getIt<LiveWsService>(),
      )..add(LiveStudentStart(
          sessionId: widget.sessionId,
          attemptId: widget.attemptId,
          wsToken: widget.wsToken,
          quizTitle: widget.quizTitle,
          questionCount: widget.questionCount,
          moduleId: widget.moduleId,
        )),
      child: _LiveStudentBody(quizTitle: widget.quizTitle, attemptId: widget.attemptId),
    );
  }
}

