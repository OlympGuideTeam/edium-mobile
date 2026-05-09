import 'dart:async';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/quiz_attempt.dart'
    show AttemptStatus, QuizQuestionForStudent, AnswerSubmissionResult, AttemptResult;
import 'package:edium/domain/usecases/test_session/get_attempt_review_usecase.dart';
import 'package:edium/presentation/student/quiz_library/quiz_result_screen.dart';
import 'package:edium/presentation/teacher/test_session/bloc/test_session_results_bloc.dart';
import 'package:edium/presentation/teacher/test_session/bloc/test_session_results_event.dart';
import 'package:edium/presentation/teacher/test_session/bloc/test_session_results_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TestSessionResultsScreen extends StatelessWidget {
  final String sessionId;
  final CourseItem? courseItem;
  final bool isTeacher;
  final String? moduleId;

  const TestSessionResultsScreen({
    super.key,
    required this.sessionId,
    this.courseItem,
    this.isTeacher = false,
    this.moduleId,
  });

  @override
  Widget build(BuildContext context) {
    // Студент с уже существующей попыткой → показываем результат
    if (!isTeacher) {
      final attemptId = courseItem?.attemptId;
      if (attemptId != null) {
        return _StudentResultScreen(
          attemptId: attemptId,
          quizTitle: courseItem?.title ?? 'Тест',
        );
      }
      // Сюда попадаем только при некорректном deep link без attemptId.
      // Бэкенд должен слать /test/{sessionId}/attempts/{attemptId} для студента.
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onBack: () => context.pop()),
              Expanded(
                child: Center(
                  child: Text('Нет доступа', style: AppTextStyles.screenSubtitle),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final title = courseItem?.title ?? 'Тест';
    return BlocProvider(
      create: (_) => TestSessionResultsBloc(
        listAttempts: getIt(),
        liveRepo: getIt(),
        courseRepo: getIt(),
        testSessionRepo: getIt(),
      )..add(LoadSessionResultsEvent(
          sessionId: sessionId,
          title: title,
          moduleId: moduleId,
          courseItemId: courseItem?.id,
          startedAt: courseItem?.startTime ?? courseItem?.payload?.startedAt,
          finishedAt: courseItem?.endTime ?? courseItem?.payload?.finishedAt,
        )),
      child: _View(sessionId: sessionId, courseItem: courseItem),
    );
  }
}

// ─── Экран результата для студента ───────────────────────────────────────────

class _StudentResultScreen extends StatefulWidget {
  final String attemptId;
  final String quizTitle;

  const _StudentResultScreen({
    required this.attemptId,
    required this.quizTitle,
  });

  @override
  State<_StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<_StudentResultScreen> {
  late Future<AttemptReview> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<GetAttemptReviewUsecase>()(widget.attemptId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<AttemptReview>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.mono700, strokeWidth: 2),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    snap.error.toString(),
                    style: AppTextStyles.screenSubtitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final review = snap.data!;
            return _buildResultFromReview(context, review);
          },
        ),
      ),
    );
  }

  Widget _buildResultFromReview(BuildContext context, AttemptReview review) {
    // Конвертируем AttemptReview → AttemptResult + QuizQuestionForStudent
    const defaultMaxScore = 10;

    final questions = review.answers
        .map((a) => QuizQuestionForStudent(
              id: a.questionId,
              type: a.questionType,
              text: a.questionText,
              maxScore: defaultMaxScore,
            ))
        .toList();

    final answers = review.answers
        .map((a) => AnswerSubmissionResult(
              questionId: a.questionId,
              answerData: a.answerData,
              finalScore: a.finalScore,
              finalFeedback: a.finalFeedback,
            ))
        .toList();

    final result = AttemptResult(
      attemptId: review.attemptId,
      status: review.status,
      score: review.score,
      startedAt: review.startedAt,
      finishedAt: review.finishedAt,
      answers: answers,
    );

    final maxPossibleScore = questions.length * defaultMaxScore;

    return QuizResultScreen(
      result: result,
      maxPossibleScore: maxPossibleScore,
      quizTitle: widget.quizTitle,
      questions: questions,
      showBottomCta: false,
    );
  }
}

// ─── Основной вид ────────────────────────────────────────────────────────────

class _View extends StatelessWidget {
  final String sessionId;
  final CourseItem? courseItem;
  const _View({required this.sessionId, this.courseItem});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TestSessionResultsBloc, TestSessionResultsState>(
      listener: (ctx, state) {
        if (state is TestSessionResultsDeleted) {
          Navigator.of(ctx).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(onBack: () => context.pop()),
                Expanded(child: _body(context, state, courseItem)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(
      BuildContext context, TestSessionResultsState state, CourseItem? courseItem) {
    if (state is TestSessionResultsLoading ||
        state is TestSessionResultsInitial) {
      return const Center(
        child: CircularProgressIndicator(
            color: AppColors.mono700, strokeWidth: 2),
      );
    }
    if (state is TestSessionResultsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(state.message,
              style: AppTextStyles.screenSubtitle,
              textAlign: TextAlign.center),
        ),
      );
    }
    if (state is TestSessionResultsLoaded) {
      return RefreshIndicator(
        color: AppColors.mono700,
        onRefresh: () async {
          context
              .read<TestSessionResultsBloc>()
              .add(const RefreshSessionResultsEvent());
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPaddingH, 0, AppDimens.screenPaddingH, 32),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 4),
            Text(state.title, style: AppTextStyles.heading2),
            const SizedBox(height: 20),
            _StatusHero(state: state),
            const SizedBox(height: 20),
            _DetailsSection(state: state),
            const SizedBox(height: 24),
            _SectionHeader(
              label: 'Участники',
              count: state.totalCount,
            ),
            const SizedBox(height: 10),
            if (state.rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    state.sessionStatus == 'not_started'
                        ? 'Тест ещё не открыт для прохождения'
                        : 'Пока никто не начинал тест',
                    style: AppTextStyles.screenSubtitle,
                  ),
                ),
              )
            else
              ...state.rows.map((r) => _StudentRowTile(
                    row: r,
                    onTap: r.attempt != null
                        ? () async {
                            final status = r.attempt!.status;
                            if (status == AttemptStatus.graded ||
                                status == AttemptStatus.grading) {
                              await context.push(
                                '/test/${state.sessionId}/attempts/${r.attempt!.attemptId}/grade',
                              );
                              if (context.mounted) {
                                context.read<TestSessionResultsBloc>().add(
                                    const RefreshSessionResultsEvent());
                              }
                            } else {
                              context.push(
                                '/test/${state.sessionId}/attempts/${r.attempt!.attemptId}',
                              );
                            }
                          }
                        : null,
                  )),
            const SizedBox(height: 20),
            _ActionButtons(state: state),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// ─── Шапка ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: AppColors.mono900),
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}

// ─── Статусный hero-блок ────────────────────────────────────────────────────

class _StatusHero extends StatelessWidget {
  final TestSessionResultsLoaded state;

  const _StatusHero({required this.state});

  @override
  Widget build(BuildContext context) {
    final status = state.sessionStatus;
    final startedAt = state.startedAt;
    final finishedAt = state.finishedAt;
    final now = DateTime.now();

    // Ещё не начат: таймер до старта
    if ((status == null || status == 'not_started' || status == 'waiting') &&
        startedAt != null &&
        startedAt.isAfter(now)) {
      return _CountdownBanner(
        label: 'СТАРТ ЧЕРЕЗ',
        target: startedAt,
      );
    }

    // Активен: таймер до дедлайна (если есть)
    if (status == 'active' &&
        finishedAt != null &&
        finishedAt.isAfter(now)) {
      return _CountdownBanner(
        label: 'ОСТАЛОСЬ',
        target: finishedAt,
        subtitle: _deadlineSubtitle(finishedAt),
      );
    }

    // Завершён или активен без дедлайна: показываем прогресс/результат
    final (:tag, :title, :subtitle) = _heroContent();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0x80FFFFFF),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0x80FFFFFF),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _deadlineSubtitle(DateTime finishedAt) {
    final fmt = DateFormat('d MMM, HH:mm', 'ru');
    return 'Дедлайн: ${fmt.format(finishedAt.toLocal())}';
  }

  ({String tag, String title, String? subtitle}) _heroContent() {
    final total = state.totalCount;
    final avg = state.averageScorePct;
    final sessionStatus = state.sessionStatus;

    if (sessionStatus == 'finished') {
      if (avg != null && total > 0) {
        return (
          tag: 'СРЕДНИЙ БАЛЛ',
          title: avg.toStringAsFixed(0),
          subtitle: 'из 10 · ${_pluralStudents(total)}',
        );
      }
      return (
        tag: 'СТАТУС',
        title: 'Завершён',
        subtitle: total > 0 ? '${_pluralStudents(total)} прошли' : 'Никто не прошёл',
      );
    }

    final nobodyStarted = state.rows.every((r) => r.attempt == null);
    final finishedCount = state.rows.where((r) {
      final s = r.attempt?.status;
      return s == AttemptStatus.grading ||
          s == AttemptStatus.graded ||
          s == AttemptStatus.completed ||
          s == AttemptStatus.published;
    }).length;

    if (nobodyStarted) {
      return (
        tag: 'СТАТУС',
        title: 'Тест\nдоступен',
        subtitle: 'Ожидание участников',
      );
    }

    if (finishedCount == total && total > 0 && avg != null) {
      return (
        tag: 'СРЕДНИЙ БАЛЛ',
        title: avg.toStringAsFixed(0),
        subtitle: 'из 10 · ${_pluralStudents(total)}',
      );
    }

    if (finishedCount == total && total > 0) {
      return (
        tag: 'СТАТУС',
        title: 'Идёт\nпроверка',
        subtitle: 'Все участники завершили тест',
      );
    }

    return (
      tag: 'ПРОГРЕСС',
      title: '$finishedCount / $total',
      subtitle: 'завершили тест',
    );
  }

  String _pluralStudents(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return '$n участник';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return '$n участника';
    }
    return '$n участников';
  }

}

// ─── Таймер обратного отсчёта ─────────────────────────────────────────────────

class _CountdownBanner extends StatefulWidget {
  final String label;
  final DateTime target;
  final String? subtitle;

  const _CountdownBanner({
    required this.label,
    required this.target,
    this.subtitle,
  });

  @override
  State<_CountdownBanner> createState() => _CountdownBannerState();
}

class _CountdownBannerState extends State<_CountdownBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    final remaining = widget.target.toLocal().difference(DateTime.now());
    if (remaining.isNegative) return;

    if (remaining.inSeconds < 60) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (!mounted) return;
        setState(() {});
        final r = widget.target.toLocal().difference(DateTime.now());
        if (r.inSeconds < 60) _startTimer();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = widget.target.toLocal().difference(now);
    if (diff.isNegative) return const SizedBox.shrink();

    final isUnderMinute = diff.inSeconds < 60;
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0x80FFFFFF),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (isUnderMinute) ...[
                _CountUnit(
                  value: seconds.toString().padLeft(2, '0'),
                  unit: 'сек',
                ),
              ] else ...[
                if (days > 0) ...[
                  _CountUnit(
                    value: days.toString().padLeft(2, '0'),
                    unit: 'дн',
                  ),
                  const SizedBox(width: 14),
                ],
                _CountUnit(
                  value: hours.toString().padLeft(2, '0'),
                  unit: 'ч',
                ),
                const SizedBox(width: 14),
                _CountUnit(
                  value: minutes.toString().padLeft(2, '0'),
                  unit: 'мин',
                ),
              ],
            ],
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              widget.subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0x80FFFFFF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CountUnit extends StatelessWidget {
  final String value;
  final String unit;

  const _CountUnit({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─── Секция деталей ─────────────────────────────────────────────────────────

class _DetailsSection extends StatelessWidget {
  final TestSessionResultsLoaded state;
  const _DetailsSection({required this.state});

  static final _dateFmt = DateFormat('d MMM, HH:mm', 'ru');

  @override
  Widget build(BuildContext context) {
    final rows = <_DetailRow>[];

    if (state.finishedAt != null) {
      rows.add(_DetailRow(
        icon: Icons.event_outlined,
        label: 'Дедлайн',
        value: _dateFmt.format(state.finishedAt!.toLocal()),
      ));
    }

    if (state.startedAt != null) {
      rows.add(_DetailRow(
        icon: Icons.schedule_outlined,
        label: 'Открывается',
        value: _dateFmt.format(state.startedAt!.toLocal()),
      ));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border:
            Border.all(color: AppColors.mono150, width: AppDimens.borderWidth),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.mono150,
                indent: 14,
                endIndent: 14,
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.mono400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.mono400,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.mono700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Заголовок секции ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.mono400,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.mono100,
            borderRadius: BorderRadius.circular(AppDimens.radiusXs),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.mono400,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Строка студента ─────────────────────────────────────────────────────────

class _StudentRowTile extends StatelessWidget {
  final StudentRow row;
  final VoidCallback? onTap;
  const _StudentRowTile({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final attempt = row.attempt;
    final status = attempt?.status;
    final score = attempt?.score;
    final isPublished = status == AttemptStatus.published;
    final tappable = onTap != null;
    final needsAction = status == AttemptStatus.graded;
    final isInactive = status == null;

    // Для published оценка показывается внутри _StatusBadge (grade chip),
    // для остальных статусов — отдельным числом справа.
    final scoreText = (!isPublished && score != null)
        ? score.toStringAsFixed(0)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: needsAction ? AppColors.mono25 : Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: needsAction ? AppColors.mono300 : AppColors.mono150,
              width: AppDimens.borderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusBadge(status: status, score: score),
                  const Spacer(),
                  if (scoreText != null) ...[
                    Text(
                      scoreText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mono900,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  if (tappable)
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: needsAction ? AppColors.mono400 : AppColors.mono300,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                row.displayName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isInactive ? AppColors.mono400 : AppColors.mono900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Бейдж статуса ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final AttemptStatus? status;
  final double? score;
  const _StatusBadge({required this.status, this.score});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case null:
        return _chip('Не начал', AppColors.mono350, Colors.transparent, AppColors.mono150);
      case AttemptStatus.inProgress:
        return _chip('Проходит', AppColors.mono400, AppColors.mono50, AppColors.mono150);
      case AttemptStatus.grading:
        return _chip('Не оценено', AppColors.mono400, AppColors.mono50, AppColors.mono150);
      case AttemptStatus.graded:
        return _chip('Оценено ИИ', Colors.white, AppColors.mono900, AppColors.mono900);
      case AttemptStatus.completed:
        return _chip('Оценено Вами', AppColors.mono600, AppColors.mono50, AppColors.mono150);
      case AttemptStatus.published:
        return _GradeChip(score: score);
    }
  }

  Widget _chip(String label, Color textColor, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
        border: Border.all(color: borderColor, width: AppDimens.borderWidth),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: textColor,
        ),
      ),
    );
  }
}

// ─── Бейдж оценки (published) ─────────────────────────────────────────────────

class _GradeChip extends StatelessWidget {
  final double? score;
  const _GradeChip({this.score});

  String _fmt(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'ОЦЕНКА',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.mono300,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: score != null ? _fmt(score!) : '—',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: 0.5,
                  ),
                ),
                if (score != null)
                  const TextSpan(
                    text: ' / 10',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mono300,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Кнопки действий ─────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final TestSessionResultsLoaded state;
  const _ActionButtons({required this.state});

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    // Завершить тест (только если сессия активна)
    if (state.sessionStatus == 'active') {
      buttons.add(_FinishButton(isFinishing: state.isFinishing));
      buttons.add(const SizedBox(height: 10));
    }

    // Опубликовать результаты
    if (state.canPublish) {
      buttons.add(_PublishButton(isPublishing: state.isPublishing));
      buttons.add(const SizedBox(height: 10));
    }

    // Удалить тест
    if (state.canDelete) {
      buttons.add(_DeleteButton(isDeleting: state.isDeleting));
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons,
    );
  }
}

class _FinishButton extends StatelessWidget {
  final bool isFinishing;
  const _FinishButton({required this.isFinishing});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonH,
      child: ElevatedButton(
        onPressed: isFinishing
            ? null
            : () async {
                final confirmed = await _confirm(context);
                if (!context.mounted || !confirmed) return;
                context
                    .read<TestSessionResultsBloc>()
                    .add(const FinishSessionEvent());
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mono900,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          textStyle: AppTextStyles.primaryButton,
        ),
        child: isFinishing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text('Завершить тест'),
      ),
    );
  }

  Future<bool> _confirm(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Завершить тест?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Студенты, не успевшие ответить, завершат попытку принудительно.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mono600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHSm,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mono900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Завершить',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHSm,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.mono150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                  ),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mono700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return res ?? false;
  }
}

class _PublishButton extends StatelessWidget {
  final bool isPublishing;
  const _PublishButton({required this.isPublishing});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonH,
      child: ElevatedButton(
        onPressed: isPublishing
            ? null
            : () {
                context
                    .read<TestSessionResultsBloc>()
                    .add(const PublishSessionEvent());
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mono900,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          textStyle: AppTextStyles.primaryButton,
        ),
        child: isPublishing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text('Опубликовать результаты'),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final bool isDeleting;
  const _DeleteButton({required this.isDeleting});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonH,
      child: OutlinedButton(
        onPressed: isDeleting
            ? null
            : () async {
                final confirmed = await _confirm(context);
                if (!context.mounted || !confirmed) return;
                context
                    .read<TestSessionResultsBloc>()
                    .add(const DeleteSessionEvent());
              },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mono700,
          side: const BorderSide(color: AppColors.mono150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          textStyle: AppTextStyles.secondaryButton,
        ),
        child: isDeleting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.mono700),
              )
            : const Text('Удалить тест'),
      ),
    );
  }

  Future<bool> _confirm(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Удалить тест?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Никто ещё не начал этот тест. Действие нельзя отменить.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mono600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHSm,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mono900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Удалить',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHSm,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.mono150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                  ),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mono700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return res ?? false;
  }
}
