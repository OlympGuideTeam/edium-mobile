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

  const TestPreviewScreen({
    super.key,
    required this.sessionId,
    this.courseItem,
  });

  TestSessionMeta _buildMeta() {
    final item = courseItem;
    return TestSessionMeta(
      sessionId: sessionId,
      quizId: item?.refId ?? sessionId,
      title: item?.title ?? 'Тест',
      description: null,
      questionCount: 0, // Caesar QuizShort не отдаёт — пока 0, показываем "—".
      needEvaluation: false, // TODO: расширение Caesar / Riddler нужно
      totalTimeLimitSec: null, // см. выше
      shuffleQuestions: null,
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

  static final _dateFmt = DateFormat('d MMM, HH:mm', 'ru');

  @override
  Widget build(BuildContext context) {
    final meta = state.meta;
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(meta.title,
              style: AppTextStyles.screenTitle.copyWith(fontSize: 22)),
          if (meta.description != null && meta.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(meta.description!, style: AppTextStyles.screenSubtitle),
          ],
          if (state.status == TestPreviewStatus.locked &&
              meta.startedAt != null) ...[
            const SizedBox(height: 16),
            _ScheduledBanner(
              startTime: meta.startedAt!,
              durationSec: meta.totalTimeLimitSec,
            ),
          ],
          const SizedBox(height: 24),
          if (meta.questionCount > 0)
            _InfoCard(
              icon: Icons.quiz_outlined,
              title: 'Количество вопросов',
              value: '${meta.questionCount}',
            ),
          if (meta.hasTimeLimit) ...[
            if (meta.questionCount > 0) const SizedBox(height: 10),
            _InfoCard(
              icon: Icons.timer_outlined,
              title: 'Ограничение по времени',
              value: '${meta.timeLimitMinutes} мин',
            ),
          ],
          if (meta.finishedAt != null) ...[
            if (meta.questionCount > 0 || meta.hasTimeLimit)
              const SizedBox(height: 10),
            _InfoCard(
              icon: Icons.event_outlined,
              title: 'Дедлайн',
              value: _dateFmt.format(meta.finishedAt!.toLocal()),
            ),
          ],
          if (meta.needEvaluation) ...[
            const SizedBox(height: 10),
            _InfoCard(
              icon: Icons.auto_awesome_outlined,
              title: 'Проверка ответов',
              value: 'Автоматически + ИИ',
            ),
          ],
          const SizedBox(height: 20),
          if (meta.hasTimeLimit && state.status == TestPreviewStatus.start)
            _WarningBlock(
              text:
                  'Таймер запустится сразу после нажатия «Начать». Он не остановится, если вы покинете экран.',
            ),
          if (state.status == TestPreviewStatus.expired)
            _WarningBlock(text: 'Срок сдачи истёк', isError: true),
          if (state.status == TestPreviewStatus.grading)
            _WarningBlock(
              text: 'Ответы проверяются. Вернитесь позже за результатом.',
            ),
          const Spacer(),
          _BottomCta(state: state, sessionId: sessionId),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

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
      TestPreviewStatus.completed => 'Посмотреть результат',
    };

    final enabled = status == TestPreviewStatus.start ||
        status == TestPreviewStatus.resume ||
        status == TestPreviewStatus.completed;

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
    if (status == TestPreviewStatus.completed) {
      // Если review подгрузился — откроем разбор; иначе просто вернёмся назад,
      // чтобы не создавать второй attempt и не получать 409.
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

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
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.mono150),
            ),
            child: Icon(icon, size: 18, color: AppColors.mono700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
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
              fontWeight: FontWeight.w700,
              color: AppColors.mono900,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Баннер обратного отсчёта ────────────────────────────────────────────────

class _ScheduledBanner extends StatefulWidget {
  final DateTime startTime;
  final int? durationSec;

  const _ScheduledBanner({required this.startTime, this.durationSec});

  @override
  State<_ScheduledBanner> createState() => _ScheduledBannerState();
}

class _ScheduledBannerState extends State<_ScheduledBanner> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = widget.startTime.toLocal().difference(now);
    if (diff.isNegative) return const SizedBox.shrink();

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    final start = widget.startTime.toLocal();
    const ruWeekdays = [
      '', 'Понедельник', 'Вторник', 'Среда',
      'Четверг', 'Пятница', 'Суббота', 'Воскресенье',
    ];
    const ruMonths = [
      '', 'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
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
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
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

// ─────────────────────────────────────────────────────────────────────────────

class _WarningBlock extends StatelessWidget {
  final String text;
  final bool isError;
  const _WarningBlock({required this.text, this.isError = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEE2E2) : AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
            color: isError ? const Color(0xFFEF4444) : AppColors.mono150),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isError ? Icons.error_outline : Icons.info_outline,
              size: 16,
              color: isError
                  ? const Color(0xFFEF4444)
                  : AppColors.mono400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: isError
                    ? const Color(0xFFEF4444)
                    : AppColors.mono400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
