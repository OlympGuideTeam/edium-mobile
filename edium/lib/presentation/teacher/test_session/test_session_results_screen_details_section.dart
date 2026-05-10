part of 'test_session_results_screen.dart';

class _DetailsSection extends StatelessWidget {
  final TestSessionResultsLoaded state;
  const _DetailsSection({required this.state});

  static final _dateFmt = DateFormat('d MMM, HH:mm', 'ru');

  @override
  Widget build(BuildContext context) {
    final rows = <_DetailRow>[];

    if (state.finishedAt != null) {
      rows.add(_DetailRow(
        icon: Icons.event_outlined,
        label: 'Дедлайн',
        value: _dateFmt.format(state.finishedAt!.toLocal()),
      ));
    }

    if (state.startedAt != null) {
      rows.add(_DetailRow(
        icon: Icons.schedule_outlined,
        label: 'Открывается',
        value: _dateFmt.format(state.startedAt!.toLocal()),
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

