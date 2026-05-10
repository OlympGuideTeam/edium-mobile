part of 'live_student_screen.dart';

class _LiveEdgeDot extends StatelessWidget {
  final bool active;
  const _LiveEdgeDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.liveDarkMuted : AppColors.liveDarkCard,
        border: Border.all(
          color: active ? AppColors.liveDarkMuted : AppColors.liveDarkBorder,
          width: 1.5,
        ),
      ),
    );
  }
}

