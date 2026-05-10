part of 'test_preview_screen.dart';

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

