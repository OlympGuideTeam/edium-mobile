import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/core/di/injection.dart';
import 'package:edium/domain/entities/library_quiz.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:edium/domain/usecases/library_quiz/get_attempt_result_usecase.dart';
import 'package:edium/domain/usecases/test_session/get_attempt_review_usecase.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:edium/presentation/shared/widgets/library_quiz_card.dart';
import 'package:edium/presentation/shared/widgets/search_bar_widget.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_state.dart';
import 'package:edium/presentation/student/quiz_library/quiz_preview_screen.dart';
import 'package:edium/presentation/student/quiz_library/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'student_quiz_library_screen_quiz_tab_bar.dart';
part 'student_quiz_library_screen_all_tab.dart';
part 'student_quiz_library_screen_all_tab_loaded.dart';
part 'student_quiz_library_screen_passed_tab.dart';
part 'student_quiz_library_screen_passed_tab_loaded.dart';
part 'student_quiz_library_screen_passed_quiz_result_loader_screen.dart';
part 'student_quiz_library_screen_error_body.dart';
part 'student_quiz_library_screen_empty_placeholder.dart';


class StudentQuizLibraryScreen extends StatelessWidget {
  const StudentQuizLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.mono900,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusXs),
                        ),
                        child: const Text('УЧЕНИК',
                            style: AppTextStyles.badgeText),
                      ),
                      const SizedBox(height: 12),
                      const Text('Квизы', style: AppTextStyles.screenTitle),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SearchBarWidget(
                    hint: 'Найти квиз...',
                    onChanged: (q) => context
                        .read<StudentQuizBloc>()
                        .add(StudentSearchChangedEvent(q)),
                  ),
                ),
                const SizedBox(height: 8),
                const _QuizTabBar(),

                const Expanded(
                  child: TabBarView(
                    children: [
                      _AllTab(),
                      _PassedTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

