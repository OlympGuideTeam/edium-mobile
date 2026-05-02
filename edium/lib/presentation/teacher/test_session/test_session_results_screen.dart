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

class TestSessionResultsScreen extends StatelessWidget {
  final String sessionId;
  final CourseItem? courseItem;
  final bool isTeacher;
  final String? classId;

  const TestSessionResultsScreen({
    super.key,
    required this.sessionId,
    this.courseItem,
    this.isTeacher = false,
    this.classId,
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
        classRepo: getIt(),
      )..add(LoadSessionResultsEvent(
          sessionId: sessionId,
          title: title,
          classId: classId,
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

  Widget _body(BuildContext context, TestSessionResultsState state, CourseItem? courseItem) {
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
            Text(state.title,
                style: AppTextStyles.screenTitle.copyWith(fontSize: 22)),
            if (isScheduled) ...[
              const SizedBox(height: 16),
              _ScheduledBanner(
                startTime: startTime,
                durationSec: courseItem?.payload?.totalTimeLimitSec,
              ),
            ],
            const SizedBox(height: 16),
            _SummaryStrip(
              totalCount: state.totalCount,
              completedCount: state.completedCount,
              averageScorePct: state.averageScorePct,
            ),
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
                  child: Text('Пока никто не начинал тест',
                      style: AppTextStyles.screenSubtitle),
                ),
              )
            else
              ...state.rows.map((r) => _StudentRowTile(
                    row: r,
                    onTap: r.attempt != null
                        ? () {
                            final status = r.attempt!.status;
                            if (status == AttemptStatus.graded) {
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

// ─── Сводная полоска ─────────────────────────────────────────────────────────

class _SummaryStrip extends StatelessWidget {
  final int totalCount;
  final int completedCount;
  final double? averageScorePct;
  const _SummaryStrip({
    required this.totalCount,
    required this.completedCount,
    required this.averageScorePct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono150, width: AppDimens.borderWidth),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            _Stat(label: 'Всего', value: '$totalCount'),
            _StatDivider(),
            _Stat(label: 'Завершили', value: '$completedCount'),
            _StatDivider(),
            _Stat(
              label: 'Средний балл',
              value: averageScorePct != null
                  ? '${averageScorePct!.toStringAsFixed(0)}%'
                  : '—',
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.mono900,
              )),
          const SizedBox(height: 3),
          Text(label,
              style: AppTextStyles.caption.copyWith(color: AppColors.mono400)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 36,
        color: AppColors.mono150,
      );
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
              _Avatar(name: row.displayName, muted: isInactive),
              const SizedBox(width: 12),
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

// ─── Аватар ──────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final bool muted;
  const _Avatar({required this.name, this.muted = false});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: muted ? AppColors.mono50 : AppColors.mono100,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: muted ? AppColors.mono300 : AppColors.mono600,
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
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Удалить тест?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.mono900,
          ),
        ),
        content: const Text(
          'Никто ещё не начал этот тест. Действие нельзя отменить.',
          style: TextStyle(fontSize: 14, color: AppColors.mono600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена',
                style: TextStyle(color: AppColors.mono600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Удалить',
              style: TextStyle(
                  color: AppColors.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
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
