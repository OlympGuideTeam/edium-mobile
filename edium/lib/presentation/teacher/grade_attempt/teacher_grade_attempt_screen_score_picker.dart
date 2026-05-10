part of 'teacher_grade_attempt_screen.dart';

class _ScorePicker extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onFeedbackChanged;
  const _ScorePicker({required this.controller, this.onFeedbackChanged});

  @override
  Widget build(BuildContext context) {
    final selected = int.tryParse(controller.text.trim());
    return Column(
      children: [
        _ScoreRow(
            values: const [1, 2, 3, 4, 5],
            selected: selected,
            controller: controller,
            onSelected: onFeedbackChanged),
        const SizedBox(height: 6),
        _ScoreRow(
            values: const [6, 7, 8, 9, 10],
            selected: selected,
            controller: controller,
            onSelected: onFeedbackChanged),
      ],
    );
  }
}

