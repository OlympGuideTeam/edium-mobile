part of 'teacher_grade_question_screen.dart';

class _ScorePicker extends StatelessWidget {
  final TextEditingController controller;
  const _ScorePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    final selected = int.tryParse(controller.text.trim());
    return Column(
      children: [
        _ScoreRow(
            values: const [1, 2, 3, 4, 5],
            selected: selected,
            controller: controller),
        const SizedBox(height: 6),
        _ScoreRow(
            values: const [6, 7, 8, 9, 10],
            selected: selected,
            controller: controller),
      ],
    );
  }
}

