part of 'course_detail_screen.dart';

class _AppBar extends StatelessWidget {
  final VoidCallback onBack;
  final Widget? trailing;

  const _AppBar({required this.onBack, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.mono900,
            ),
            onPressed: onBack,
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

