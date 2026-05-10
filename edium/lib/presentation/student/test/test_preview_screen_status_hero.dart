part of 'test_preview_screen.dart';

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

