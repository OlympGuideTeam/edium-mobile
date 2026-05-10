import 'dart:async';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:edium/domain/usecases/library_quiz/get_attempt_result_usecase.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:edium/presentation/student/quiz_library/student_question_review_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

part 'quiz_result_screen_top_bar.dart';
part 'quiz_result_screen_grade_badge.dart';
part 'quiz_result_screen_pending_body.dart';
part 'quiz_result_screen_result_body.dart';
part 'quiz_result_screen_big_score.dart';
part 'quiz_result_screen_progress_bar.dart';
part 'quiz_result_screen_stat_card.dart';
part 'quiz_result_screen_pending_notice.dart';
part 'quiz_result_screen_answer_breakdown.dart';
part 'quiz_result_screen_answer_row.dart';
part 'quiz_result_screen_status_dot.dart';
part 'quiz_result_screen_bottom_cta.dart';


class QuizResultScreen extends StatefulWidget {
  final AttemptResult result;
  final int maxPossibleScore;
  final String quizTitle;
  final List<QuizQuestionForStudent> questions;
  final String? courseId;
  final bool showBottomCta;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.maxPossibleScore,
    required this.quizTitle,
    required this.questions,
    this.courseId,
    this.showBottomCta = true,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late AttemptResult _current;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _current = widget.result;
    _maybeStartPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  bool get _isPending =>
      _current.status == AttemptStatus.grading ||
      _current.status == AttemptStatus.graded ||
      _current.status == AttemptStatus.completed;

  void _maybeStartPolling() {
    if (!_isPending) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _refresh());
  }

  void _exit(BuildContext context) {
    final cid = widget.courseId;
    if (cid != null) {
      context.go('/course/$cid');
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _refresh() async {
    try {
      final fresh = await getIt<GetAttemptResultUsecase>()(_current.attemptId);
      if (!mounted) return;
      setState(() => _current = fresh);
      if (!_isPending) _pollTimer?.cancel();
    } catch (_) {

    }
  }

  @override
  Widget build(BuildContext context) {
    final grade = _current.score;
    final showGrade = !_isPending && grade != null;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              onBack: () => _exit(context),
              trailing: showGrade ? _GradeBadge(grade: grade) : null,
            ),
            Expanded(
              child: _isPending
                  ? const _PendingBody()
                  : EdiumRefreshIndicator(
                      onRefresh: _refresh,
                      child: _ResultBody(
                        result: _current,
                        maxPossibleScore: widget.maxPossibleScore,
                        quizTitle: widget.quizTitle,
                        questions: widget.questions,
                      ),
                    ),
            ),
            if (widget.showBottomCta)
              _BottomCta(onPressed: () => _exit(context)),
          ],
        ),
      ),
    );
  }
}

