part of 'live_student_screen.dart';

class _OptionCard extends StatelessWidget {
  final bool isSelected;
  final Widget child;

  const _OptionCard({required this.isSelected, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.liveDarkSurface : AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.liveAccent : AppColors.liveDarkBorder,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}

