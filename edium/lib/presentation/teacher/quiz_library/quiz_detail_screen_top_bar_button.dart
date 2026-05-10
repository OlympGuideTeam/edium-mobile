part of 'quiz_detail_screen.dart';

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _TopBarButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: AppColors.mono50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.mono100),
        ),
        child: Icon(icon, size: 18, color: AppColors.mono700),
      ),
    );
  }
}

