import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/presentation/live/teacher/live_teacher_screen.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:edium/presentation/shared/widgets/quiz_card.dart';
import 'package:edium/presentation/shared/widgets/search_bar_widget.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/create_quiz_screen.dart';
import 'package:edium/presentation/teacher/edit_quiz_template/edit_quiz_template_screen.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/live_library_cubit.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_bloc.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_event.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_state.dart';
import 'package:edium/presentation/teacher/quiz_library/quiz_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'quiz_library_screen_quiz_library_scaffold.dart';
part 'quiz_library_screen_all_quizzes_tab.dart';
part 'quiz_library_screen_my_quizzes_tab.dart';
part 'quiz_library_screen_live_tab.dart';
part 'quiz_library_screen_live_sessions_content.dart';
part 'quiz_library_screen_live_session_card.dart';
part 'quiz_library_screen_phase_badge.dart';



class QuizLibraryScreen extends StatelessWidget {
  const QuizLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: _QuizLibraryScaffold(),
    );
  }
}

