part of 'view_question_screen.dart';

class _ReadOnlyDragSection extends StatelessWidget {
  final List<String> items;
  const _ReadOnlyDragSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ЭЛЕМЕНТЫ В ПРАВИЛЬНОМ ПОРЯДКЕ', style: AppTextStyles.sectionTag),
        const SizedBox(height: 10),
        ...items.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ReadOnlyDragTile(index: e.key, text: e.value),
            )),
        const SizedBox(height: 8),
        Text(
          'Студент расставит элементы в нужном порядке перетаскиванием',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

