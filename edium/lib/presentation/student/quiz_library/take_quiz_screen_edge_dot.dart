part of 'take_quiz_screen.dart';

class _EdgeDot extends StatelessWidget {
  final bool active;
  const _EdgeDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.mono700 : Colors.white,
        border: Border.all(
          color: active ? AppColors.mono700 : AppColors.mono250,
          width: 1.5,
        ),
      ),
    );
  }
}

