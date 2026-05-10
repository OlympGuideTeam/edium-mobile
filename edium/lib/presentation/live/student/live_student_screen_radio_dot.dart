part of 'live_student_screen.dart';

class _RadioDot extends StatelessWidget {
  final bool isSelected;
  const _RadioDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.liveAccent : const Color(0xFF4A4A4A),
          width: isSelected ? 6 : 2,
        ),
      ),
    );
  }
}

