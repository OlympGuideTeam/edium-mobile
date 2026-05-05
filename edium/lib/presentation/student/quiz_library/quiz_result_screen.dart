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
import 'package:intl/intl.dart';

class QuizResultScreen extends StatefulWidget {
  final AttemptResult result;
  final int maxPossibleScore;
  final String quizTitle;
  final List<QuizQuestionForStudent> questions;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.maxPossibleScore,
    required this.quizTitle,
    required this.questions,
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
      _current.status == AttemptStatus.graded;

  void _maybeStartPolling() {
    if (!_isPending) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _refresh());
  }

  Future<void> _refresh() async {
    try {
      final fresh = await getIt<GetAttemptResultUsecase>()(_current.attemptId);
      if (!mounted) return;
      setState(() => _current = fresh);
      if (!_isPending) _pollTimer?.cancel();
    } catch (_) {
      // best-effort
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
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
            _BottomCta(onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: AppColors.mono900),
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          const Text('Результаты', style: AppTextStyles.screenTitle),
        ],
      ),
    );
  }
}

// ── Pending body (grading/graded) ──────────────────────────────────────────

class _PendingBody extends StatelessWidget {
  const _PendingBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.mono50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.mono150),
              ),
              child: const Icon(Icons.auto_awesome_outlined,
                  size: 28, color: AppColors.mono600),
            ),
            const SizedBox(height: 18),
            const Text('Ответы проверяются', style: AppTextStyles.screenTitle),
            const SizedBox(height: 8),
            Text(
              'Часть ответов проверяется ИИ или учителем. Экран обновится автоматически.',
              style: AppTextStyles.screenSubtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result body ────────────────────────────────────────────────────────────

class _ResultBody extends StatelessWidget {
  final AttemptResult result;
  final int maxPossibleScore;
  final String quizTitle;
  final List<QuizQuestionForStudent> questions;

  const _ResultBody({
    required this.result,
    required this.maxPossibleScore,
    required this.quizTitle,
    required this.questions,
  });

  // Функциональные акценты — как в AttemptReviewScreen/TakeQuiz.
  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);
  static const _amber = Color(0xFFD97706);
  static const _amberBg = Color(0xFFFEF3C7);

  double get _progress {
    if (maxPossibleScore <= 0) return 0;
    return ((result.score ?? 0) / maxPossibleScore).clamp(0.0, 1.0);
  }

  int get _pct => (_progress * 100).round();

  int get _totalQuestions => questions.length;

  /// Словарь questionId → maxScore.
  Map<String, int> get _maxByQuestion =>
      {for (final q in questions) q.id: q.maxScore};

  Iterable<_AnswerBreakdown> get _breakdown {
    return result.answers.map((a) {
      final max = _maxByQuestion[a.questionId] ?? 0;
      final score = a.finalScore;
      final status = () {
        if (score == null) return _AnswerStatus.pending;
        if (max == 0 || score >= max) return _AnswerStatus.correct;
        if (score <= 0) return _AnswerStatus.wrong;
        return _AnswerStatus.partial;
      }();
      return _AnswerBreakdown(
        answer: a,
        maxScore: max,
        status: status,
      );
    });
  }

  int get _correctCount =>
      _breakdown.where((b) => b.status == _AnswerStatus.correct).length;
  int get _partialCount =>
      _breakdown.where((b) => b.status == _AnswerStatus.partial).length;
  int get _wrongCount =>
      _breakdown.where((b) => b.status == _AnswerStatus.wrong).length;

  String get _durationString {
    final start = result.startedAt;
    final end = result.finishedAt;
    if (end == null) return '—';
    final d = end.difference(start);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d MMM, HH:mm', 'ru');
    final finishedAt = result.finishedAt;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPaddingH, 4, AppDimens.screenPaddingH, 24),
      children: [
        // Row: ТЕСТ badge + date
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.mono100,
                borderRadius: BorderRadius.circular(AppDimens.radiusXs),
              ),
              child: const Text(
                'ТЕСТ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (finishedAt != null) ...[
              const SizedBox(width: 8),
              Text(
                'Сдан ${dateFmt.format(finishedAt.toLocal())}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.mono400,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // Quiz title
        Text(
          quizTitle,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.mono600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),
        // Big score + pct
        _BigScore(
          score: (result.score ?? 0),
          max: maxPossibleScore.toDouble(),
          pct: _pct,
        ),
        const SizedBox(height: 18),
        // Progress bar
        _ProgressBar(progress: _progress),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('0', style: TextStyle(fontSize: 11, color: AppColors.mono300)),
            Text('100',
                style: TextStyle(fontSize: 11, color: AppColors.mono300)),
          ],
        ),
        const SizedBox(height: 20),
        // 3 stat cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatCard(
                label: 'ПРАВИЛЬНО',
                value: '$_correctCount / ${_correctCount + _wrongCount}',
                valueColor: _green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'ЧАСТИЧНО',
                value: '$_partialCount',
                valueColor: _amber,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'ВРЕМЯ',
                value: _durationString,
                valueColor: AppColors.mono900,
              ),
            ),
          ],
        ),
        if (result.hasPendingEvaluation) ...[
          const SizedBox(height: 16),
          _PendingNotice(),
        ],
        const SizedBox(height: 24),
        // Section label
        const Text('РАЗБОР ВОПРОСОВ', style: AppTextStyles.sectionTag),
        const SizedBox(height: 10),
        // Answer tiles
        ..._breakdown.toList().asMap().entries.map((entry) {
          final q = questions[entry.key];
          return _AnswerRow(
            index: entry.key + 1,
            breakdown: entry.value,
            total: _totalQuestions,
            question: q,
          );
        }),
      ],
    );
  }
}

// ── Big score ────────────────────────────────────────────────────────────

class _BigScore extends StatelessWidget {
  final double score;
  final double max;
  final int pct;
  const _BigScore({
    required this.score,
    required this.max,
    required this.pct,
  });

  String _fmt(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _fmt(score),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            color: AppColors.mono900,
            height: 1.0,
            letterSpacing: -2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '/${_fmt(max)}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.mono250,
              height: 1.0,
              letterSpacing: -1.5,
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            '$pct%',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.mono700,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Progress bar ─────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 6,
        color: AppColors.mono100,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(color: AppColors.mono900),
        ),
      ),
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.mono400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pending notice ───────────────────────────────────────────────────────

class _PendingNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.hourglass_top_outlined,
              size: 16, color: AppColors.mono400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Часть ответов ещё проверяется — итоговый балл может измениться.',
              style: AppTextStyles.helperText,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Answer row ───────────────────────────────────────────────────────────

enum _AnswerStatus { correct, partial, wrong, pending }

class _AnswerBreakdown {
  final AnswerSubmissionResult answer;
  final int maxScore;
  final _AnswerStatus status;
  const _AnswerBreakdown({
    required this.answer,
    required this.maxScore,
    required this.status,
  });
}

class _AnswerRow extends StatelessWidget {
  final int index;
  final _AnswerBreakdown breakdown;
  final int total;
  final QuizQuestionForStudent question;

  const _AnswerRow({
    required this.index,
    required this.breakdown,
    required this.total,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final score = breakdown.answer.finalScore;
    final max = breakdown.maxScore;
    final scoreText = score == null
        ? '—'
        : '${score.toStringAsFixed(score % 1 == 0 ? 0 : 1)}/$max';

    return GestureDetector(
      onTap: () => showStudentQuestionReview(
        context,
        data: StudentQuestionReviewData(
          index: index,
          total: total,
          question: question,
          answer: breakdown.answer,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.mono150),
        ),
        child: Row(
          children: [
            _StatusDot(status: breakdown.status),
            const SizedBox(width: 12),
            SizedBox(
              width: 18,
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono400,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                breakdown.answer.finalFeedback != null &&
                        breakdown.answer.finalFeedback!.isNotEmpty
                    ? breakdown.answer.finalFeedback!
                    : 'Вопрос $index',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mono900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              scoreText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _colorForStatus(breakdown.status),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.mono300),
          ],
        ),
      ),
    );
  }

  Color _colorForStatus(_AnswerStatus s) {
    switch (s) {
      case _AnswerStatus.correct:
        return _ResultBody._green;
      case _AnswerStatus.partial:
        return _ResultBody._amber;
      case _AnswerStatus.wrong:
        return _ResultBody._red;
      case _AnswerStatus.pending:
        return AppColors.mono400;
    }
  }
}

class _StatusDot extends StatelessWidget {
  final _AnswerStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final IconData icon;
    switch (status) {
      case _AnswerStatus.correct:
        bg = _ResultBody._greenBg;
        fg = _ResultBody._green;
        icon = Icons.check;
        break;
      case _AnswerStatus.wrong:
        bg = _ResultBody._redBg;
        fg = _ResultBody._red;
        icon = Icons.close;
        break;
      case _AnswerStatus.partial:
        bg = _ResultBody._amberBg;
        fg = _ResultBody._amber;
        icon = Icons.remove;
        break;
      case _AnswerStatus.pending:
        bg = AppColors.mono50;
        fg = AppColors.mono400;
        icon = Icons.hourglass_bottom;
        break;
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: fg),
    );
  }
}

// ── Bottom CTA ───────────────────────────────────────────────────────────

class _BottomCta extends StatelessWidget {
  final VoidCallback onPressed;
  const _BottomCta({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.screenPaddingH,
        8,
        AppDimens.screenPaddingH,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: EdiumButton(
        label: 'К курсу',
        onPressed: onPressed,
      ),
    );
  }
}
