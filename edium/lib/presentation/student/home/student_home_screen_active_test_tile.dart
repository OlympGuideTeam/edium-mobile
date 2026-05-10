part of 'student_home_screen.dart';

class _ActiveTestTile extends StatelessWidget {
  final ActiveTestItem item;

  static final _dateFmt = DateFormat('d MMM', 'ru');

  const _ActiveTestTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        onTap: () => context.push(
          '/test/${item.sessionId}',
          extra: {'quizTitle': item.quizTitle},
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                      item.quizTitle,
                      style: AppTextStyles.fieldText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle,
                      style: AppTextStyles.helperText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: AppColors.mono300, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String get _subtitle {
    if (item.attemptStatus == 'in_progress') return 'В процессе';
    if (item.sessionFinishedAt != null) {
      return 'Дедлайн: ${_dateFmt.format(item.sessionFinishedAt!.toLocal())}';
    }
    return 'Доступен';
  }
}

