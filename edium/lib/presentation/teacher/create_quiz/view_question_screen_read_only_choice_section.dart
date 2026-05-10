part of 'view_question_screen.dart';

class _ReadOnlyChoiceSection extends StatelessWidget {
  final List<AnswerOption> options;
  final bool isMulti;

  const _ReadOnlyChoiceSection({required this.options, required this.isMulti});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ВАРИАНТЫ ОТВЕТА', style: AppTextStyles.sectionTag),
        const SizedBox(height: 10),
        ...options.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ReadOnlyOptionTile(option: opt, isMulti: isMulti),
            )),
        const SizedBox(height: 8),
        Text(
          isMulti
              ? 'Правильных ответов: ${options.where((o) => o.isCorrect).length}'
              : 'Один правильный ответ',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

