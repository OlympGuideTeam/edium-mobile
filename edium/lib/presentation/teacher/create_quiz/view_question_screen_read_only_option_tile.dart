part of 'view_question_screen.dart';

class _ReadOnlyOptionTile extends StatelessWidget {
  final AnswerOption option;
  final bool isMulti;

  const _ReadOnlyOptionTile({required this.option, required this.isMulti});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: option.isCorrect ? AppColors.mono900 : AppColors.mono150,
          width: option.isCorrect ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: isMulti
                ? _CheckboxIcon(isCorrect: option.isCorrect)
                : _RadioIcon(isCorrect: option.isCorrect),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 14, top: 14, bottom: 14),
              child: Text(
                option.text,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

