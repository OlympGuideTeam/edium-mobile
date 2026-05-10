part of 'teacher_grade_attempt_screen.dart';

class _ScoreRow extends StatelessWidget {
  final List<int> values;
  final int? selected;
  final TextEditingController controller;
  final VoidCallback? onSelected;

  const _ScoreRow({
    required this.values,
    required this.selected,
    required this.controller,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
              child: _ScoreChip(
                  value: values[i],
                  isSelected: selected == values[i],
                  controller: controller,
                  onSelected: onSelected)),
        ],
      ],
    );
  }
}

