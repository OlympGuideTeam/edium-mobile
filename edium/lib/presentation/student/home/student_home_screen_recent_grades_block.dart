part of 'student_home_screen.dart';

class _RecentGradesBlock extends StatelessWidget {
  final List<RecentGradeItem> items;

  const _RecentGradesBlock({required this.items});

  @override
  Widget build(BuildContext context) {
    final scored = items.where((e) => e.score != null).toList();
    final avg = scored.isEmpty
        ? null
        : scored.fold(0.0, (sum, e) => sum + e.score!) / scored.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: AppColors.mono150,
          width: AppDimens.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Expanded(
                child: Text(
                  'Среднее',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mono400,
                  ),
                ),
              ),
              Text(
                avg != null ? avg.toStringAsFixed(1) : '—',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.mono100),
          const SizedBox(height: 12),
          ...items.map((item) => _GradeRow(item: item)),
        ],
      ),
    );
  }
}

