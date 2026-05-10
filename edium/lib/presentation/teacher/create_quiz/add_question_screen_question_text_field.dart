part of 'add_question_screen.dart';

class _QuestionTextField extends StatefulWidget {
  final TextEditingController controller;
  const _QuestionTextField({required this.controller});

  @override
  State<_QuestionTextField> createState() => _QuestionTextFieldState();
}

class _QuestionTextFieldState extends State<_QuestionTextField> {
  static const _maxLength = 300;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ТЕКСТ ВОПРОСА', style: AppTextStyles.sectionTag),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          textCapitalization: TextCapitalization.sentences,
          style: AppTextStyles.subtitle.copyWith(color: AppColors.mono900),
          decoration: InputDecoration(
            hintText: 'Введите вопрос...',
            hintStyle: AppTextStyles.subtitle.copyWith(
              color: AppColors.mono300,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            counterText: '',
          ),
          cursorColor: AppColors.mono900,
          minLines: 1,
          maxLines: null,
          maxLength: _maxLength,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.mono100)),
            const SizedBox(width: 8),
            ListenableBuilder(
              listenable: widget.controller,
              builder: (_, __) => Text(
                '${widget.controller.text.length}/$_maxLength',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.mono300, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

