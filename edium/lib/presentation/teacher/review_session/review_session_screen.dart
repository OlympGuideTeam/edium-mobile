import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/attempt_summary.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:edium/domain/usecases/test_session/list_session_attempts_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// ─── Cubit ────────────────────────────────────────────────────────────────────

sealed class _State extends Equatable {
  const _State();
  @override
  List<Object?> get props => [];
}

class _Loading extends _State {
  const _Loading();
}

class _Loaded extends _State {
  final List<AttemptSummary> attempts;
  const _Loaded(this.attempts);
  @override
  List<Object?> get props => [attempts];
}

class _Error extends _State {
  final String message;
  const _Error(this.message);
  @override
  List<Object?> get props => [message];
}

class _Cubit extends Cubit<_State> {
  final ListSessionAttemptsUsecase _usecase;
  final String sessionId;

  _Cubit(this._usecase, this.sessionId) : super(const _Loading()) {
    _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    emit(const _Loading());
    try {
      final all = await _usecase(sessionId);
      final reviewable = all
          .where((a) =>
              a.status == AttemptStatus.graded ||
              a.status == AttemptStatus.grading)
          .toList()
        ..sort((a, b) => _statusOrder(a.status) - _statusOrder(b.status));
      emit(_Loaded(reviewable));
    } catch (e) {
      emit(_Error(e.toString()));
    }
  }

  // graded (ждут учителя) первыми, grading (у ИИ) — после
  static int _statusOrder(AttemptStatus s) =>
      s == AttemptStatus.graded ? 0 : 1;
}

// ─── Экран ────────────────────────────────────────────────────────────────────

class ReviewSessionScreen extends StatelessWidget {
  final String sessionId;
  final String quizTitle;

  const ReviewSessionScreen({
    super.key,
    required this.sessionId,
    required this.quizTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _Cubit(getIt<ListSessionAttemptsUsecase>(), sessionId),
      child: _View(sessionId: sessionId, quizTitle: quizTitle),
    );
  }
}

class _View extends StatelessWidget {
  final String sessionId;
  final String quizTitle;

  const _View({required this.sessionId, required this.quizTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(title: quizTitle),
            Expanded(
              child: BlocBuilder<_Cubit, _State>(
                builder: (context, state) => switch (state) {
                  _Loading() => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mono700,
                        strokeWidth: 2,
                      ),
                    ),
                  _Error(:final message) => _ErrorBody(
                      message: message,
                      onRetry: () => context.read<_Cubit>().refresh(),
                    ),
                  _Loaded(:final attempts) => _LoadedBody(
                      attempts: attempts,
                      sessionId: sessionId,
                      onRefresh: () => context.read<_Cubit>().refresh(),
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Шапка ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.screenPaddingH,
        16,
        AppDimens.screenPaddingH,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.mono700,
            ),
          ),
          const SizedBox(height: 16),
          const Text('ОЖИДАЮТ ПРОВЕРКИ', style: AppTextStyles.sectionTag),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTextStyles.screenTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Тело при ошибке ──────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Не удалось загрузить попытки',
              style: AppTextStyles.screenSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Повторить',
                style: TextStyle(color: AppColors.mono900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Загруженное тело ─────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  final List<AttemptSummary> attempts;
  final String sessionId;
  final Future<void> Function() onRefresh;

  const _LoadedBody({
    required this.attempts,
    required this.sessionId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (attempts.isEmpty) {
      return Center(
        child: Text(
          'Нет попыток для проверки',
          style: AppTextStyles.screenSubtitle,
        ),
      );
    }

    final gradedCount =
        attempts.where((a) => a.status == AttemptStatus.graded).length;
    final gradingCount =
        attempts.where((a) => a.status == AttemptStatus.grading).length;

    return RefreshIndicator(
      color: AppColors.mono700,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPaddingH,
          8,
          AppDimens.screenPaddingH,
          24,
        ),
        children: [
          _SummaryStrip(gradedCount: gradedCount, gradingCount: gradingCount),
          const SizedBox(height: 20),
          ...attempts.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AttemptTile(
                attempt: a,
                onTap: () => context.push(
                  '/test/$sessionId/attempts/${a.attemptId}/grade',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Сводная полоска ──────────────────────────────────────────────────────────

class _SummaryStrip extends StatelessWidget {
  final int gradedCount;
  final int gradingCount;

  const _SummaryStrip({
    required this.gradedCount,
    required this.gradingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: AppColors.mono150,
          width: AppDimens.borderWidth,
        ),
      ),
      child: Row(
        children: [
          _Cell(
            value: '$gradedCount',
            label: 'Ждут учителя',
            highlight: gradedCount > 0,
          ),
          _Divider(),
          _Cell(
            value: '$gradingCount',
            label: 'Проверяет ИИ',
            highlight: false,
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;

  const _Cell({
    required this.value,
    required this.label,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: highlight ? AppColors.mono900 : AppColors.mono300,
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
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: AppColors.mono150);
  }
}

// ─── Строка попытки ───────────────────────────────────────────────────────────

class _AttemptTile extends StatelessWidget {
  final AttemptSummary attempt;
  final VoidCallback? onTap;

  const _AttemptTile({required this.attempt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGraded = attempt.status == AttemptStatus.graded;
    final name = attempt.userName?.isNotEmpty == true
        ? attempt.userName!
        : attempt.userId;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: AppColors.mono150,
              width: AppDimens.borderWidth,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.fieldText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGraded ? 'Ждёт проверки учителя' : 'Проверяет ИИ',
                      style: AppTextStyles.helperText.copyWith(
                        color: isGraded
                            ? AppColors.mono600
                            : AppColors.mono300,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.mono300,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
