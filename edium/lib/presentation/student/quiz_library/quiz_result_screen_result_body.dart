part of 'quiz_result_screen.dart';

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


  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);
  static const _amber = Color(0xFFD97706);
  static const _amberBg = Color(0xFFFEF3C7);


  double get _earnedScore => result.answers
      .fold<double>(0, (sum, a) => sum + (a.finalScore ?? 0));

  double get _progress {
    if (maxPossibleScore <= 0) return 0;
    return (_earnedScore / maxPossibleScore).clamp(0.0, 1.0);
  }

  int get _pct => (_progress * 100).round();

  int get _totalQuestions => questions.length;


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

        Text(
          quizTitle,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.mono600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),

        _BigScore(
          score: _earnedScore,
          max: maxPossibleScore.toDouble(),
          pct: _pct,
        ),
        const SizedBox(height: 18),

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

        const Text('РАЗБОР ВОПРОСОВ', style: AppTextStyles.sectionTag),
        const SizedBox(height: 10),

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

