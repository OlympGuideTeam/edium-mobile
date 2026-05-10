part of 'invite_screen.dart';

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

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
              Icons.error_outline,
              size: 32,
              color: AppColors.mono700,
            ),
          ),
          const SizedBox(height: 32),
          Text('Не удалось принять\nприглашение', style: AppTextStyles.heading1),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.mono400),
          ),
          const Spacer(),
          _PrimaryButton(label: 'Попробовать снова', onTap: onRetry),
          const SizedBox(height: 16),
          _SecondaryButton(
            label: 'На главную',
            onTap: () => context.go('/welcome'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

