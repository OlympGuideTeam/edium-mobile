part of 'invite_screen.dart';

class _AlreadyMemberBody extends StatelessWidget {
  final VoidCallback onGoHome;
  const _AlreadyMemberBody({required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 32,
              color: AppColors.mono700,
            ),
          ),
          const SizedBox(height: 32),
          Text('Вы уже в классе', style: AppTextStyles.heading1),
          const SizedBox(height: 12),
          Text(
            'Вы уже являетесь участником этого класса.',
            style: AppTextStyles.body.copyWith(color: AppColors.mono400),
          ),
          const Spacer(),
          _PrimaryButton(label: 'На главную', onTap: onGoHome),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

