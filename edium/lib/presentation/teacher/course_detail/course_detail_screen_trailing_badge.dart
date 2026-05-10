part of 'course_detail_screen.dart';

class _TrailingBadge extends StatelessWidget {
  final CourseItem item;
  final bool isTeacher;
  final SessionStatusItem? sessionStatus;
  const _TrailingBadge({
    required this.item,
    required this.isTeacher,
    this.sessionStatus,
  });

  @override
  Widget build(BuildContext context) {
    return isTeacher ? _teacherBadge() : _studentBadge();
  }

  Widget _teacherBadge() {
    final String label;
    if (sessionStatus != null) {
      final s = sessionStatus!;
      if (s.mode == 'live') {
        label = switch (s.phase) {
          'lobby' => 'Лобби',
          'question_active' || 'question_locked' => 'Идёт',
          'completed' => 'Завершён',
          _ => 'Не начат',
        };
      } else {
        label = switch (s.status) {
          'active' => 'Идёт',
          'finished' => 'Завершён',
          _ => 'Не начат',
        };
      }
    } else {
      final now = DateTime.now();
      final p = item.payload;
      if (p == null) {
        label = 'Не начат';
      } else if (p.finishedAt != null && now.isAfter(p.finishedAt!)) {
        label = 'Завершён';
      } else if (p.startedAt == null || !now.isBefore(p.startedAt!)) {
        label = 'Идёт';
      } else {
        label = 'Ожидает';
      }
    }
    return Text(
      label,
      style: const TextStyle(fontSize: 12, color: AppColors.mono300),
    );
  }

  Widget _studentBadge() {
    final s = sessionStatus;
    if (s != null) {
      final as_ = s.attemptStatus;


      if (as_ == 'grading' || as_ == 'graded' || as_ == 'completed') {
        return _chip(
          icon: Icons.hourglass_top_outlined,
          label: 'Проверяется',
        );
      }
      if (as_ == 'published') {
        final score = s.score ?? item.score;
        return _scoreChip(score);
      }
      if (as_ == 'kicked') {
        return _labelText('Дисквалифицирован', actionable: false);
      }
      if (as_ == 'in_progress') {
        return _labelText('Продолжить →', actionable: true);
      }


      if (s.mode == 'live') {
        return switch (s.phase) {
          'lobby' => _labelText('Войти →', actionable: true),
          'question_active' || 'question_locked' => _labelText('Идёт', actionable: false),
          'completed' => _labelText('Завершён', actionable: false),
          _ => _labelText('Ожидает', actionable: false),
        };
      } else {
        return switch (s.status) {
          'active' => _labelText('Начать →', actionable: true),
          'finished' => _labelText('Завершён', actionable: false),
          _ => _labelText('Ожидает', actionable: false),
        };
      }
    }


    if (item.isPassed) {
      if (item.state != 'published') {
        return _chip(icon: Icons.check_circle_outline, label: 'Пройден');
      }
      return _scoreChip(item.score);
    }
    final label = studentTestActionLabel(item);
    final actionable = item.state == 'in_progress' ||
        item.state == null ||
        item.state == 'not_started';
    return _labelText(label, actionable: actionable);
  }

  Widget _scoreChip(double? score) {
    if (score == null) {
      return _chip(icon: Icons.check_circle_outline, label: 'Пройден');
    }
    final text = '${score.toStringAsFixed(score % 1 == 0 ? 0 : 1)}%';
    return _chip(icon: Icons.check_circle_outline, label: text);
  }

  Widget _chip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.mono100,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.mono600),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.mono600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelText(String label, {required bool actionable}) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: actionable ? FontWeight.w600 : FontWeight.w400,
        color: actionable ? AppColors.mono900 : AppColors.mono300,
      ),
    );
  }
}

