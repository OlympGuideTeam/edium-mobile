part of 'view_question_screen.dart';

class _ReadOnlyConnectionSection extends StatelessWidget {
  final List<String> left;
  final List<String> right;

  const _ReadOnlyConnectionSection(
      {required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final count = left.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ПАРЫ СООТВЕТСТВИЯ', style: AppTextStyles.sectionTag),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Левая колонка',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.mono400, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 36),
            Expanded(
              child: Text(
                'Правая колонка',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.mono400, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(count, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ReadOnlyConnectionPairTile(
                leftText: i < left.length ? left[i] : '',
                rightText: i < right.length ? right[i] : '',
                index: i,
              ),
            )),
        const SizedBox(height: 8),
        Text(
          'Студент соединит левые элементы с правыми',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

