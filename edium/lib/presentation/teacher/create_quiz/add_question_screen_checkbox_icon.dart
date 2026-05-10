part of 'add_question_screen.dart';

class _CheckboxIcon extends StatelessWidget {
  final bool isCorrect;
  const _CheckboxIcon({required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: isCorrect ? AppColors.mono900 : Colors.transparent,
        border: Border.all(
          color: isCorrect ? AppColors.mono900 : AppColors.mono300,
          width: 1.5,
        ),
      ),
      child: isCorrect
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );
  }
}

