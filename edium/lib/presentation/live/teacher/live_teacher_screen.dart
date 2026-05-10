import 'dart:async';
import 'dart:math' as math;

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/live/teacher/bloc/live_teacher_bloc.dart';
import 'package:edium/presentation/live/teacher/bloc/live_teacher_event.dart';
import 'package:edium/presentation/live/teacher/bloc/live_teacher_state.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/presentation/shared/widgets/edium_confirm_dialog.dart';
import 'package:edium/services/live_ws/live_ws_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'live_teacher_screen_live_teacher_body.dart';
part 'live_teacher_screen_teacher_loading_phase.dart';
part 'live_teacher_screen_teacher_pending_phase.dart';
part 'live_teacher_screen_teacher_lobby_phase.dart';
part 'live_teacher_screen_lobby_joined_tile.dart';
part 'live_teacher_screen_lobby_empty_joined.dart';
part 'live_teacher_screen_lobby_not_joined_row.dart';
part 'live_teacher_screen_teacher_question_phase.dart';
part 'live_teacher_screen_teacher_locked_phase.dart';
part 'live_teacher_screen_monitor_header.dart';
part 'live_teacher_screen_timer_progress_segment.dart';
part 'live_teacher_screen_locked_snap_segment.dart';
part 'live_teacher_screen_live_dot.dart';
part 'live_teacher_screen_locked_badge.dart';
part 'live_teacher_screen_live_timer.dart';
part 'live_teacher_screen_question_card.dart';
part 'live_teacher_screen_question_distribution.dart';
part 'live_teacher_screen_choice_distribution.dart';
part 'live_teacher_screen_option_fill_cell.dart';
part 'live_teacher_screen_choice_indicator.dart';
part 'live_teacher_screen_given_answer_distribution.dart';
part 'live_teacher_screen_binary_distribution.dart';
part 'live_teacher_screen_binary_bar.dart';
part 'live_teacher_screen_live_stats_row.dart';
part 'live_teacher_screen_stats_cell.dart';
part 'live_teacher_screen_participant_progress.dart';
part 'live_teacher_screen_all_pending_answered_placeholder.dart';
part 'live_teacher_screen_section_label.dart';
part 'live_teacher_screen_pending_row.dart';
part 'live_teacher_screen_answered_row.dart';
part 'live_teacher_screen_no_answer_row.dart';
part 'live_teacher_screen_participant_row.dart';
part 'live_teacher_screen_gated_monitor_bottom_bar.dart';
part 'live_teacher_screen_monitor_bottom_bar.dart';
part 'live_teacher_screen_teacher_results_loading_phase.dart';
part 'live_teacher_screen_teacher_results_phase.dart';
part 'live_teacher_screen_leaderboard_tab.dart';
part 'live_teacher_screen_leaderboard_row.dart';
part 'live_teacher_screen_position_mark.dart';
part 'live_teacher_screen_questions_tab.dart';
part 'live_teacher_screen_teacher_error_phase.dart';



class LiveTeacherScreen extends StatelessWidget {
  final String sessionId;
  final String quizTitle;
  final int questionCount;
  final String? moduleId;

  const LiveTeacherScreen({
    super.key,
    required this.sessionId,
    required this.quizTitle,
    required this.questionCount,
    this.moduleId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LiveTeacherBloc(
        repo: getIt<ILiveRepository>(),
        ws: getIt<LiveWsService>(),
      )..add(LiveTeacherLoad(
          sessionId: sessionId,
          quizTitle: quizTitle,
          questionCount: questionCount,
          moduleId: moduleId,
        )),
      child: _LiveTeacherBody(
        quizTitle: quizTitle,
        questionCount: questionCount,
      ),
    );
  }
}

