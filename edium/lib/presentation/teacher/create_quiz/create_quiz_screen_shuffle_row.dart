part of 'create_quiz_screen.dart';

class _ShuffleRow extends StatelessWidget {
  final bool value;
  const _ShuffleRow({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Перемешать вопросы',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.mono700),
            ),
          ),
          _MonoSwitch(
            value: value,
            onChanged: (v) => context
                .read<CreateQuizBloc>()
                .add(UpdateShuffleQuestionsEvent(v)),
          ),
        ],
      ),
    );
  }
}

