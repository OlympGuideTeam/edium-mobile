part of 'create_quiz_screen.dart';

class _TitleField extends StatelessWidget {
  final TextEditingController controller;
  const _TitleField({required this.controller});

  static const _maxLength = 100;

  static const _inputDecoration = InputDecoration(
    hintText: 'Например: Алгебра — контрольная',
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    contentPadding: EdgeInsets.zero,
    isDense: true,
    counterText: '',
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Название', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          style: AppTextStyles.subtitle.copyWith(color: AppColors.mono900),
          decoration: _inputDecoration.copyWith(
            hintStyle: AppTextStyles.subtitle.copyWith(
              color: AppColors.mono300,
              fontWeight: FontWeight.w400,
            ),
          ),
          cursorColor: AppColors.mono900,
          minLines: 1,
          maxLines: null,
          maxLength: _maxLength,
          textInputAction: TextInputAction.next,
          onChanged: (v) =>
              context.read<CreateQuizBloc>().add(UpdateTitleEvent(v)),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.mono100)),
            const SizedBox(width: 8),
            ListenableBuilder(
              listenable: controller,
              builder: (_, __) => Text(
                '${controller.text.length}/$_maxLength',
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

