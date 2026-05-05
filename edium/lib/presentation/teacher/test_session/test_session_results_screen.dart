import 'dart:async';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
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
    if (!isTeacher) {
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
        repo: getIt(),
        liveRepo: getIt(),
      )..add(LoadSessionResultsEvent(
          sessionId: sessionId,
          title: title,
          moduleId: moduleId,
        )),
      child: _View(sessionId: sessionId, courseItem: courseItem),
    );
  }
}

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
      final startTime = courseItem?.startTime;
      final isScheduled = courseItem?.state == 'waiting' &&
          startTime != null &&
          startTime.isAfter(DateTime.now());

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
            _StatusHero(
              state: state,
              isScheduled: isScheduled,
              startTime: startTime,
              durationSec: courseItem?.payload?.totalTimeLimitSec,
            ),
            const SizedBox(height: 20),
            _DetailsSection(courseItem: courseItem),
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
                    isScheduled
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
                        ? () {
                            final status = r.attempt!.status;
                            if (status == AttemptStatus.graded ||
                                status == AttemptStatus.grading) {
                              context.push(
                                '/test/$sessionId/attempts/${r.attempt!.attemptId}/grade',
                              );
                            } else {
                              context.push(
                                '/test/$sessionId/attempts/${r.attempt!.attemptId}',
                              );
                            }
                          }
                        : null,
                  )),
            if (state.canDelete) ...[
              const SizedBox(height: 20),
              _DeleteButton(isDeleting: state.isDeleting),
            ],
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
  final bool isScheduled;
  final DateTime? startTime;
  final int? durationSec;

  const _StatusHero({
    required this.state,
    required this.isScheduled,
    this.startTime,
    this.durationSec,
  });

  @override
  Widget build(BuildContext context) {
    if (isScheduled && startTime != null) {
      return _ScheduledBanner(startTime: startTime!, durationSec: durationSec);
    }

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

  ({String tag, String title, String? subtitle}) _heroContent() {
    final total = state.totalCount;
    final avg = state.averageScorePct;
    final nobodyStarted = state.rows.every((r) => r.attempt == null);

    final finishedCount = state.rows.where((r) {
      final s = r.attempt?.status;
      return s == AttemptStatus.grading ||
          s == AttemptStatus.graded ||
          s == AttemptStatus.completed;
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
        subtitle: 'из 100 · ${_pluralStudents(total)}',
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

// ─── Секция деталей ─────────────────────────────────────────────────────────

class _DetailsSection extends StatelessWidget {
  final CourseItem? courseItem;
  const _DetailsSection({required this.courseItem});

  static final _dateFmt = DateFormat('d MMM, HH:mm', 'ru');

  @override
  Widget build(BuildContext context) {
    final payload = courseItem?.payload;
    final rows = <_DetailRow>[];

    final hasTimeLimit =
        payload?.totalTimeLimitSec != null && payload!.totalTimeLimitSec! > 0;
    rows.add(_DetailRow(
      icon: Icons.timer_outlined,
      label: 'Время',
      value: hasTimeLimit
          ? '${(payload.totalTimeLimitSec! / 60).round()} мин'
          : 'Без ограничений',
    ));

    if (courseItem?.endTime != null) {
      rows.add(_DetailRow(
        icon: Icons.event_outlined,
        label: 'Дедлайн',
        value: _dateFmt.format(courseItem!.endTime!.toLocal()),
      ));
    }

    if (payload?.shuffleQuestions == true) {
      rows.add(const _DetailRow(
        icon: Icons.shuffle_rounded,
        label: 'Порядок вопросов',
        value: 'Случайный',
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
    final scoreText = attempt?.score != null
        ? '${attempt!.score!.toStringAsFixed(0)}%'
        : null;
    final tappable = onTap != null;
    final needsAction = status == AttemptStatus.graded;
    final isInactive = status == null;

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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  row.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isInactive ? AppColors.mono400 : AppColors.mono900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: status),
              if (scoreText != null) ...[
                const SizedBox(width: 6),
                Text(
                  scoreText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                ),
              ],
              if (tappable) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: needsAction ? AppColors.mono400 : AppColors.mono300,
                ),
              ],
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
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case null:
        return const _Chip(
          label: 'Не начал',
          textColor: AppColors.mono350,
          bgColor: Colors.transparent,
          borderColor: AppColors.mono150,
        );
      case AttemptStatus.inProgress:
        return const _Chip(
          label: 'Проходит',
          textColor: AppColors.mono400,
          bgColor: AppColors.mono50,
          borderColor: AppColors.mono150,
        );
      case AttemptStatus.grading:
        return const _Chip(
          label: 'Проверка ИИ',
          textColor: AppColors.mono400,
          bgColor: AppColors.mono50,
          borderColor: AppColors.mono150,
        );
      case AttemptStatus.graded:
        return const _Chip(
          label: 'К проверке',
          textColor: Colors.white,
          bgColor: AppColors.mono900,
          borderColor: AppColors.mono900,
          icon: Icons.edit_outlined,
        );
      case AttemptStatus.completed:
        return const SizedBox.shrink();
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
        border: Border.all(color: borderColor, width: AppDimens.borderWidth),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Кнопка удаления ─────────────────────────────────────────────────────────

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

// ─── Баннер обратного отсчёта ────────────────────────────────────────────────

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
