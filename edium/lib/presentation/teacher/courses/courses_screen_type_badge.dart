part of 'courses_screen.dart';

class _TypeBadge extends StatelessWidget {
  final bool isTemplate;
  const _TypeBadge({required this.isTemplate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isTemplate ? AppColors.mono100 : AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        isTemplate ? 'ШАБЛОН' : 'КВИЗ',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: isTemplate ? AppColors.mono400 : Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

