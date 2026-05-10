part of 'review_session_screen.dart';

class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.screenPaddingH,
        16,
        AppDimens.screenPaddingH,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.mono700,
            ),
          ),
          const SizedBox(height: 16),
          const Text('ОЖИДАЮТ ПРОВЕРКИ', style: AppTextStyles.sectionTag),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTextStyles.screenTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

