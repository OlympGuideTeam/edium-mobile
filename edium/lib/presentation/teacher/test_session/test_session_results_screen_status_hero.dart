part of 'test_session_results_screen.dart';

class _StatusHero extends StatelessWidget {
  final TestSessionResultsLoaded state;

  const _StatusHero({required this.state});

  @override
  Widget build(BuildContext context) {
    final status = state.sessionStatus;
    final startedAt = state.startedAt;
    final finishedAt = state.finishedAt;
    final now = DateTime.now();


    if ((status == null || status == 'not_started' || status == 'waiting') &&
        startedAt != null &&
        startedAt.isAfter(now)) {
      return _CountdownBanner(
        label: 'СТАРТ ЧЕРЕЗ',
        target: startedAt,
      );
    }


    if (status == 'active' &&
        finishedAt != null &&
        finishedAt.isAfter(now)) {
      return _CountdownBanner(
        label: 'ОСТАЛОСЬ',
        target: finishedAt,
        subtitle: _deadlineSubtitle(finishedAt),
      );
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

