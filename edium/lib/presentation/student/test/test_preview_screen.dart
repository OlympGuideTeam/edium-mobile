import 'dart:async';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/test_session_meta.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/take_quiz_screen.dart';
import 'package:edium/presentation/student/test/bloc/test_preview_bloc.dart';
import 'package:edium/presentation/student/test/bloc/test_preview_event.dart';
import 'package:edium/presentation/student/test/bloc/test_preview_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TestPreviewScreen extends StatelessWidget {
  final String sessionId;
  final CourseItem? courseItem;
  final String? quizTitle;

  const TestPreviewScreen({
    super.key,
    required this.sessionId,
    this.courseItem,
    this.quizTitle,
  });

  TestSessionMeta _buildMeta() {
    final item = courseItem;
    final quizId = item?.quizTemplateId ?? item?.refId ?? sessionId;
    return TestSessionMeta(
      sessionId: sessionId,
      quizId: quizId,
      title: item?.title ?? quizTitle ?? 'Тест',
      description: null,
      questionCount: 0,
      needEvaluation: item?.needEvaluation ?? false,
      totalTimeLimitSec: item?.payload?.totalTimeLimitSec,
      shuffleQuestions: item?.payload?.shuffleQuestions,
      startedAt: item?.startTime,
      finishedAt: item?.endTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = _buildMeta();
    return BlocProvider(
      create: (_) => TestPreviewBloc(
        repo: getIt(),
        getReview: getIt(),
      )..add(LoadTestPreviewEvent(
          meta: meta,
          initialAttemptId: courseItem?.attemptId,
        )),
      child: _TestPreviewView(sessionId: sessionId),
    );
  }
}

class _TestPreviewView extends StatelessWidget {
  final String sessionId;
  const _TestPreviewView({required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _BackRow(onBack: () => context.pop()),
            Expanded(
              child: BlocBuilder<TestPreviewBloc, TestPreviewState>(
                builder: (context, state) {
                  if (state is TestPreviewLoading ||
                      state is TestPreviewInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mono700,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (state is TestPreviewError) {
                    return _ErrorBody(message: state.message);
                  }
                  if (state is TestPreviewLoaded) {
                    return _LoadedBody(
                      state: state,
                      sessionId: sessionId,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackRow extends StatelessWidget {
  final VoidCallback onBack;
  const _BackRow({required this.onBack});
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

class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          'Не удалось загрузить тест:\n$message',
          textAlign: TextAlign.center,
          style: AppTextStyles.screenSubtitle,
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final TestPreviewLoaded state;
  final String sessionId;
  const _LoadedBody({required this.state, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final meta = state.meta;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(meta.title, style: AppTextStyles.heading2),
                if (meta.description != null &&
                    meta.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(meta.description!,
                      style: AppTextStyles.screenSubtitle),
                ],
                const SizedBox(height: 24),
                _StatusHero(state: state),
                const SizedBox(height: 20),
                _DetailsSection(meta: meta, status: state.status),
                if (meta.hasTimeLimit &&
                    state.status == TestPreviewStatus.start) ...[
                  const SizedBox(height: 16),
                  _WarningBlock(
                    text:
                        'Таймер запустится сразу после нажатия «Начать». Он не остановится, если вы покинете экран.',
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPaddingH,
            0,
            AppDimens.screenPaddingH,
            24,
          ),
          child: _BottomCta(state: state, sessionId: sessionId),
        ),
      ],
    );
  }
}

// ─── Статусный hero-блок ────────────────────────────────────────────────────

class _StatusHero extends StatelessWidget {
  final TestPreviewLoaded state;
  const _StatusHero({required this.state});

  @override
  Widget build(BuildContext context) {
    final status = state.status;
    final meta = state.meta;

    if (status == TestPreviewStatus.locked && meta.startedAt != null) {
      return _ScheduledBanner(
        startTime: meta.startedAt!,
        durationSec: meta.totalTimeLimitSec,
      );
    }

    final (:tag, :title, :subtitle) = _heroContent(status, state);

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

  ({String tag, String title, String? subtitle}) _heroContent(
    TestPreviewStatus status,
    TestPreviewLoaded state,
  ) {
    return switch (status) {
      TestPreviewStatus.start => (
        tag: 'СТАТУС',
        title: 'Тест\nдоступен',
        subtitle: state.meta.hasTimeLimit
            ? '${state.meta.timeLimitMinutes} мин на выполнение'
            : null,
      ),
      TestPreviewStatus.resume => (
        tag: 'СТАТУС',
        title: 'Тест начат',
        subtitle: 'Продолжите выполнение',
      ),
      TestPreviewStatus.locked => (
        tag: 'СТАТУС',
        title: 'Откроется\nпозже',
        subtitle: null,
      ),
      TestPreviewStatus.expired => (
        tag: 'СТАТУС',
        title: 'Срок сдачи\nистёк',
        subtitle: null,
      ),
      TestPreviewStatus.grading => (
        tag: 'СТАТУС',
        title: 'Ответы\nпроверяются',
        subtitle: 'Вернитесь позже',
      ),
      TestPreviewStatus.graded => (
        tag: 'СТАТУС',
        title: 'Результаты\nбудут позже',
        subtitle: 'Ожидайте: учитель проверяет',
      ),
      TestPreviewStatus.published => (
        tag: 'РЕЗУЛЬТАТ',
        title: _completedTitle(state),
        subtitle: 'Посмотреть подробнее',
      ),
    };
  }

  String _completedTitle(TestPreviewLoaded state) {
    final score = state.review?.score;
    if (score != null) {
      return '${score.round()}%';
    }
    return 'Завершён';
  }
}

// ─── Секция деталей ─────────────────────────────────────────────────────────

class _DetailsSection extends StatelessWidget {
  final TestSessionMeta meta;
  final TestPreviewStatus status;
  const _DetailsSection({required this.meta, required this.status});

  static final _dateFmt = DateFormat('d MMM, HH:mm', 'ru');

  @override
  Widget build(BuildContext context) {
    final rows = <_DetailRow>[];

    rows.add(_DetailRow(
      icon: Icons.timer_outlined,
      label: 'Время',
      value: meta.hasTimeLimit
          ? '${meta.timeLimitMinutes} мин'
          : 'Без ограничений',
    ));

    if (meta.finishedAt != null) {
      rows.add(_DetailRow(
        icon: Icons.event_outlined,
        label: 'Дедлайн',
        value: _dateFmt.format(meta.finishedAt!.toLocal()),
      ));
    }

    if (meta.shuffleQuestions == true) {
      rows.add(_DetailRow(
        icon: Icons.shuffle_rounded,
        label: 'Порядок вопросов',
        value: 'Случайный',
      ));
    }

    final attemptUsed = status == TestPreviewStatus.resume ||
        status == TestPreviewStatus.published ||
        status == TestPreviewStatus.grading ||
        status == TestPreviewStatus.graded;

    rows.add(_DetailRow(
      icon: Icons.replay_outlined,
      label: 'Попытки',
      value: attemptUsed ? 'Закончились' : '1 доступна',
    ));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono150),
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

// ─── Баннер обратного отсчёта ───────────────────────────────────────────────

class _ScheduledBanner extends StatefulWidget {
  final DateTime startTime;
  final int? durationSec;

  const _ScheduledBanner({required this.startTime, this.durationSec});

  @override
  State<_ScheduledBanner> createState() => _ScheduledBannerState();
}

class _ScheduledBannerState extends State<_ScheduledBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    final remaining = widget.startTime.toLocal().difference(DateTime.now());
    if (remaining.isNegative) return;

    if (remaining.inSeconds < 60) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (!mounted) return;
        setState(() {});
        final r = widget.startTime.toLocal().difference(DateTime.now());
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
    final diff = widget.startTime.toLocal().difference(now);
    if (diff.isNegative) return const SizedBox.shrink();

    final isUnderMinute = diff.inSeconds < 60;
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    final start = widget.startTime.toLocal();
    const ruWeekdays = [
      '',
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    const ruMonths = [
      '',
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];

    final weekday = ruWeekdays[start.weekday];
    final dateStr = '${start.day} ${ruMonths[start.month]}';
    final timeStr =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

    final subParts = ['$weekday, $dateStr · $timeStr'];
    if (widget.durationSec != null && widget.durationSec! > 0) {
      final min = (widget.durationSec! / 60).round();
      subParts.add('длительность ≈ $min мин');
    }

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
          const Text(
            'СТАРТ ЧЕРЕЗ',
            style: TextStyle(
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
          const SizedBox(height: 10),
          Text(
            subParts.join(' · '),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0x80FFFFFF),
            ),
          ),
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

// ─── Warning ────────────────────────────────────────────────────────────────

class _WarningBlock extends StatelessWidget {
  final String text;
  const _WarningBlock({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              size: 16, color: AppColors.mono400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.mono400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CTA-кнопка ─────────────────────────────────────────────────────────────

class _BottomCta extends StatelessWidget {
  final TestPreviewLoaded state;
  final String sessionId;
  const _BottomCta({required this.state, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final status = state.status;
    final meta = state.meta;

    final label = switch (status) {
      TestPreviewStatus.start => 'Начать тест',
      TestPreviewStatus.resume => 'Продолжить',
      TestPreviewStatus.locked => 'Откроется позже',
      TestPreviewStatus.expired => 'Дедлайн истёк',
      TestPreviewStatus.grading => 'Ответы проверяются',
      TestPreviewStatus.graded => 'Результаты недоступны',
      TestPreviewStatus.published => 'Посмотреть результат',
    };

    final enabled = status == TestPreviewStatus.start ||
        status == TestPreviewStatus.resume ||
        status == TestPreviewStatus.published;

    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonH,
      child: ElevatedButton(
        onPressed: enabled ? () => _onTap(context, meta, status) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mono900,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.mono200,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          textStyle: AppTextStyles.primaryButton,
        ),
        child: Text(label),
      ),
    );
  }

  void _onTap(
    BuildContext context,
    TestSessionMeta meta,
    TestPreviewStatus status,
  ) {
    if (status == TestPreviewStatus.published) {
      final review = state.review;
      if (review != null) {
        context.push('/test/$sessionId/attempts/${review.attemptId}');
      }
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => TakeQuizBloc(
            createAttempt: getIt(),
            submitAnswer: getIt(),
            finishAttempt: getIt(),
            getResult: getIt(),
            testSessionRepo: getIt(),
          ),
          child: TakeQuizScreen(
            sessionId: sessionId,
            quizTitle: meta.title,
            totalTimeLimitSec: meta.totalTimeLimitSec,
            useCache: true,
          ),
        ),
      ),
    );
  }
}
