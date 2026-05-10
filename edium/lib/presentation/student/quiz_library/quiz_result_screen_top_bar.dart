part of 'quiz_result_screen.dart';

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final Widget? trailing;
  const _TopBar({required this.onBack, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: AppColors.mono900),
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          const Text('Результаты', style: AppTextStyles.screenTitle),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

