import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:edium/presentation/teacher/test_monitoring/bloc/test_monitoring_bloc.dart';
import 'package:edium/presentation/teacher/test_monitoring/bloc/test_monitoring_event.dart';
import 'package:edium/presentation/teacher/test_monitoring/bloc/test_monitoring_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TestMonitoringScreen extends StatelessWidget {
  final String sessionId;
  final String classId;
  final CourseItem? courseItem;

  const TestMonitoringScreen({
    super.key,
    required this.sessionId,
    required this.classId,
    this.courseItem,
  });

  @override
  Widget build(BuildContext context) {
    final title = courseItem?.title ?? 'Тест';
    final needsManualGrading = courseItem?.needEvaluation ?? false;

    return BlocProvider(
      create: (_) => TestMonitoringBloc(
        listAttempts: getIt(),
        classRepo: getIt(),
      )..add(LoadTestMonitoringEvent(
          sessionId: sessionId,
          classId: classId,
          title: title,
          needsManualGrading: needsManualGrading,
        )),
      child: _View(sessionId: sessionId, courseItem: courseItem),
    );
  }
}

// ─── Корневой вид ─────────────────────────────────────────────────────────────

class _View extends StatelessWidget {
  final String sessionId;
  final CourseItem? courseItem;

  const _View({required this.sessionId, required this.courseItem});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TestMonitoringBloc, TestMonitoringState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(onBack: () => context.pop()),
                Expanded(child: _body(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, TestMonitoringState state) {
    if (state is TestMonitoringLoading || state is TestMonitoringInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mono700, strokeWidth: 2),
      );
    }

    if (state is TestMonitoringError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Не удалось загрузить данные',
                style: AppTextStyles.screenSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context
                    .read<TestMonitoringBloc>()
                    .add(const RefreshTestMonitoringEvent()),
                child: const Text('Повторить',
                    style: TextStyle(color: AppColors.mono900)),
              ),
            ],
          ),
        ),
      );
    }

    if (state is TestMonitoringLoaded) {
      return _LoadedBody(
        state: state,
        sessionId: sessionId,
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── Загруженный контент ──────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  final TestMonitoringLoaded state;
  final String sessionId;

  const _LoadedBody({required this.state, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final notStarted = state.rows.where((r) => r.status == null).length;
    final inProgress =
        state.rows.where((r) => r.status == AttemptStatus.inProgress).length;
    final finished = state.finishedCount;

    return RefreshIndicator(
      color: AppColors.mono700,
      onRefresh: () async => context
          .read<TestMonitoringBloc>()
          .add(const RefreshTestMonitoringEvent()),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPaddingH,
          0,
          AppDimens.screenPaddingH,
          24,
        ),
        children: [
          const SizedBox(height: 4),
          Text(state.title,
              style: AppTextStyles.screenTitle.copyWith(fontSize: 22)),
          const SizedBox(height: 16),
          _StatsStrip(
              notStarted: notStarted,
              inProgress: inProgress,
              finished: finished),
          if (state.needsManualGrading) ...[
            const SizedBox(height: 12),
            const _GradingBanner(),
          ],
          const SizedBox(height: 20),
          if (state.rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('Нет студентов в классе',
                    style: AppTextStyles.screenSubtitle),
              ),
            )
          else
            ...state.rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MonitoringRowTile(
                  row: row,
                  needsManualGrading: state.needsManualGrading,
                  onTap: _buildOnTap(context, row),
                ),
              ),
            ),
        ],
      ),
    );
  }

  VoidCallback? _buildOnTap(BuildContext context, MonitoringRow row) {
    if (row.attemptId == null) return null;
    if (row.needsTeacherAction) {
      return () => context
          .push('/test/$sessionId/attempts/${row.attemptId}/grade');
    }
    if (row.status == AttemptStatus.completed) {
      return () =>
          context.push('/test/$sessionId/attempts/${row.attemptId}');
    }
    return null;
  }
}

// ─── Плашка со статистикой ────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final int notStarted;
  final int inProgress;
  final int finished;

  const _StatsStrip({
    required this.notStarted,
    required this.inProgress,
    required this.finished,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono150, width: AppDimens.borderWidth),
      ),
      child: Row(
        children: [
          _StatCell(value: '$notStarted', label: 'Не начали'),
          _Divider(),
          _StatCell(value: '$inProgress', label: 'Проходят'),
          _Divider(),
          _StatCell(value: '$finished', label: 'Завершили'),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;

  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.mono900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.mono400),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: AppColors.mono150);
}

// ─── Баннер ручной проверки ───────────────────────────────────────────────────

class _GradingBanner extends StatelessWidget {
  const _GradingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: const [
          Icon(Icons.edit_outlined, size: 16, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Есть вопросы с развёрнутым ответом — нужна ручная проверка',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Строка студента ──────────────────────────────────────────────────────────

class _MonitoringRowTile extends StatelessWidget {
  final MonitoringRow row;
  final bool needsManualGrading;
  final VoidCallback? onTap;

  const _MonitoringRowTile({
    required this.row,
    required this.needsManualGrading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tappable = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: AppColors.mono150,
            width: AppDimens.borderWidth,
          ),
        ),
        child: Row(
          children: [
            _Avatar(name: row.displayName),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                row.displayName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mono900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _TrailingSection(row: row, needsManualGrading: needsManualGrading),
            if (tappable) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.mono300),
            ],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

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
        color: AppColors.mono100,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.mono600,
        ),
      ),
    );
  }
}

class _TrailingSection extends StatelessWidget {
  final MonitoringRow row;
  final bool needsManualGrading;

  const _TrailingSection({required this.row, required this.needsManualGrading});

  @override
  Widget build(BuildContext context) {
    final status = row.status;

    if (status == null) {
      return const _Chip(label: 'Не начинал', color: AppColors.mono250);
    }

    if (status == AttemptStatus.inProgress) {
      return const _Chip(label: 'В процессе', color: AppColors.mono600);
    }

    if (status == AttemptStatus.grading) {
      return const _Chip(label: 'Завершил', color: AppColors.mono300);
    }

    if (status == AttemptStatus.graded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Chip(label: 'Завершил', color: AppColors.mono900),
          if (needsManualGrading) ...[
            const SizedBox(width: 6),
            const Icon(Icons.edit_outlined, size: 15, color: AppColors.mono400),
          ],
        ],
      );
    }

    // completed
    final scoreText = row.score != null
        ? '${row.score!.toStringAsFixed(row.score! % 1 == 0 ? 0 : 1)}%'
        : '—';
    return Text(
      scoreText,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.mono900,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
        border: Border.all(color: AppColors.mono150, width: AppDimens.borderWidth),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Шапка ────────────────────────────────────────────────────────────────────

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
