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

  const TestSessionResultsScreen({
    super.key,
    required this.sessionId,
    this.courseItem,
    this.isTeacher = false,
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
      )..add(LoadSessionResultsEvent(sessionId: sessionId, title: title)),
      child: _View(sessionId: sessionId),
    );
  }
}

class _View extends StatelessWidget {
  final String sessionId;
  const _View({required this.sessionId});

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
                Expanded(child: _body(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, TestSessionResultsState state) {
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
            const SizedBox(height: 8),
            Text(state.title,
                style: AppTextStyles.screenTitle.copyWith(fontSize: 22)),
            const SizedBox(height: 16),
            _SummaryStrip(
              totalCount: state.totalCount,
              completedCount: state.completedCount,
              averageScorePct: state.averageScorePct,
            ),
            const SizedBox(height: 20),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono150),
      ),
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
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.mono900,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.mono400)),
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

class _StudentRowTile extends StatelessWidget {
  final StudentRow row;
  final VoidCallback? onTap;
  const _StudentRowTile({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final attempt = row.attempt;
    final chip = _statusChip(attempt?.status);
    final scoreText = attempt?.score != null
        ? '${attempt!.score!.toStringAsFixed(0)}%'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.mono150),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  row.displayName,
                  style: AppTextStyles.fieldText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (chip != null) chip,
              if (scoreText != null) ...[
                const SizedBox(width: 8),
                Text(
                  scoreText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget? _statusChip(AttemptStatus? status) {
    if (status == null) {
      return const _Chip(label: 'Не начал', color: AppColors.mono300);
    }
    switch (status) {
      case AttemptStatus.inProgress:
        return const _Chip(label: 'Проходит…', color: AppColors.mono600);
      case AttemptStatus.grading:
        return const _Chip(label: 'Проверка ИИ', color: AppColors.mono600);
      case AttemptStatus.graded:
        return const _Chip(
            label: 'Готов к проверке', color: AppColors.mono900);
      case AttemptStatus.completed:
        return null;
    }
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
        border: Border.all(color: AppColors.mono150),
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
