import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/attempt_summary.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:edium/domain/usecases/test_session/list_session_attempts_usecase.dart';
import 'package:edium/domain/usecases/test_session/publish_session_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'review_session_screen_loading.dart';
part 'review_session_screen_loaded.dart';
part 'review_session_screen_published.dart';
part 'review_session_screen_error.dart';
part 'review_session_screen_cubit.dart';
part 'review_session_screen_review_session_screen.dart';
part 'review_session_screen_view.dart';
part 'review_session_screen_view_body.dart';
part 'review_session_screen_top_bar.dart';
part 'review_session_screen_error_body.dart';
part 'review_session_screen_loaded_body.dart';
part 'review_session_screen_summary_strip.dart';
part 'review_session_screen_cell.dart';
part 'review_session_screen_divider.dart';
part 'review_session_screen_attempt_tile.dart';



sealed class _State extends Equatable {
  const _State();
  @override
  List<Object?> get props => [];
}

