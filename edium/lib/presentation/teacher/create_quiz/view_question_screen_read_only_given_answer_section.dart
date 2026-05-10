part of 'view_question_screen.dart';

class _ReadOnlyGivenAnswerSection extends StatelessWidget {
  final List<String> answers;
  const _ReadOnlyGivenAnswerSection({required this.answers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ПРАВИЛЬНЫЕ ОТВЕТЫ', style: AppTextStyles.sectionTag),
        const SizedBox(height: 10),
        ...answers.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ReadOnlyTextTile(
                text: e.value,
                hint: 'Принимаемый ответ ${e.key + 1}',
              ),
            )),
        const SizedBox(height: 8),
        Text(
          'Система примет любой из указанных вариантов написания',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

